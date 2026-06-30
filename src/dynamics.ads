------------------------------------------------------------
--  dynamics.ads
--  Package: Dynamics
--  Purpose:
--     Computes the aircraft's dynamic response to forces and
--     control inputs. This module converts aerodynamic forces
--     and control surface effects into *accelerations*:
--
--       - Q_Dot : pitch angular acceleration
--       - Az    : vertical (linear) acceleration
--
--     Dynamics does NOT compute aerodynamic forces and does
--     NOT integrate the state. It only transforms:
--
--         (Aircraft_State + Aero_Forces) => Accelerations
--
--     The resulting accelerations are passed to the Integration module,
--     which updates the aircraft state over time.
--
--  Notes:
--     - Uses simplified stability/control derivatives:
--         K_Elevator - elevator effectiveness (Cm_delta_e)

--     - Produces identical behavior to the previous monolithic
--       integrator, but with clean modular separation.
--
--  Author : Ovi
------------------------------------------------------------

with Aircraft;
with Aerodynamics;
package Dynamics is
   ---------------------------------------------------------
   --  Acceleration
   --
   --  Output of the Dynamics module.
   --  Contains the linear and angular accelerations that
   --  will be integrated by the Integration module.
   ---------------------------------------------------------
   type Acceleration is record
      Q_Dot : Float;  --  Pitch acceleration [deg/s/s]
      Az    : Float;  --  vertical acceleration [m/s/s]
      Ax    : Float;  --  horizontal acceleration [m/s/s]
   end record;
   ---------------------------------------------------------
   --  Compute_Accelerations
   --
   --  Input:
   --     S : Aircraft_State
   --     F : Aero_Forces (Drag, Lift_Pitch, Vel_Damping)
   --
   --  Output:
   --     Acceleration record containing Q_Dot and Az.
   --
   --  Description:
   --     Computes pitch and vertical accelerations based on:
   --       - aerodynamic forces (from Aerodynamics)
   --       - thrust and mass (from Aircraft)
   --       - control surface effectiveness (K_Elevator)
   --       - pitch rate damping (D_Pitch)
   --
   --     This function represents the aircraft's dynamic
   --     response model.
   ---------------------------------------------------------  
   function Compute_Accelerations (S : Aircraft.Aircraft_State; F: Aerodynamics.Aero_Forces) return Acceleration;
   

end Dynamics;
