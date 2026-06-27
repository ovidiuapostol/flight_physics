------------------------------------------------------------
--  integration.adb
--  Package: Integration
--  Purpose: Integrates the accelerations respectivelly velociies
--           to get the position. This apply to both:
--            - linear
--            - angular values
--  Author : Ovi
------------------------------------------------------------
with Ada.Text_IO; use Ada.Text_IO;
with Environment;
with Plane_Characteristics;
with Utils;
with Aircraft; use Aircraft;
with Dynamics;
package body Integration is

      ------------------------------------------------------
      --  Integrator
      --   Advances simulation by one time step DT:
      --   - Computes forces (thrust, drag, gravity)
      --   - Updates velocity and position
      ------------------------------------------------------
   procedure Integrate (S: in out Aircraft_State; A : Dynamics.Acceleration; Time_Step_ms : Natural) is

         S_Local   : Aircraft_State;
 --        Rho       : Float;                  -- air density
--         G         : constant Float := 9.81; -- gravity [m/s²]

         -- New pitch model constants
--         K_Elevator   : constant Float := 20.0; -- elevator effectiveness (Cm_delta_e)
--         D_Pitch      : constant Float := 5.0;  -- pitch damping (Cmq)
--         K_Lift_Pitch : constant Float := 0.02; -- lift from pitch (CL_alpha)
--         K_Vel_Damp   : constant Float := 0.07;

         DT : constant Float   := Float (Time_Step_ms) * Utils.Ms_To_Sec; --  [s]
      begin
         ---------------------------------------------------------
         -- Read current state
         ---------------------------------------------------------
 --        S_Local  := Aircraft.Aircraft.Get_State;

         -- Get environment data
 --        Rho := Environment.Env.Rho;

         ---------------------------------------------------------
         -- Internal computation block
         ---------------------------------------------------------
         declare
            -- Aircraft parameters
--            T_Max : constant Float := Aircraft.T_Max;
--            Mass  : constant Float := Aircraft.Mass;
--            Cd    : constant Float := Aircraft.Cd;
--            Sref  : constant Float := Aircraft.Sref;

            -- Forces
--            Thrust : Float;
--            Drag   : Float;

            -- Pitch dynamics
--            Pitch_Accel : Float;

            -- Vertical acceleration
 --           A : Float;
         begin
            ---------------------------------------------
            -- Forces
            ---------------------------------------------
            --  Thrust := S_Local.Throttle * T_Max;
            --
            --  Drag :=
            --    0.5 * Rho *
            --    S_Local.Velocity * S_Local.Velocity *
            --    Cd * Sref;
            --
            --  ---------------------------------------------
            --  -- Pitch dynamics
            --  ---------------------------------------------
            --  Pitch_Accel :=
            --    K_Elevator * S_Local.Elevator
            --    - D_Pitch * S_Local.Pitch_Rate;

         -- Integrate pitch rate
         S_Local := S;
            S_Local.Pitch_Rate :=
              S_Local.Pitch_Rate + A.Q_Dot * DT;

            -- Integrate pitch angle
            S_Local.Pitch_Angle :=
              S_Local.Pitch_Angle + S_Local.Pitch_Rate * DT;

            ---------------------------------------------
            -- Clamp pitch angle (safety)
            ---------------------------------------------
            S_Local.Pitch_Angle := Utils.Clamp (S_Local.Pitch_Angle, -20.0, 20.0);

            ---------------------------------------------
            -- Vertical dynamics (pitch influences climb)
            ---------------------------------------------
            --  A :=
            --    (Thrust - Drag) / Mass
            --    + K_Lift_Pitch * S_Local.Pitch_Angle
            --    - G - K_Vel_Damp * S_Local.Velocity;

            ---------------------------------------------
            -- Integrate motion
            ---------------------------------------------
            S_Local.Velocity :=
              S_Local.Velocity + A.Az * DT;

            S_Local.Position :=
           S_Local.Position + S_Local.Velocity * DT;

         end;

         ---------------------------------------------------------
         -- Write updated state
         ---------------------------------------------------------
        -- Aircraft.Aircraft.Set_State (S_Local);
         S := S_Local;
         ---------------------------------------------------------
         -- Update environment
         ---------------------------------------------------------
         Environment.Env.Set_Speed (S_Local.Velocity);

         ---------------------------------------------------------
         -- Stop condition
         ---------------------------------------------------------
--         if Run_Time >= Simulation_Run_Time then
--            Stop_Flag := True;
--         end if;

      end Integrate;
--   end Aircraft;

end Integration;
