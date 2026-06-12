------------------------------------------------------------
--  physics.ads
--  Package: Physics
--  Purpose: Defines aircraft state and vertical motion model.
--           Provides a protected object to safely read and
--           update simulation state during execution.
--  Author : Ovi
------------------------------------------------------------
package Physics is
   ---------------------------------------------------------
   --  Aircraft_State
   --   Represents the current state of the aircraft
   ---------------------------------------------------------
   type Aircraft_State is record
      Position : Float := 0.0;
      Velocity : Float := 0.0;
      Throttle : Float := 0.0;
   end record;
   ---------------------------------------------------------
   --  Simulation timing
   ---------------------------------------------------------
   --  this will be the recurence of the Integrator cycle time [ms]
   Time_Step : constant Natural := 100;
   --  DT is used as a Time_Step by the Integrator. The integrator need the
   --  value in second
   DT : constant Float   := Float (Time_Step) / 1000.0; --  [s]
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

      --  Integrator step (updates position & velocity)
      procedure Integrator;
   private
      S : Aircraft_State;             -- current state
      Run_Time : Natural  := 0;       -- simulation time counter
      Stop_Flag : Boolean := False;
   end Aircraft;

end Physics;
