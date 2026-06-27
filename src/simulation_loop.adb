-----------------------------------------------------------------------
--  Simulation_Loop.adb
--  Package: Simulation_Loop
--  Purpose:

--    aircraft model. This task replaces the previous
--    Generic_Cyclic_Task abstraction and provides a dedicated,
--    deterministic execution loop that performs one complete
--    simulation step per cycle.
--    Each cycle executes the following sequence:
--      1. Environment update
--      2. PID control computation
--      3. Aerodynamic force calculation
--      4. Dynamic acceleration computation
--      5. State integration
--      6. Logging and display
--    The task runs periodically using a delay-until pattern,
--    ensuring stable and predictable timing behavior.
--  Notes:
--    - The discriminant 'Period' defines the cycle time in ms.
--    - Simulation_Cycles_Current and Simulation_Cycles_Finish
--      control the stop condition.
--    - The Aircraft_State is read and written through the
--      Aircraft package to ensure consistent access.
--  Author : Ovi
-----------------------------------------------------------------------
with Ada.Text_IO; use Ada.Text_IO;
with Aerodynamics;
with Aircraft;
with Dynamics;
package body Simulation_Loop is
   
   task body Simulation_Loop is
      --  Next scheduled activation time for the periodic loop.      
      Next_Time : Time := Clock;
      --  Temporary values for forces, accelerations, and state.      
      F : Aerodynamics.Aero_Forces;
      A : Dynamics.Acceleration;
      S : Aircraft.Aircraft_State;
   begin
      loop
        ------------------------------------------------------------
         --  Stop Condition
         --  The simulation runs for a fixed number of cycles.
         --  Once the counter reaches Simulation_Cycles_Finish,
         --  the task exits the loop and terminates.
         ------------------------------------------------------------
         Simulation_Cycles_Current := Simulation_Cycles_Current + 1;
         exit when Simulation_Cycles_Current = Simulation_Cycles_Finish;
         
         --  get current aircraft state
         S := Aircraft.Aircraft.Get_State; 
         
         --  update the environment data (for time being is aier density at see level)
         Environment.Env.Environment_Cyclic;
         
         --  apply controll laws (PID) for the current state
         --    Computes elevator and throttle commands based on
         --    altitude, pitch, pitch rate and velocity
         PID_Control.PID_Step (S, Period);
         
         --  compute aerodynamic forces 
         F := Aerodynamics.Compute_Forces (S);
         
         --  compute dynamic accelerations
         --     converts erodynamic forces int linear and angular
         --     accelerations using aircraft mass and inertia
         A := Dynamics.Compute_Accelerations (S, F);
         
         --   integrate accelerations
         Integration.Integrate (S, A, Period);
         
         --  write updated state back to the global model
         Aircraft.Aircraft.Set_State (S);

         --  log and display data
         Logger.Log_Data;
         Display.Render_Frame (Period);
         
         --  Schedule the next activation
         Next_Time := Next_Time + Milliseconds(Period);
         delay until Next_Time;
      end loop;
      
   end Simulation_Loop;
end Simulation_Loop;
