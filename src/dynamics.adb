------------------------------------------------------------
--  dynamics.adb
--  Package: Dynamics
--  Purpose:
--     Implements the aircraft dynamic response model.
--     This module converts aerodynamic forces and control
--     inputs into accelerations:
--       - Q_Dot : pitch angular acceleration
--       - Az    : vertical linear acceleration
--     Dynamics does NOT compute aerodynamic forces and does
--     NOT integrate the aircraft state. It only transforms:
--         (Aircraft_State + Aero_Forces) - Acceleration
--     The resulting accelerations are passed to the Integration module
--  Notes:
--     - Uses simplified stability/control derivatives:
--         K_Elevator - elevator effectiveness (Cm_delta_e)
--         D_Pitch    - pitch - rate damping (Cmq)
--     - Gravity is included as a constant term.
--     - Produces identical behavior to the previous monolithic
--       integrator, but with clean modular separation.
--  Author : Ovi
------------------------------------------------------------
package body Dynamics is
   ---------------------------------------------------------
   -- Physical and dynamic model constants
   ---------------------------------------------------------
   G         : constant Float := 9.81; -- gravity [m/s/s]

   -- pitch simplified dynamic model constants
   K_Elevator   : constant Float := 20.0; -- elevator effectiveness (Cm_delta_e)
   D_Pitch      : constant Float := 5.0;  -- pitch rate damping (Cmq)
    ---------------------------------------------------------
    -- Compute_Accelerations
    --
    -- Input:
    --     S : Aircraft_State
    --     F : Aero_Forces (Drag, Lift_Pitch, Vel_Damping)
    --
    -- Output:
    --     Acceleration record containing:
    --       Q_Dot : pitch angular acceleration
    --       Az    : vertical linear acceleration
    --
    -- Description:
    --     Computes the aircraft's dynamic response based on:
    --       - thrust and mass (from Aircraft)
    --       - aerodynamic forces (from Aerodynamics)
    --       - elevator effectiveness (K_Elevator)
    --       - pitch rate damping (Cmq)
    --
    --     This represents the simplified longitudinal dynamics
    --     model used by the simulation.
    ---------------------------------------------------------
   function Compute_Accelerations (S : Aircraft.Aircraft_State; F : Aerodynamics.Aero_Forces) return Acceleration is
      A : Acceleration;
      --  Aircraft Parameters
      T_Max : constant Float := Aircraft.T_Max;
      Mass  : constant Float := Aircraft.Mass;
      
      --  Forces
      Thrust : Float;
   begin
      
      -- Thrust
      Thrust := S.Throttle * T_Max;
      
      -- Pitch Acceleration
      A.Q_Dot := K_Elevator * S.Elevator - D_Pitch * S.Pitch_Rate;
      
      --  vertical acceleration
      A.Az := (Thrust - F.Drag)/Mass + F.Lift_Pitch + F.Vel_Damping - G;
      
      return A;
   end Compute_Accelerations;
   

end Dynamics;
