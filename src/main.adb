------------------------------------------------------------
--  main.adb
--  Procedure: Main
--  Purpose:

--    elaborating this unit triggers the creation and activation
--    of the Simulation_Loop task. Once instantiated, the task
--    runs autonomously using its internal periodic scheduling
--    (delay until pattern).
--    Main does not contain a control loop. The entire simulation
--    is driven by periodic task that execute independently:
--      - environment update
--      - aerodynamics and dynamics computation
--      - control (PID)
--      - integration
--      - logging and display
--    Instantiating the Simulation_Loop task is sufficient to
--    start the whole simulation pipeline.
--  Notes:
--    - Task_Cycle_Time defines the simulation step in ms.
--    - The discriminant 'Period' configures the task instance.
--    - After elaboration, Main has no further responsibilities.
--  Author : Ovi
------------------------------------------------------------
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time;
with Simulation_Loop;
with Integration;
procedure Main is
   --  Simulation cycle time for the main loop (Simulation_Loop)
   Task_Cycle_Time : constant Natural := 100;  --  [ms]
   --  Instantiation of the Simulation_Loop task type.
   --  Passing the discriminant 'Period' configures the task's
   --  internal timing interval.
   Sim : Simulation_Loop.Simulation_Loop (Period => Task_Cycle_Time);
begin
  ---------------------------------------------------------
   --  Elaboration Phase
   --  When Main is elaborated:
   --    * The Simulation_Loop task is created.
   --    * Its task body begins execution immediately.
   --  No explicit loop is required here. The simulation is
   --  entirely task driven and runs autonomously once the
   --  task instance has been created.
  ---------------------------------------------------------
   Put_Line ("Project started");
   --  nothing else required. project is now running
   null;
end Main;
