------------------------------------------------------------
--  utils.ads
--  Package: Utils
--
--  Purpose:
--     Provides general-purpose utility functions used across
--     the flight-simulation codebase. These helpers are
--     intentionally lightweight and independent of physics,
--     control logic, or aircraft-specific behavior.
--
--     The utilities include:
--
--       - Numeric helpers
--           - Clamp for Float and Integer

--           - Arctan2 wrapper
--
--       - Unit conversion constants
--           - milliseconds -> seconds
--           - degrees <-> radians
--
--       - Formatting helpers
--           - Phase_To_String for HUD display
--
--     These functions are reusable throughout Aerodynamics,
--     Dynamics, PID control, and the animation system.
--
--  Notes:
--     - Vector2D is a simple 2-D structure used for velocity,
--       lift direction, and damping direction.
--     - Clamp is commonly used for control surface limits,
--       throttle bounds, and integrator anti-windup.
--     - Direction always returns a unit vector; zero vectors
--       are handled safely.
--
--  Author : Ovi
------------------------------------------------------------
with Aircraft;
use Aircraft;
package Utils is
   ---------------------------------------------------------
   --  Vector2D
   --
   --  Simple 2D vector type used for velocities, directions,
   --  aerodynamic force components, and damping calculations.
   ---------------------------------------------------------   
   type Vector2D is record
      X : Float;
      Z : Float;
   end record;
   
   ---------------------------------------------------------
   --  Unit Conversion Constants
   ---------------------------------------------------------   
   Ms_To_Sec  : constant Float := 0.001;
   Deg_To_Rad : constant Float := 0.01745;  -- PI/180
   Rad_To_Deg : constant Float := 57.2958;  -- 180/PI

   ---------------------------------------------------------
   --  Clamp (Float)
   --   Restricts a value to a specified range.
   ---------------------------------------------------------
   function Clamp (Value : Float; Min : Float; Max : Float) return Float; 
  ---------------------------------------------------------
   --  Clamp (Integer)
   --  Restricts an integer value to the range [Min, Max].
   --  Used mainly for animation indices and screen coordinates.
   ---------------------------------------------------------   
   function Clamp (Value : Integer; Min : Integer; Max : Integer) return Integer;
   ---------------------------------------------------------
   --  Magnitude
   --  Computes the Euclidean length of a 2D vector:
   --      |V| = sqrt(Vx*Vx + Vz*Vz)
   --  Overloads support both raw components and Vector2D.
   ---------------------------------------------------------   
   function Magnitude (Vx : Float; Vz : Float) return Float;
   function Magnitude (V : Vector2D) return Float;
   ---------------------------------------------------------
   --  Direction
   --
   --  Returns a unit vector in the direction of (Vx, Vz).
   --  If the vector magnitude is zero, returns (0, 0).
   ---------------------------------------------------------   
   function Direction (Vx : Float; Vz : Float) return Vector2D;
   function Direction (V : Vector2D) return Vector2D;
   ---------------------------------------------------------
   --  Arctan2
   --
   --  Compute the arctangent, in the correct quadrant
   ---------------------------------------------------------  
   function Arctan2 (Y, X : Float) return Float;
   ---------------------------------------------------------
   --  Phase_To_String
   --
   --  Converts a Flight_Phase enumeration into a readable
   --  string for HUD display (e.g., "CLIMB", "ROTATION").
   ---------------------------------------------------------   
   function Phase_To_String (P : Flight_phase) return String;
   
end Utils;
