--  aerodynamics.adb
--  Package: Aerodynamics
--  Purpose:
--     Implements the aerodynamic force model used by the
--     flight physics simulation. This module computes ONLY
--     aerodynamic forces based on the current aircraft state
--     and environment:
--
--       - Drag (simplified Cd * q * Sref model)
--       - Lift contribution from pitch angle (CL_alpha approx.)
--       - Velocity dependent aerodynamic damping
--
--     No accelerations or state integration are performed here.
--     The output forces are consumed by the Dynamics module
--  Notes:
--     - Uses simplified linear aerodynamic coefficients.
--     - Produces identical results to the previous monolithic
--       integrator, but now cleanly separated.
--     - Environment.Env.Rho provides air density.
--
--  Author : Ovi
------------------------------------------------------------
with Environment;
with Aircraft;
package body Aerodynamics is
   ---------------------------------------------------------
   --  Compute_Forces
   --  Input:
   --     S : Aircraft_State
   --  Output:
   --     Aero_Forces record containing:
   --       Drag        : aerodynamic drag force [N]
   --       Lift_Pitch  : lift contribution from pitch angle [N]
   --       Vel_Damping : aerodynamic velocity damping [N]
   --
   --  Description:
   --     Computes aerodynamic forces using simplified linear
   --     relationships. Drag is computed from dynamic pressure,
   --     while Lift_Pitch and Vel_Damping use constant gains.
   ---------------------------------------------------------
   function Compute_Forces (S : Aircraft.Aircraft_State) return Aero_Forces is
      F : Aero_Forces := (0.0, 0.0, 0.0);
      --  Aircraft parameters
      Cd : constant Float := Aircraft.Cd;
      Sref : constant Float := Aircraft.Sref;
      --  Environment
      Rho : constant Float := Environment.Env.Rho;
   begin
     ---------------------------------------------
     -- Forces
     ---------------------------------------------
  
     F.Drag := 0.5 * Rho * S.Velocity * S.Velocity * Cd * Sref;
      -----------------------------------------------------
      -- Lift contribution from pitch angle
      --   Simplified CL_alpha * alpha model
      -----------------------------------------------------      
      F.Lift_Pitch := K_Lift_Pitch * S.Pitch_Angle;
      -----------------------------------------------------
      -- Velocity dependent aerodynamic damping
      --   Linear approximation: -k * V
      -----------------------------------------------------      
      F.Vel_Damping := -K_Vel_Damp * S.Velocity;
      
      return F;
   end Compute_Forces;
   

end Aerodynamics;
