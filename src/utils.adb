------------------------------------------------------------
--  utils.adb
--  Package body: Utils
--
--  Purpose:
--     Implements general-purpose utility functions used
--     throughout the simulation. These helpers are not tied
--     to physics, control logic, or rendering. They provide
--     basic numeric operations, vector math, and formatting
--     support for multiple modules.
--
--     The functions here improve code reuse, readability,
--     and consistency across Aerodynamics, Dynamics, PID
--     control, and the HUD/animation system.
--
--  Notes:
--     - All functions are lightweight and side-effect free.
--     - Direction always returns a unit vector; zero vectors
--       are handled safely.
--     - Arctan2 is implemented manually because Ada's math
--       library does not provide a two-argument version.
--
--  Author : Ovi
------------------------------------------------------------
with Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions;
package body Utils is
   ---------------------------------------------------------
   --  Clamp (Float)
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
   
   ---------------------------------------------------------
   --  Clamp (Integer)
   ---------------------------------------------------------   
   function Clamp (Value : Integer; Min : Integer; Max : Integer) return Integer  is 
   begin
      if Value < Min then
         return Min;
      elsif Value > Max then
        return Max;
      else
         return Value;
      end if;    
   end Clamp;
   
  ---------------------------------------------------------
   --  Magnitude
   --
   --  Computes the Euclidean length of a 2-D vector:
   --      |V| = sqrt(Vx*Vx + Vz*Vz)
   --
   --  Overloads support both raw components and Vector2D.
   ---------------------------------------------------------   
   function Magnitude (Vx : Float; Vz : Float) return Float is
   begin
      return Sqrt (Vx * Vx + Vz * Vz);
   end Magnitude;
   
   function Magnitude (V : Vector2D) return Float is
   begin
      return Sqrt (V.X * V.X + V.Z * V.Z);
   end Magnitude;  
   
   ---------------------------------------------------------
   --  Direction
   --
   --  Returns a unit vector in the direction of (Vx, Vz).
   --  If the magnitude is zero, returns (0, 0).
   ---------------------------------------------------------   
   function Direction (Vx : Float; Vz : Float) return Vector2D is
      Norm : constant Float := Magnitude (Vx, Vz);
      Dir  : Vector2D := (X => 0.0, Z => 0.0);
   begin
      if Norm > 0.0 then
         Dir.X := Vx / Norm;
         Dir.Z := Vz / Norm;
      end if;
      return Dir;
   end Direction;
   
   function Direction (V : Vector2D) return Vector2D is
      Norm : constant Float := Magnitude (V);
      Dir  : Vector2D := (X => 0.0, Z => 0.0);
   begin
      if Norm > 0.0 then
         Dir.X := V.X / Norm;
         Dir.Z := V.Z / Norm;
      end if;
      return Dir;
   end Direction;
   ---------------------------------------------------------
   --  Arc tangent in the correct quadrant
   ---------------------------------------------------------      
   function Arctan2 (Y, X : Float) return Float is
   begin
      if X > 0.0 then
         return Arctan (Y / X);
      elsif X < 0.0 then
         if Y >= 0.0 then
            return Arctan (Y / X) + Ada.Numerics.Pi;
         else
            return Arctan (Y / X) - Ada.Numerics.Pi;
         end if;
      else -- X = 0
         if Y > 0.0 then
            return Ada.Numerics.Pi / 2.0;
         elsif Y < 0.0 then
            return -Ada.Numerics.Pi/2.0;
         else
            return 0.0;  -- undefined but safe ??
         end if;
      end if;
      
   end Arctan2;
   ---------------------------------------------------------
   --  Phase_To_String
   --
   --  Converts a Flight_Phase enumeration into a short
   --  string for HUD display.
   ---------------------------------------------------------   
   function Phase_To_String (P : Flight_Phase) return String is
   begin
      case P is
         when Ground_Roll => return "GR";
         when Rotation    => return "ROT";
         when Climb       => return "CLIMB";
      end case;
   end Phase_To_String;
   
end Utils;
