------------------------------------------------------------
--  physics.ads
--  Package: Physics
--  Purpose: Defines aircraft state and vertical motion model.
--           Provides a protected object to safely read and
--           update simulation state during execution.
--           Uses Environment for atmospheric parameters
--           (currently air density for drag computation).
--           Designed to allow future extensions such as
--           wind or altitude-dependent models.
--  Author : Ovi
------------------------------------------------------------
with Environment;
with Plane_Characteristics;
with Utils;
package body Physics is

   ---------------------------------------------------------
   --  Aircraft (Protected Body)
   --   Encapsulates shared simulation state and updates
   ---------------------------------------------------------
   protected body Aircraft is

      --   Update full aircraft state
      procedure Set_State (New_State : Aircraft_State) is
      begin
         S := New_State;
      end Set_State;

      --   Return current aircraft state
      function Get_State return Aircraft_State is
      begin
         return S;
      end Get_State;

      --   Check if simulation should terminate
      function Should_Stop return Boolean is
      begin
         return Stop_Flag;
      end Should_Stop;

      --  Return the ellapsed run time
      function Get_Run_Time return Integer is
      begin
         return Run_Time;
      end Get_Run_Time;


      ------------------------------------------------------
      --  Integrator
      --   Advances simulation by one time step DT:
      --   - Computes forces (thrust, drag, gravity)
      --   - Updates velocity and position
      ------------------------------------------------------
      procedure Integrator is
         S_Local   : Aircraft_State;
         Rho       : Float;                  -- air density
         G         : constant Float := 9.81; -- gravity [m/s²]

         -- New pitch model constants
         K_Elevator   : constant Float := 20.0; -- elevator effectiveness (Cm_delta_e)
         D_Pitch      : constant Float := 5.0;  -- pitch damping (Cmq)
         K_Lift_Pitch : constant Float := 0.02; -- lift from pitch (CL_alpha)
         K_Vel_Damp   : constant Float := 0.07;
      begin
         ---------------------------------------------------------
         -- Read current state
         ---------------------------------------------------------
         S_Local  := Get_State;

         -- Get environment data
         Rho := Environment.Env.Rho;

         -- Update runtime
         Run_Time := Run_Time + 1;

         ---------------------------------------------------------
         -- Internal computation block
         ---------------------------------------------------------
         declare
            -- Aircraft parameters
            T_Max : constant Float := Plane_Characteristics.T_Max;
            Mass  : constant Float := Plane_Characteristics.Mass;
            Cd    : constant Float := Plane_Characteristics.Cd;
            Sref  : constant Float := Plane_Characteristics.Sref;

            -- Forces
            Thrust : Float;
            Drag   : Float;

            -- Pitch dynamics
            Pitch_Accel : Float;

            -- Vertical acceleration
            A : Float;
         begin
            ---------------------------------------------
            -- Forces
            ---------------------------------------------
            Thrust := S_Local.Throttle * T_Max;

            Drag :=
              0.5 * Rho *
              S_Local.Velocity * S_Local.Velocity *
              Cd * Sref;

            ---------------------------------------------
            -- Pitch dynamics
            ---------------------------------------------
            Pitch_Accel :=
              K_Elevator * S_Local.Elevator
              - D_Pitch * S_Local.Pitch_Rate;

            -- Integrate pitch rate
            S_Local.Pitch_Rate :=
              S_Local.Pitch_Rate + Pitch_Accel * DT;

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
            A :=
              (Thrust - Drag) / Mass
              + K_Lift_Pitch * S_Local.Pitch_Angle
              - G - K_Vel_Damp * S_Local.Velocity;

            ---------------------------------------------
            -- Integrate motion
            ---------------------------------------------
            S_Local.Velocity :=
              S_Local.Velocity + A * DT;

            S_Local.Position :=
              S_Local.Position + S_Local.Velocity * DT;
         end;

         ---------------------------------------------------------
         -- Write updated state
         ---------------------------------------------------------
         Set_State (S_Local);

         ---------------------------------------------------------
         -- Update environment
         ---------------------------------------------------------
         Environment.Env.Set_Speed (S_Local.Velocity);

         ---------------------------------------------------------
         -- Stop condition
         ---------------------------------------------------------
         if Run_Time >= Simulation_Run_Time then
            Stop_Flag := True;
         end if;

      end Integrator;
   end Aircraft;

end Physics;
