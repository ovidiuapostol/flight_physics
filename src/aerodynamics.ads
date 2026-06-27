------------------------------------------------------------
--  aerodynamics.ads
--
--  Package: Aerodynamics
--
--  Purpose:
--     Computes all aerodynamic forces acting on the aircraft.
--     This module is responsible ONLY for aerodynamic effects:
--
--
--  Aero_Forces
--   Output of the aerodynamic model.
--   These forces are passed to Dynamics.
--     
--       - Drag (simplified Cd * q * Sref model)
--       - Lift contribution from pitch angle (CL_alpha aproximation)
--       - Velocity dependent aeorodynamic damping
--
--     It does NOT compute accelerations or integrate motion.
--     It simply returns aerodynamic forces, which are then
--     consumed by the Dynamics module.
--
--  Notes:
--     - Uses simplified linear aerodynamic models.
--     - Constants K_Lift_Pitch and K_Vel_Damp are model parameters.
--     - Produces identical results to the previous monolithic
--       integrator, but now cleanly separated.
--
--  Author : Ovi
------------------------------------------------------------
with Aircraft;
package Aerodynamics is
   ---------------------------------------------------------
   --  Aero_Forces
   --   Output of the aerodynamic model.
   --   These forces are passed to Dynamics.
   ---------------------------------------------------------
   
   type Aero_Forces is record
      Drag        : Float;   -- aerodynamic drag force [N]
      Lift_Pitch  : Float;   -- lift contribution from pitch angle [N]
      Vel_Damping : Float;   -- aerodynamic velocity damping [N]
   end record;
   
   K_Lift_Pitch : constant Float := 0.02; -- lift from pitch (CL_alpha)
   K_Vel_Damp   : constant Float := 0.07; -- velocity damping term
   ---------------------------------------------------------
   --  Compute_Forces
   --
   --  Input:
   --     S : Aircraft_State
   --
   --  Output:
   --     Aero_Forces record containing Drag, Lift_Pitch,
   --     and Vel_Damping.
   --
   --  Description:
   --     Computes aerodynamic forces based on the current
   --     aircraft state and environment.
   ---------------------------------------------------------   
   function Compute_Forces (S: Aircraft.Aircraft_State) return Aero_Forces;

end Aerodynamics;
