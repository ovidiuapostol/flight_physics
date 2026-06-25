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
package body Simulation_Loop is
   
   task body Simulation_Loop is
      Next_Time : Time := Clock;
   begin
      loop
         Put_Line ("Simulation Started");
         exit when Physics.Aircraft.Should_Stop;
         --  call the functions.
         Environment.Env.Environment_Cyclic;
         Physics.Aircraft.Integrator;

         PID_Control.PID_Step;
         Logger.Log_Data;
         Display.Render_Frame;
         --  Schedule the next activation
         Next_Time := Next_Time + Milliseconds(Period);
         delay until Next_Time;
      end loop;
      
   end Simulation_Loop;
end Simulation_Loop;
