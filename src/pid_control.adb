------------------------------------------------------------
--  pid_control.adb
--
--  Package: PID_Control
--
--  Purpose:
--     Implements a multi-loop control system for vertical
--     flight control of the aircraft.
--
--     The controller is composed of three coordinated
--     feedback loops:
--
--       1. Altitude Control (Outer Loop)
--          - Computes altitude error
--          - Generates a desired pitch command
--
--       2. Pitch Control (Inner Loop)
--          - Uses PD control to track desired pitch
--          - Produces elevator command
--
--       3. Energy / Throttle Control
--          - Uses PI control based on altitude error
--            and accumulated error (integrator)
--          - Includes velocity feedback for damping
--          - Adjusts throttle to regulate total energy
--
--     Features:
--       - Anti-windup mechanism for integrator
--       - Command saturation via clamping
--       - Coupled pitch + energy control
--
--  Author : Ovi
------------------------------------------------------------
--with Physics;
with Utils;
package body PID_Control is
   --------------------------------------------------------------
   --  Altitude controller gains ---
   --  Altitude control loops:
   --    Target Altitude
   --          |
   --    Altitude Controller     ---> outer loop
   --          |
   --      desired pitch         ---> output from the outer loop/input in Pitch controller
   --          |
   --    Pitch controller        ---> inner loop
   --          |
   --       elevator             ---> command that goes to dynamics
   ----------------------------------------------------------------------------

   --  Throttle control gains (energy control loop)
   Kp_Throttle : constant Float := 0.00002;   -- proportional (altitude error) in curent code 0.00003
   Ki_Throttle : constant Float := 0.0000002;  -- integral (accumulated error)
   Kd_Throttle : constant Float := 0.006;--0.003;     -- velocity damping (energy rate)

   Throttle_Trim : constant Float := 0.512;   -- equilibrium throttle
   Kp_Alt   : constant Float := 0.012; --  proportional gain for outer loop [deg/m]

   Kp_Pitch : constant Float := 0.08;  -- proportional gain for the inner loop --old value 0.08
   Kd_Pitch : constant Float := 0.05;  -- derivative gain for the inner loop   -- old = 0.05

   --  Integral term (acumulated error)
   Integral   : Float := 0.0;          --  used by Throttle
   Target : constant Float := 1000.0;  --  target altitude [m]

---------------------------------------------------------
--  PID_Step
--
--  Performs one control iteration for the longitudinal
--  flight controller using a multi-loop structure:
--
--    1. Outer loop (Altitude -> Pitch):
--       - Computes altitude error
--       - Generates desired pitch command
--
--    2. Inner loop (Pitch -> Elevator):
--       - Uses PD control to track desired pitch
--       - Produces elevator command
--
--    3. Energy control (Altitude -> Throttle):
--       - Uses PID control to regulate total energy
--       - Adjusts throttle to remove steady-state error
--       - Includes velocity feedback to limit overshoot
--
--  Features:
--    - Anti-windup for integrator
--    - Command saturation (elevator, pitch, throttle)
--    - Coupled pitch + energy control for stable climb
--
--  This implementation approximates a simplified
--  autopilot-like control system.
---------------------------------------------------------
   procedure PID_Step (S : in out Aircraft.Aircraft_State; Period : Natural) is
      Throttle        : Float;   --  command: increase/decrease engine output
      Alt_Error       : Float;   --  altitude error
      Pitch_Error     : Float;   --  difference between desired Pitch and real pitch
      Desired_Pitch   : Float;   --  computed by the outer control loop
      Elevator        : Float;   --  command: increase/decr5ease pitch

      DT              : Float := Float (Period) * Utils.Ms_To_Sec;
   begin
      --------------------------------------------------
      --  Outer loop - Altitude error -> desired pitch
      --------------------------------------------------
      Alt_Error := Target - S.Position;

      --------- Anti Wind-up --------------
      if abs (Alt_Error) < 300.0 then
         Integral := Integral + Alt_Error * DT;
      end if;

      --  clamp it
      Integral := Utils.Clamp (Integral, -1000.0, 1000.0);

      Desired_Pitch := Kp_Alt * Alt_Error;
      --      clamp desired pitch
      Desired_Pitch := Utils.Clamp (Desired_Pitch, -10.0, 10.0);

      --------------------------------------------------
      --  Inner loop - Pitch error -> Elevator
      --------------------------------------------------
      Pitch_Error := Desired_Pitch - S.Pitch_Angle;
      Elevator := Kp_Pitch * Pitch_Error - Kd_Pitch * S.Pitch_Rate;
      --  clamp elevator
      Elevator := Utils.Clamp (Elevator, -1.0, 1.0);

      Throttle := Throttle_Trim + Kp_Throttle * Alt_Error + Ki_Throttle * Integral - Kd_Throttle * S.Velocity;
      Throttle := Utils.Clamp (Throttle, 0.0, 1.0);

      --  Apply control
      S.Desired_Pitch := Desired_Pitch;
      S.Elevator := Elevator;
      S.Throttle := Throttle;
   end PID_Step;
end PID_Control;
