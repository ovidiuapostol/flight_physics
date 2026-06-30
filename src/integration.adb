------------------------------------------------------------
--  Integration.adb
--  Package: Integration
--  Purpose:
--    Implements the numerical state-propagation step for the
--    aircraft simulation. This procedure integrates both
--    linear and angular accelerations over a fixed time step
--    and updates the Aircraft_State accordingly.
--    The integration model covers:
--      * Angular motion: pitch rate and pitch angle
--      * Linear vertical motion: velocity and altitude
--    No aerodynamic or dynamic forces are computed here.
--    Those are provided by Aerodynamics and Dynamics.
--  Notes:
--    - Time_Step_ms is given in milliseconds and converted
--      to seconds using Utils.Ms_To_Sec.
--    - Pitch angle is clamped to a safe range to prevent
--      unrealistic simulation divergence.
--    - The environment module is updated with the new
--      velocity after integration.
--  Author : Ovi
------------------------------------------------------------
with Ada.Text_IO; use Ada.Text_IO;
with Environment;
with Utils;
with Aircraft; use Aircraft;
with Dynamics;
package body Integration is
   ---------------------------------------------------------
   --  Integrate
   --  Performs one numerical integration step on the aircraft
   --  state. The procedure:
   --    1. Converts the time step to seconds.
   --    2. Integrates pitch rate using angular acceleration.
   --    3. Integrates pitch angle using the updated pitch rate.
   --    4. Clamps pitch angle to a safe range.
   --    5. Integrates velocity using linear accel.
   --    6. Integrates position using updated velocity.
   --    7. Updates the environment with the new velocity.
   --  Parameters:
   --    S            : in out Aircraft_State
   --                   Current aircraft state, updated in place.
   --    A            : in Dynamics.Acceleration
   --                   Contains angular acceleration (Q_Dot)
   --                   and vertical acceleration (Az).
   --    Time_Step_ms : in Natural
   --                   Integration time step in milliseconds.
   ---------------------------------------------------------
   procedure Integrate (S: in out Aircraft_State; A : Dynamics.Acceleration; Time_Step_ms : Natural) is
      S_Local   : Aircraft_State;
      DT : constant Float   := Float (Time_Step_ms) * Utils.Ms_To_Sec; --  [s]
   begin
      ---------------------------------------------------------
      -- 1. Integrate angular motion
      ---------------------------------------------------------
      -- pitch rate
      S.Pitch_Rate := S.Pitch_Rate + A.Q_Dot * DT;
      -- pitch angle
      S.Pitch_Angle := S.Pitch_Angle + S.Pitch_Rate * DT;

      ---------------------------------------------
      -- Clamp pitch angle (safety)
      ---------------------------------------------
      S.Pitch_Angle := Utils.Clamp (S.Pitch_Angle, -5.0, 15.0);

      ---------------------------------------------------------
      -- 2. Integrate linear motion
      ---------------------------------------------------------

      -- vertical velocity
      S.Velocity_Z := S.Velocity_Z + A.Az * DT;
      -- vertical position (altitude)
      S.Position_Z := S.Position_Z + S.Velocity_Z * DT;
      -- horizontal velocity
      S.Velocity_X := S.Velocity_X + A.Ax * DT;
      -- horizontal position
      S.Position_X := S.Position_X + S.Velocity_X * DT;
      ---------------------------------------------------------
      -- Update environment
      ---------------------------------------------------------
     -- Environment.Env.Set_Speed (S.Velocity);

      end Integrate;

end Integration;
