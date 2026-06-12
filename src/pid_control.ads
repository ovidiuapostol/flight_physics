------------------------------------------------------------
--  pid_control.ads
--  Package: PID_Control
--  Purpose: Implements a PID control step for the vertical
--           flight system. Computes throttle input based on
--           position error, velocity (damping), and integral
--           action.
--  Author : Ovi
------------------------------------------------------------
package PID_Control is

   --  Perform one PID control step
   --  Called cyclic by the scheduler
   procedure PID_Step;

end PID_Control;
