with Aircraft;
package Aerodynamics is

   type Aero_Forces is record
      Drag        : Float;
      Lift_Pitch  : Float;
      Vel_Damping : Float;
   end record;
   
   K_Lift_Pitch : constant Float := 0.02; -- lift from pitch (CL_alpha)
   K_Vel_Damp   : constant Float := 0.07;
   
   function Compute_Forces (S: Aircraft.Aircraft_State) return Aero_Forces;

end Aerodynamics;
