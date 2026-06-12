------------------------------------------------------------
--  pid_control.adb
--  Package: PID_Control
--  Purpose: Implements a PID control step for the vertical
--           flight system. Computes throttle based on
--           position error, velocity (damping), and
--           integral action.
--  Author : Ovi
------------------------------------------------------------
with Physics;
package body PID_Control is

   --  PID gains (tuned empirically)
   Kp : constant Float := 0.00216;  --  proportional gain
   Ki : constant Float := 0.000075; --  integral gain
   Kd : constant Float := 0.0065;   --  derivative gain (velocity damping)
   --  Integral term (acumulated error)
   Integral   : Float := 0.0;
   Target : constant Float := 1000.0; --  target altitude [m]

   ---------------------------------------------------------
   --  PID_Step
   --   Performs one control iteration:
   --   - Computes position error
   --   - Applies PID control law
   --   - Handles saturation and anti-windup
   --   - Updates aircraft throttle
   ---------------------------------------------------------
   procedure PID_Step is
      S_Local        : Physics.Aircraft_State;
      Error          : Float;
      Throttle       : Float;
      Unsat_Throttle : Float;
   begin
      --  Read current State (feedback)
      S_Local := Physics.Aircraft.Get_State;
      --  Compute controll Error
      Error := Target - S_Local.Position;
      --  Compute unsaturated Throttle
      Unsat_Throttle := Kp * Error + Ki * Integral - Kd * S_Local.Velocity;
      --  PI
      --  Anti-windup (add integrall only if not saturated)
      if not (((Unsat_Throttle > 1.0) and (Error > 0.0)) or
                ((Unsat_Throttle < 0.0) and (Error < 0.0))) then
         Integral := Integral + Error * Physics.DT;
      end if;
      --  Clamp integral term
      if Integral >= 5000.0 then
         Integral := 5000.0;
      elsif Integral <= -5000.0 then
         Integral := -5000.0;
      end if;
      --  Derivative: Velocity is allready the derivative of possition
      Throttle := Kp * Error + Ki * Integral - Kd * S_Local.Velocity;
      ------------------------------------------------------
      --  Actuator saturation (throttle limits)
      ------------------------------------------------------
      if Throttle > 1.0 then
         Throttle := 1.0;
      elsif Throttle < 0.0 then
         Throttle := 0.0;
      end if;
      --  Apply control
      S_Local.Throttle := Throttle;
      Physics.Aircraft.Set_State (S_Local);

   end PID_Step;
end PID_Control;
