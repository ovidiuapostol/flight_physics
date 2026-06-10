with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;


procedure Main is
   type Aircraft_State is record
      Position : Float := 0.0;   -- meters
      Velocity : Float := 0.0;   -- m/s
      Throttle : Float := 0.5;   -- 0.0 .. 1.0
   end record;

   procedure Integrate (S : in out Aircraft_State; DT : Float) is
      -- Aircraft constants
      T_Max : constant Float := 5000.0;     --  maximum motor thrust [N]
      Mass  : constant Float := 1200.0;     --  aircraft mass [kg]
      Cd    : constant Float := 0.035;      --  drag coeficient
      Sref  : constant Float := 16.0;       --  wing area m^2
      Rho   : constant Float := 1.225;      --  air density at sea level

      -- Forces
      Thrust : Float;
      Drag   : Float;

      -- Acceleration
      A : Float;
   begin
      -- Convert throttle to thrust
      Thrust := S.Throttle * T_Max;

      -- Drag force
      Drag := 0.5 * Rho * S.Velocity * S.Velocity * Cd * Sref;

      -- Longitudinal acceleration
      A := (Thrust - Drag) / Mass;

      -- Integrate velocity
      S.Velocity := S.Velocity + A * DT;

      -- Integrate position
      S.Position := S.Position + S.Velocity * DT;
   end Integrate;

   S : Aircraft_State;
   DT : constant Float := 0.1;
   I : Natural := 0;


begin
   Put_Line ("Project started");
   loop
      Integrate(S, DT);

      Put("Pos: ");
      Put(S.Position, Fore => 6, Aft => 2, Exp => 0);
      Put("  Vel: ");
      Put(S.Velocity*3.6, Fore => 6, Aft => 2, Exp => 0);

      New_Line;

      delay Duration (DT);
      I := I + 1;
      exit when I >= 300;
   end loop;
   null;
end Main;
