------------------------------------------------------------
--  aerodynamics.adb
--
--  Package: Aerodynamics
--
--  Purpose:
--     Implements the aerodynamic force model used by the
--     flight physics simulation. This module computes ONLY
--     aerodynamic forces based on the current aircraft state
--     and environment:
--
--       - Drag (Cd * q * Sref model)
--       - Lift from angle of attack (CL_0 + CL_alpha * alpha)
--       - Velocity dependent aerodynamic damping
--       - Thrust resolved along body pitch angle
--
--     No accelerations or state integration are performed here.
--     The output forces are consumed by the Dynamics module.
--
--  Notes:
--     - Uses simplified linear aerodynamic coefficients.
--     - Lift is modeled as perpendicular to the velocity vector.
--     - Damping is a linear term proportional to speed and
--       opposite to the velocity direction.
--     - Environment.Env.Rho provides air density.
--
--  Author : Ovi
------------------------------------------------------------
with Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions;
with Environment;
with Aircraft;
with Utils;
with Ada.Text_IO; use Ada.Text_IO;
package body Aerodynamics is
   ---------------------------------------------------------
   --  Compute_Forces
   --
   --  Input:
   --     S : Aircraft_State
   --
   --  Output:
   --     Aero_Forces record containing:
   --       Fx : total aerodynamic + thrust force in X [N]
   --       Fz : total aerodynamic + thrust force in Z [N]
   --
   --  Description:
   --     Computes aerodynamic forces using a simplified model:
   --
   --       1. Dynamic pressure:
   --          q = 0.5 * rho * |V|^2
   --
   --       2. Drag:
   --          Drag = q * Sref * Cd
   --          Direction opposite to velocity.
   --
   --       3. Lift:
   --          Alpha = Theta - Gamma
   --          CL    = CL_0 + CL_Alpha * Alpha
   --          Lift  = q * Sref * CL
   --          Direction perpendicular to velocity.
   --
   --       4. Velocity damping:
   --          Vel_Damping = -K_Vel_Damp * |V|
   --          Applied along velocity direction.
   --
   --       5. Thrust:
   --          T = Throttle * T_Max
   --          Resolved along pitch angle Theta:
   --            Tx = T * cos(Theta)
   --            Tz = T * sin(Theta)
   --
   --     The resulting Fx, Fz are the sum of thrust, drag,
   --     lift, and damping components in each axis.
   ---------------------------------------------------------

   function Compute_Forces (S : Aircraft.Aircraft_State) return Aero_Forces is
      F        : Aero_Forces := (0.0, 0.0);
      --  Aircraft parameters
      Cd       : constant Float := Aircraft.Cd;
      Sref     : constant Float := Aircraft.Sref;
      --  Environment
      Rho      : constant Float := Environment.Env.Rho;
      -- pitch angle in rad
      Theta    : constant Float := S.Pitch_Angle * Utils.Deg_To_Rad;
      --  creating some alliases for easy formulas
      
      Vel      : constant Utils.Vector2D := (X => S.Velocity_X,
                                             Z => S.Velocity_Z);
      Vel_Dir  : constant Utils.Vector2D := Utils.Direction (S.Velocity_X, 
                                                             S.Velocity_Z);
      Speed    : constant Float := Utils.Magnitude (Vel);
      --  Thrust magnitude
      T        : constant Float := S.Throttle * Aircraft.T_Max; 
      --  Flight angle
      Gamma    : constant Float := Utils.Arctan2 (S.Velocity_Z, 
                                                  S.Velocity_X); 
      --  angle of attack
      Alpha    : constant Float := Theta - Gamma;             
      --  dynamic pressure
      q        : constant Float := 0.5 * Rho * Speed * Speed; 
      --  Zero Lift Coeficinet
      CL_0     : constant Float := 0.2;
      --  Slope of the Lift curve
      CL_Alpha : constant Float := 5.0; --  per radian
      
      Drag        : Float;   --  aerodynamic drag force [N] - magnitude
      Vel_Damping : Float;   --  aerodynamic velocity damping [N]
      Drag_X      : Float;   --  Drag componnent X
      Drag_Z      : Float;   --  Drag componnent Z

      Vel_Damp_X  : Float;   --  X componnent of velocity damping
      Vel_Damp_Z  : Float;   --  Z componnent of velocity damping
      CL          : Float;   --  Lift coeficient
      Lift        : Float;   --  Lift Force
      Lift_X      : Float;   --  lift Componnent X
      Lift_Z      : Float;   --  lift componnent Z
      --  lift directio is perpendicular to velocity
      Lift_Dir    : Utils.Vector2D := (X => -Vel_Dir.Z, Z => Vel_Dir.X);      
   begin 
      ---------------------------------------------
      -- Forces
      ---------------------------------------------
      Drag := 0.5 * Rho * Speed * Speed * Cd * Sref; -- magnitude of drag force
      Drag_X := -Vel_Dir.X * Drag;   -- drag direction is opste to velocity
      Drag_Z := -Vel_Dir.Z * Drag;  
      -----------------------------------------------------
      -- Lift contribution from pitch angle
      --   Simplified CL_alpha * alpha model
      -----------------------------------------------------      
      CL     := CL_0 + CL_Alpha * Alpha;
      Lift   := q * Sref * CL;
      Lift_X := Lift_Dir.X * Lift;  --  Lift direction is perpendiculat to velocity
      Lift_Z := Lift_Dir.Z * Lift;
      -----------------------------------------------------
      -- Velocity dependent aerodynamic damping
      --   Linear approximation: -k * V
      -----------------------------------------------------      
      Vel_Damping := -K_Vel_Damp * Speed;       --  velocity dampind is oposite to velocity
      Vel_Damp_X  := Vel_Damping * Vel_Dir.X;
      Vel_Damp_Z  := Vel_Damping * Vel_Dir.Z;
      
      -----------------------------------------------------
      --   Total Forces
      -----------------------------------------------------
      F.Fx := T * Cos (Theta) + Drag_X + Lift_X + Vel_Damp_X;
      F.Fz := T * Sin (Theta) + Drag_Z + Lift_Z + Vel_Damp_Z;
      return F;
   end Compute_Forces;
   

end Aerodynamics;
