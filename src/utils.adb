
------------------------------------------------------------
--  utils.adb
--  Package body: Utils
--
--  Purpose:
--     Implements general-purpose utility functions used
--     throughout the simulation.
--
--     These functions are domain-independent (not tied to
--     physics, control logic, or display) and improve
--     code reuse and readability.
--
--  Author : Ovi
------------------------------------------------------------
package body Utils is
   ---------------------------------------------------------
   --  Clamp
   ---------------------------------------------------------
   function Clamp (Value : Float; Min : Float; Max : Float) return Float is
   begin
      if Value < Min then
         return Min;
      elsif Value > Max then
        return Max;
      else
         return Value;
      end if;
      
   end Clamp;
   
end Utils;
