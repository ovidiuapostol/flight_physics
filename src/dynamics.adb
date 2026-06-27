package body Dynamics is

  G         : constant Float := 9.81; -- gravity [m/s²]

  -- New pitch model constants
  K_Elevator   : constant Float := 20.0; -- elevator effectiveness (Cm_delta_e)
  D_Pitch      : constant Float := 5.0;  -- pitch damping (Cmq)
  
   function Compute_Accelerations (S : Aircraft.Aircraft_State; F : Aerodynamics.Aero_Forces) return Acceleration is
      A : Acceleration;
      --  Aircraft Parameters
      T_Max : constant Float := Aircraft.T_Max;
      Mass  : constant Float := Aircraft.Mass;
      
      --  Forces
      Thrust : Float;
   begin
      
      -- Thrust
      Thrust := S.Throttle * T_Max;
      
      -- Pitch Acceleration
      A.Q_Dot := K_Elevator * S.Elevator - D_Pitch * S.Pitch_Rate;
      
      --  vertical acceleration
      A.Az := (Thrust - F.Drag)/Mass + F.Lift_Pitch + F.Vel_Damping - G;
      
      return A;
   end Compute_Accelerations;
   

end Dynamics;
