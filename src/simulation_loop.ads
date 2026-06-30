-----------------------------------------------------------------------
--  Simulation_Loop.ads
--  Package: Simulation_Loop
--  Purpose: Replace the previous generic_yclic_task for
--           performing the simulation. It implements a cyclic task that
--           call in a sequence the simulation steps:
--             - aerodynamics
--             - dynamics
--             - integrator
--             - PID
--             - loging and display
--  Author : Ovi
-----------------------------------------------------------------------
with Ada.Real_Time; use Ada.Real_Time;
with Integration;
with Environment;
with PID_Control;
with Logger;
with Display;
package Simulation_Loop is
   --  Total number of simuation cycles
   Simulation_Cycles_Finish : constant Natural := 605;
   Simulation_Cycles_Current : Natural := 0;
   
   task type Simulation_Loop (Period : Natural);

end Simulation_Loop;
