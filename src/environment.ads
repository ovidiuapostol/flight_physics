
------------------------------------------------------------
--  environment.ads
--  Package: Environment
--  Purpose: Provides atmospheric parameters for the simulation.
--           Supplies air density used for drag computation
--           and receives aircraft velocity for potential use.
--           Designed as an extension point for future models
--           such as wind, turbulence, or altitude-dependent
--           atmosphere effects.
--  Author : Ovi
------------------------------------------------------------
package Environment is

   protected Env is

      procedure Set_Rho (R : Float);
      function Rho return Float;

      procedure Set_Altitude (H : Float);
      function Altitude return Float;

      procedure Set_Speed (V : Float);
      function Speed return Float;

      procedure Environment_Cyclic;

   private
      Rho_Val : Float := 1.225;    --  density (normaly computed from altitude)
      H_Val   : Float := 0.0;      --  for future use
      V_Val   : Float := 0.0;      --  for future use
   end Env;
end Environment;
