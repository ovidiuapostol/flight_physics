---------------------------------------------------------------------------
--  display.adb
--  Package: Display
--  Purpose: Text-based visualization of the vertical flight controller.
--           Uses ANSI escape sequences to render the aircraft position,
--           target altitude, and system values (position, velocity,
--           throttle) in a simple ASCII layout.
--  Author : Ovi
-------------------------------------------------------------------------
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;         use Ada.Strings.Fixed;
with Ada.Strings;               use Ada.Strings;
with Utils;
with Aircraft;
with Simulation_Loop;

package body Display is

   ---------------------------------------------------------
   -- Pad string to fixed width
   ---------------------------------------------------------
   function Pad_Right (S : String; Width : Natural) return String is
   begin
      if S'Length >= Width then
         return S;
      else
         return S & (1 .. Width - S'Length => ' ');
      end if;
   end Pad_Right;

   ---------------------------------------------------------
   -- Pitch indicator
   ---------------------------------------------------------
   function Pitch_Indicator (Angle : Float) return String is
   begin
      if Angle > 5.0 then
         return "///";
      elsif Angle > 1.0 then
         return " / ";
      elsif Angle < -5.0 then
         return "\\\\";   -- descending strongly
      elsif Angle < -1.0 then
         return " \\ ";
      else
         return "---";
      end if;
   end Pitch_Indicator;

   ---------------------------------------------------------
   -- Format float nicely
   ---------------------------------------------------------
   function F (X : Float) return String is
   begin
      return Trim (Float'Image (X), Both);
   end F;

   ---------------------------------------------------------
   -- Time string (seconds)
   ---------------------------------------------------------
   function Time_Str (DT : Float) return String is
   begin
      return Trim
        (Float'Image (Float (Simulation_Loop.Simulation_Cycles_Current) * DT), Both);
   end Time_Str;

   ---------------------------------------------------------
   -- Render frame
   ---------------------------------------------------------
   procedure Render_Frame (Period : Natural) is

      S_Loc : constant Aircraft.Aircraft_State :=
        Aircraft.Aircraft.Get_State;

      Screen_Height : constant Positive := 33;
      Max_Altitude  : constant Float := 1500.0;
      Target        : constant Float := 1000.0;

      Marker_Row : Integer;
      Target_Row : Integer;

      Buffer : Unbounded_String := To_Unbounded_String ("");

      DT : constant Float := Float (Period) * Utils.Ms_To_Sec;

      ------------------------------------------------------
      procedure Append_Line (Text : String) is
      begin
         Buffer := Buffer & Text & ASCII.LF;
      end Append_Line;

   begin
      ------------------------------------------------------
      -- Clear screen
      ------------------------------------------------------
      Buffer := Buffer & Character'Val (27) & "[2J";
      Buffer := Buffer & Character'Val (27) & "[H";

      ------------------------------------------------------
      -- Position mapping
      ------------------------------------------------------
      Marker_Row :=
        Integer (Float (Screen_Height - 1)
        * S_Loc.Position / Max_Altitude);

      Target_Row :=
        Integer (Float (Screen_Height - 1)
        * Target / Max_Altitude);

      if Marker_Row < 0 then
         Marker_Row := 0;
      elsif Marker_Row > Screen_Height - 1 then
         Marker_Row := Screen_Height - 1;
      end if;

      ------------------------------------------------------
      -- Draw scene
      ------------------------------------------------------
      for Row in reverse 0 .. Screen_Height - 1 loop
         declare
            Line : Unbounded_String :=
              To_Unbounded_String ("|");
         begin

            -- Aircraft marker
            if Row = Marker_Row then
               Line := Line &
                 Character'Val (27) & "[96m" &
                 "  <*> " &
                 Character'Val (27) & "[0m";
            end if;

            -- Target line
            if Row = Target_Row then
               Line := Line & "  ===== TARGET";
            end if;

            --------------------------------------------------
            -- INFO PANEL
            --------------------------------------------------
            if Row = Screen_Height - 1 then
               declare
                  Left : constant String :=
                    "t: " & Time_Str (DT) & " s";

                  Mid : constant String :=
                    "Thr: " & F (S_Loc.Throttle);
               begin
                  Line := Line
                    & Pad_Right (Left, 20)
                    & Pad_Right (Mid, 20);
               end;

            elsif Row = Screen_Height - 2 then
               declare
                  Left : constant String :=
                    "Alt: " & F (S_Loc.Position);

                  Mid : constant String :=
                    "Pitch: "
                    & F (S_Loc.Pitch_Angle)
                    & " "
                    & Pitch_Indicator (S_Loc.Pitch_Angle);

                  Right : constant String :=
                    "Elev: " & F (S_Loc.Elevator);
               begin
                  Line := Line
                    & Pad_Right (Left, 20)
                    & Pad_Right (Mid, 25)
                    & Right;
               end;

            elsif Row = Screen_Height - 3 then
               declare
                  Left : constant String :=
                    "Vel: " & F (S_Loc.Velocity);

                  Mid : constant String :=
                    "P.Rate: " & F (S_Loc.Pitch_Rate);

                  Right : constant String :=
                    "D.Pitch: " & F (S_Loc.Desired_Pitch);
               begin
                  Line := Line
                    & Pad_Right (Left, 20)
                    & Pad_Right (Mid, 25)
                    & Right;
               end;
            end if;

            Append_Line (To_String (Line));
         end;
      end loop;

      Append_Line ("+---------------------------");

      Put (To_String (Buffer));

   end Render_Frame;

end Display;
