------------------------------------------------------------
--  environment.adb
--  Package: Environment
--  Purpose: Implements the environment model for the
--           simulation. Manages atmospheric parameters
--           such as air density and stores auxiliary data
--           (altitude, velocity) for potential extensions.
--  Author : Ovi
------------------------------------------------------------
package body Environment is
   ---------------------------------------------------------
   --  Env (Protected Body)
   --   Encapsulates environmental parameters shared across
   --   the simulation (air density, altitude, speed).
   ---------------------------------------------------------
   protected body Env is
      ------------------------------------------------------
      --  Set_Rho
      --   Update air density value
      ------------------------------------------------------
      procedure Set_Rho (R : Float) is
      begin
         Rho_Val := R;
      end Set_Rho;
      --   Return current air density
      function Rho return Float is
      begin
         return Rho_Val;
      end Rho;
      --   Store current altitude (extension point)
      procedure Set_Altitude (H : Float) is
      begin
         H_Val := H;
      end Set_Altitude;
      --   Return stored altitude
      function Altitude return Float is
      begin
         return H_Val;
      end Altitude;
      --   Store current aircraft speed (extension point)
      procedure Set_Speed (V : Float) is
      begin
         V_Val := V;
      end Set_Speed;
      --   Return stored speed
      function Speed return Float is
      begin
         return V_Val;
      end Speed;
      ------------------------------------------------------
      --  Environment_Cyclic
      --   Updates environment parameters periodically.
      --   Currently uses constant air density.
      ------------------------------------------------------
      procedure Environment_Cyclic is
      begin
         Env.Set_Rho (1.225);
      end Environment_Cyclic;

   end Env;

end Environment;
