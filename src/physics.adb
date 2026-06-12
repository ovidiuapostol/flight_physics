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

      ------------------------------------------------------
      --  Integrator
      --   Advances simulation by one time step DT:
      --   - Computes forces (thrust, drag, gravity)
      --   - Updates velocity and position
      ------------------------------------------------------
      procedure Integrator is
         S_Local   : Aircraft_State;
         Rho       : Float;                  --  air density
         G         : constant Float := 9.81; --  gravity [m/s/s]
      begin
         --  Read current state
         S_Local  := Get_State;
         --  Get environment data (air density)
         Rho      := Environment.Env.Rho;
         --  Update runtime counter
         Run_Time := Run_Time + 1;
         declare
            --  Aircraft parameters
            T_Max : constant Float := Plane_Characteristics.T_Max;
            Mass  : constant Float := Plane_Characteristics.Mass;
            Cd    : constant Float := Plane_Characteristics.Cd;
            Sref  : constant Float := Plane_Characteristics.Sref;
            --  Forces
            Thrust : constant Float := S_Local.Throttle * T_Max;
            Drag   : constant Float := 0.5 * Rho * S_Local.Velocity *
              S_Local.Velocity * Cd * Sref;
            --  acceleration
            A : constant Float := (Thrust - Drag) / Mass - G;
         begin
            --  Integrate for velocity and position
            S_Local.Velocity := S_Local.Velocity + A * DT;
            S_Local.Position := S_Local.Position + S_Local.Velocity * DT;
         end;

         --  Write updated state
         Set_State (S_Local);
         --  Update environment (optional coupling)
         Environment.Env.Set_Speed (S_Local.Velocity);
         --  Stop condition (simulation time limit)
         if Run_Time >= 1000 then
            Stop_Flag := True;
         end if;

      end Integrator;
   end Aircraft;

end Physics;
