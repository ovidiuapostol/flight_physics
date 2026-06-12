------------------------------------------------------------
--  scheduler.ads
--  Package: Scheduler
--  Purpose: Defines periodic cyclic tasks for the flight
--           simulation system:
--             * Environment update
--             * Physics integration
--             * PID control loop
--             * Data logging
--             * ASCII visualization
--  Author : Ovi
------------------------------------------------------------
with Ada.Real_Time;
with Generic_Cyclic_Task;
with Environment;
with Logger;
with Display;
with Physics;
with PID_Control;
package Scheduler is

   Task_Recurence_100ms      : constant Natural := 100;
   --  The integrator task period MUST match Physics.Time_Step.
   --  The physics update uses DT as a discrete time step, and
   --  any mismatch between this period and DT will lead to
   --  incorrect integration and non-physical behavior.
   Task_Recurence_Integrator : constant Natural := Physics.Time_Step;

   package Environment_Cyclic_Task is new Generic_Cyclic_Task
     (Job => Environment.Env.Environment_Cyclic,
      Period => Ada.Real_Time.Milliseconds (Task_Recurence_100ms));

   package Physics_Cyclic_Task is new Generic_Cyclic_Task
     (Job => Physics.Aircraft.Integrator,
      Period => Ada.Real_Time.Milliseconds (Task_Recurence_Integrator));

   package PID_Control_Cyclic_Task is new Generic_Cyclic_Task
     (Job => PID_Control.PID_Step,
      Period => Ada.Real_Time.Milliseconds (Task_Recurence_100ms));

   package Logger_Cyclic_Task is new Generic_Cyclic_Task
     (Job => Logger.Log_Data,
      Period => Ada.Real_Time.Milliseconds (Task_Recurence_100ms));

   package Display_Cyclic_Task is new Generic_Cyclic_Task
     (Job => Display.Render_Frame,
      Period => Ada.Real_Time.Milliseconds (Task_Recurence_100ms));
end Scheduler;
