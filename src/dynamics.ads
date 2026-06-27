with Aircraft;
with Aerodynamics;
package Dynamics is

   type Acceleration is record
      Q_Dot : Float;  --  Pitch acceleration
      Az    : Float;  --  vertical acceleration
   end record;
   
   function Compute_Accelerations (S : Aircraft.Aircraft_State; F: Aerodynamics.Aero_Forces) return Acceleration;
   

end Dynamics;
