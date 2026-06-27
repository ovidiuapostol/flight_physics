-----------------------------------------------------------------------
--  Simulation_Loop.adb
--  Package: Simulation_Loop
--  Purpose: Replace the previous generic_cyclic_task for
--           performing the simulation. It implements a cyclic task that
--           call in a sequence the simulation steps:
--             - aerodynamics
--             - dynamics
--             - integrator
--             - PID
--             - loging and display
--  Author : Ovi
-----------------------------------------------------------------------
with Ada.Text_IO; use Ada.Text_IO;
--with Aerodynamics;
with Aerodynamics;
with Aircraft;
with Dynamics;
package body Simulation_Loop is
   
   task body Simulation_Loop is
      Next_Time : Time := Clock;
      F : Aerodynamics.Aero_Forces;
      A : Dynamics.Acceleration;
      S : Aircraft.Aircraft_State;
   begin
      loop
         S := Aircraft.Aircraft.Get_State;
 --        Put_Line ("Alt : " & Float'Image (S.Position));
         Simulation_Cycles_Current := Simulation_Cycles_Current + 1;
 --        Put_Line ("Simulation Started");
         exit when Simulation_Cycles_Current = Simulation_Cycles_Finish;
         --  call the functions.
         Environment.Env.Environment_Cyclic;
         PID_Control.PID_Step (S, Period);
         
         F := Aerodynamics.Compute_Forces (S);
         A := Dynamics.Compute_Accelerations (S, F);
         Integration.Integrate (S, A, Period);
         
         Aircraft.Aircraft.Set_State (S);

--         PID_Control.PID_Step (S, Period);
         Logger.Log_Data;
         Display.Render_Frame (Period);
         --  Schedule the next activation
         Next_Time := Next_Time + Milliseconds(Period);
         delay until Next_Time;
      end loop;
      
   end Simulation_Loop;
end Simulation_Loop;
