------------------------------------------------------------
--  aerodynamics.ads
--
--  Package: Aerodynamics
--
--  Purpose:
--     Provides the aerodynamic force model used by the
--     aerodynamic forces based on the current aircraft state
--     and atmospheric conditions. No accelerations or motion
--     integration are performed here.
--
--     The aerodynamic model includes:
--
--        * Drag
--           Simplified Cd * q * Sref formulation.
--           Direction opposite to velocity.
--
--        * Lift
--           Based on angle of attack using:
--             CL = CL_0 + CL_Alpha * Alpha
--           Direction perpendicular to velocity.
--
--        * Velocity damping
--           Linear aerodynamic damping proportional to speed
--           and opposite to the velocity direction.
--
--        * Thrust resolution
--           Thrust is resolved into Fx and Fz using the
--           aircraft pitch angle.
--
--     The resulting forces (Fx, Fz) are passed to the
--     Dynamics module, which computes accelerations and
--     integrates the aircraft state.
--
--  Notes:
--     - Uses simplified linear aerodynamic coefficients.
--     - K_Vel_Damp controls the strength of velocity damping.
--     - This module is intentionally lightweight and does not
--       modell stall, CLmax, induced drag or full 3D aerodynamics
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
      Fx          : Float;   -- horizontal force
      Fz          : Float;   -- vertical force (total)
   end record;
   
   ---------------------------------------------------------
   --  Model Parameters
   --  K_Vel_Damp :
   --     Linear aerodynamic damping coefficient. Produces a
   --     stabilizing force proportional to speed and opposite
   --     to the velocity direction.
   ---------------------------------------------------------   
   
   K_Vel_Damp   : constant Float := 0.07; 
   ---------------------------------------------------------
   --  Compute_Forces
   --  Input:
   --     S : Aircraft_State
   --  Output:
   --     Aero_Forces record containing Drag, Lift_Pitch,
   --     and Vel_Damping.
   --  Description:
   --     Computes aerodynamic forces based on the current
   --     aircraft state and environment.
   ---------------------------------------------------------   
   function Compute_Forces (S: Aircraft.Aircraft_State) return Aero_Forces;

end Aerodynamics;
