with Environment;
with Aircraft;
package body Aerodynamics is

   function Compute_Forces (S : Aircraft.Aircraft_State) return Aero_Forces is
      F : Aero_Forces := (0.0, 0.0, 0.0);
      Cd : constant Float := Aircraft.Cd;
      Sref : constant Float := Aircraft.Sref;
   begin
     ---------------------------------------------
     -- Forces
     ---------------------------------------------
  
     F.Drag :=
         0.5 * Environment.Env.Rho *
         S.Velocity * S.Velocity *
            Cd * Sref;
      
      F.Lift_Pitch := K_Lift_Pitch * S.Pitch_Angle;
      F.Vel_Damping := -K_Vel_Damp * S.Velocity;
      
      return F;
   end Compute_Forces;
   

end Aerodynamics;
