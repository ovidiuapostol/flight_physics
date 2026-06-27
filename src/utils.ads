
------------------------------------------------------------
--  utils.ads
--  Package: Utils
--  Purpose:
--     Provides general-purpose utility functions that are
--     independent of physics or control logic.
--
--     These helpers are reusable across the simulation
--     (e.g. numeric operations such as clamping values).
--
--     This package is intentionally lightweight and
--     contains only generic support functions.
--
--  Author : Ovi
------------------------------------------------------------
package Utils is
   
   Ms_To_Sec : constant Float := 0.001;

   ---------------------------------------------------------
   --  Clamp
   --   Restricts a value to a specified range.
   --
   --   If Value is greater than Max, returns Max.
   --   If Value is less than Min, returns Min.
   --   Otherwise returns Value unchanged.
   --
   --   Typical uses:
   --     - throttle limits [0.0, 1.0]
   --     - control surface limits [-1.0, 1.0]
   --     - integrator bounds
   ---------------------------------------------------------
  function Clamp (Value : Float; Min : Float; Max : Float) return Float; 

end Utils;
