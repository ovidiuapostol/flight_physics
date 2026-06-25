------------------------------------------------------------
--  main.adb
--  Procedure: Main
--  Purpose: Entry point of the flight simulation system.
--           Triggers elaboration of cyclic tasks defined in
--           the Scheduler package. After elaboration, all
--           periodic tasks (environment, physics, control,
--           logging, display) run automatically.
--  Author : Ovi
------------------------------------------------------------
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time;
--with Scheduler;
with Simulation_Loop;
with Physics;
procedure Main is
   Task_Recurence_Integrator : constant Natural := Physics.Time_Step;
   Sim : Simulation_Loop.Simulation_Loop (Period => Task_Recurence_Integrator);
begin
   ---------------------------------------------------------
   --  The Scheduler package is WITH'ed to ensure its
   --  elaboration. During elaboration, all cyclic task
   --  instances are created and started automatically.
   --
   --  No explicit loop is needed here because the system
   --  behavior is driven entirely by periodic tasks.
   ---------------------------------------------------------
   Put_Line ("Project started");
   null;
end Main;
