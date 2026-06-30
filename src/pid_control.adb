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
   Kp_Throttle : constant Float := 0.00002;    -- proportional (altitude error)
   Ki_Throttle : constant Float := 0.0000002;  -- integral (accumulated error)
   Kd_Throttle : constant Float := 0.006;      -- velocity damping (energy rate)

   Throttle_Trim : constant Float := 0.512;   -- equilibrium (nominal cruise) throttle
   Kp_Alt   : constant Float := 0.012; --  proportional gain for outer loop [deg/m]

   Kp_Pitch : constant Float := 0.08;  -- proportional gain for the inner loop
   Kd_Pitch : constant Float := 0.05;  -- derivative gain for the inner loop

   --  Integral term (acumulated error)
   Integral   : Float := 0.0;          --  used by Throttle
   Target : constant Float := 1000.0;  --  target altitude [m]

   ------------------------------------------------------------
   --  PID_Step
   --
   --  Performs one control iteration for the longitudinal
   --  flight controller. The logic is phase-dependent:
   --
   --    PHASE 1: GROUND_ROLL
   --       - Pitch demand fixed at +1°
   --       - Elevator tracks this pitch demand
   --       - Throttle commanded to maximum
   --
   --    PHASE 2: ROTATION
   --       - Pitch demand fixed at +10°
   --       - Elevator tracks pitch demand
   --       - Throttle remains maximum
   --
   --    PHASE 3: CLIMB
   --       - Altitude outer loop computes desired pitch
   --       - Pitch inner loop tracks desired pitch
   --       - Throttle PI loop regulates total energy
   --       - Vertical velocity provides damping
   --
   --  All phases use:
   --       - Pitch PD control
   --       - Elevator saturation
   --       - Throttle saturation
   --
   --  This controller approximates a simplified autopilot
   --  for takeoff and climb.
   ------------------------------------------------------------
   procedure PID_Step (S : in out Aircraft.Aircraft_State; Period : Natural) is
      Throttle        : Float;   --  command: increase/decrease engine output
      Alt_Error       : Float;   --  altitude error
      Pitch_Error     : Float;   --  difference between desired Pitch and real pitch
      Desired_Pitch   : Float;   --  computed by the outer control loop
      Elevator        : Float;   --  command: increase/decr5ease pitch

      DT              : Float := Float (Period) * Utils.Ms_To_Sec;
   begin
      -------------------------------------------------------------------------
      --   Phase determination
      ------------------------------------------------------------------------
      if S.Velocity_X < Aircraft.Vr then
         S.Phase := Aircraft.Ground_Roll;
      elsif S.Position_Z < 5.0 then
         S.Phase := Aircraft.Rotation;
      else
         S.Phase := Aircraft.Climb;
      end if;
      -----------------------------------------------------------
      --   Phase dependent control Logic
      -----------------------------------------------------------
      case S.Phase is
         when Aircraft.Ground_Roll =>
            Desired_Pitch := 1.0;
            Pitch_Error := Desired_Pitch - S.Pitch_Angle;

            Elevator := Kp_Pitch * Pitch_Error - Kd_Pitch * S.Pitch_Rate;
            Elevator := Utils.Clamp (Elevator, -1.0, 1.0);
            Throttle := 1.0;    --  Full Thrust
         when Aircraft.Rotation =>
            Desired_Pitch := 10.0;
            Pitch_Error := Desired_Pitch - S.Pitch_Angle;
            Elevator := Kp_Pitch * Pitch_Error - Kd_Pitch * S.Pitch_Rate;
            Elevator := Utils.Clamp (Elevator, -1.0, 1.0);
            Throttle := 1.0;    --  Full Thrust
         when Aircraft.Climb =>
            --------------------------------------------------
            --  Outer loop - Altitude error -> desired pitch
            --------------------------------------------------
            Alt_Error := Target - S.Position_Z;

            --------- Anti Wind-up --------------
            if abs (Alt_Error) < 300.0 then
               Integral := Integral + Alt_Error * DT;
            end if;

            --  clamp it
            Integral := Utils.Clamp (Integral, -1000.0, 1000.0);

            Desired_Pitch := Kp_Alt * Alt_Error;
            --      clamp desired pitch
            Desired_Pitch := Utils.Clamp (Desired_Pitch, -5.0, 15.0);

            --------------------------------------------------
            --  Inner loop - Pitch error -> Elevator
            --------------------------------------------------
            Pitch_Error := Desired_Pitch - S.Pitch_Angle;
            Elevator := Kp_Pitch * Pitch_Error - Kd_Pitch * S.Pitch_Rate;
            --  clamp elevator
            Elevator := Utils.Clamp (Elevator, -1.0, 1.0);

            Throttle := Throttle_Trim + Kp_Throttle * Alt_Error + Ki_Throttle * Integral - Kd_Throttle * S.Velocity_Z;
            Throttle := Utils.Clamp (Throttle, 0.0, 1.0);
      end case;

      --  Apply control
      S.Desired_Pitch := Desired_Pitch;
      S.Elevator := Elevator;
      S.Throttle := Throttle;
   end PID_Step;
end PID_Control;
