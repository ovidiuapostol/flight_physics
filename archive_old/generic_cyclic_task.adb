------------------------------------------------------------------------
--  generic_cyclic_task.adb
--  Package: Generic_Cyclic_Task
--  Purpose: Provides a generic periodic task abstraction. Each instance
--           executes a user-supplied Job at a fixed real-time period
--           using delay-until scheduling.
--  Author : Ovi
----------------------------------------------------------------------
with Ada.Real_Time; use Ada.Real_Time;
with Physics;
package body Generic_Cyclic_Task is
   --------------------------------------------------------------------
   --  Task body implementing a periodic real-time loop.
   --  The task:
   --    * waits until the next scheduled activation time
   --    * executes the Job procedure supplied by the instantiator
   --    * updates the next activation time by adding the fixed Period
   --
   --  The loop terminates when the Physics package signals
   --  that the system should stop.
   --------------------------------------------------------------------
   task body Cyclic is
      Next_Time : Time := Clock;
   begin
      loop
         exit when Physics.Aircraft.Should_Stop;
         --  Wait until the next scheduled activation time.
         delay until Next_Time;
         Job;      -- Execute the user defined Job;

         --  Schedule the next activation
         Next_Time := Next_Time + Period;
      end loop;
   end Cyclic;

end Generic_Cyclic_Task;
