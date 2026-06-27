------------------------------------------------------------
--  aircraft.ads
--  Package: Aircraft
--  Purpose: Contains/defines the aicraft model
--           Is updated by the Integrator.
--           All other packages reads it
--  Author : Ovi
------------------------------------------------------------
package Aircraft is
   ---------------------------------------------------------
   --  Aircraft constant
   --   some physical constants of the aircraft
   ---------------------------------------------------------
   Mass  : constant Float := 1200.0;          --  aircraft mass [kg]
   T_Max : constant Float := Mass * 20.0;     --  maximum motor thrust [N]
   Cd    : constant Float := 0.035;           --  drag coeficient
   Sref  : constant Float := 16.0;            --  wing area [m^2]
--   Rho   : constant Float := 1.225;           --  air density at sea level
   ---------------------------------------------------------
   --  Aircraft_State
   --   Represents the current state of the aircraft
   ---------------------------------------------------------
   type Aircraft_State is record
      Position    : Float := 0.0;           --  altitude [m]
      Velocity    : Float := 0.0;           --  vertical speed [m/s]
      Throttle    : Float := 0.0;           --  engine control [0..1]
   
      Pitch_Angle : Float := 0.0;        --  deg
      Pitch_Rate  : Float := 0.0;        --  deg/s
      Elevator    : Float := 0.0;        --  command [-1 .. 1]
   
      --  kept in AIrcraft_State for display and tunning effectivness only
      Desired_Pitch : Float := 0.0;       --  command from outer loop
   end record;
   ---------------------------------------------------------
   --  Aircraft (Protected Object)
   --   Manages shared simulation state
   ---------------------------------------------------------
   
   
   protected Aircraft is
      --  Update full aircraft state
      procedure Set_State (New_State : Aircraft_State);
      --  Read current aircraft state
      function Get_State   return Aircraft_State;
      --  Signal simulation termination
      function Should_Stop return Boolean;
      --  Run Time is needed by display, to update the running time
      function Get_Run_Time return Integer;
      --  Integrator step (updates position & velocity)
--      procedure Integrator;
   private
      S : Aircraft_State;             -- current state
      Run_Time : Natural  := 0;       -- simulation time counter
      Stop_Flag : Boolean := False;
   end Aircraft;

end Aircraft;
