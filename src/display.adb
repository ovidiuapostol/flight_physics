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

   Anim_X      : Float := 0.0;
   Last_Anim_X : Float := 0.0;
   Last_Anim_Z : Float := 0.0;

Traj_Map : array (0 .. 32, 0 .. 79) of Character :=
  (others => (others => ' '));


   function Phase_Color (P : Aircraft.Flight_Phase) return String is
   begin
      case P is
         when Aircraft.Ground_Roll =>
            return Character'Val(27) & "[92mGR" & Character'Val(27) & "[0m";  -- green

         when Aircraft.Rotation =>
            return Character'Val(27) & "[91mROT" & Character'Val(27) & "[0m";    -- red

         when Aircraft.Climb =>
            return Character'Val(27) & "[96mCLIMB" & Character'Val(27) & "[0m";   -- cyan

         when others =>
            return Character'Val(27) & "[90mUNKNOWN" & Character'Val(27) & "[0m";  -- gray
      end case;
   end Phase_Color;


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
      Screen_Width  : constant Positive := 80;

      Max_Altitude  : constant Float := 1500.0;
      Max_Distance  : constant Float := 13000.0;
      Target        : constant Float := 1000.0;
      Altitude      : Float := S_Loc.Position_Z;

      Marker_Row : Integer;
      Marker_Col : Integer;
      Target_Row : Integer;

      Buffer : Unbounded_String := To_Unbounded_String ("");

      DT : constant Float := Float (Period) * Utils.Ms_To_Sec;

      Traj_Row : Integer;
      Traj_Col : Integer;

      procedure Append_Line (Text : String) is
      begin
         Buffer := Buffer & Text & ASCII.LF;
      end Append_Line;

   begin
      ------------------------------------------------------
      -- Update animation horizontal position
      ------------------------------------------------------
      Altitude := Utils.Clamp (Altitude, 0.0, 1500.0);
      Anim_X := Anim_X + 20.0;

      if Anim_X >= Max_Distance then
         Anim_X := 0.0;
      end if;

      ------------------------------------------------------
      -- Compute marker position
      ------------------------------------------------------
      Marker_Col :=
        Integer (Float (Screen_Width - 1) * Anim_X / Max_Distance);
      Marker_Col := Utils.Clamp (Marker_Col, 0, Screen_Width - 1);

      Marker_Row :=
        Integer (Float (Screen_Height - 1) * S_Loc.Position_Z / Max_Altitude);
      Marker_Row := Utils.Clamp (Marker_Row, 0, Screen_Height - 1);

      ------------------------------------------------------
      -- Compute target row
      ------------------------------------------------------
      Target_Row :=
        Integer (Float (Screen_Height - 1) * Target / Max_Altitude);
      Target_Row := Utils.Clamp (Target_Row, 0, Screen_Height - 1);

      ------------------------------------------------------
      -- Store current position into trajectory map
      ------------------------------------------------------
      Traj_Col :=
        Integer (Float (Screen_Width - 1) * Anim_X / Max_Distance);
      Traj_Col := Utils.Clamp (Traj_Col, 0, Screen_Width - 1);

      Traj_Row :=
        Integer (Float (Screen_Height - 1) * S_Loc.Position_Z / Max_Altitude);
      Traj_Row := Utils.Clamp (Traj_Row, 0, Screen_Height - 1);

      Traj_Map (Traj_Row, Traj_Col) := '.';

      ------------------------------------------------------
      -- Clear screen
      ------------------------------------------------------
      Buffer := Buffer & Character'Val (27) & "[2J";
      Buffer := Buffer & Character'Val (27) & "[H";

      ------------------------------------------------------
      -- Draw scene
      ------------------------------------------------------
      for Row in reverse 0 .. Screen_Height - 1 loop
         declare
            Line        : Unbounded_String := To_Unbounded_String ("|");
            Current_Col : Integer := 0;
         begin
            --------------------------------------------------
            -- Draw trajectory from Traj_Map
            --------------------------------------------------
            for Col in 0 .. Screen_Width - 1 loop
               if Traj_Map (Row, Col) = '.' then
                  if Col > Current_Col then
                     for C in Current_Col + 1 .. Col loop
                        Line := Line & " ";
                     end loop;
                     Current_Col := Col;
                  end if;

                  Line := Line & ".";
                  Current_Col := Current_Col + 1;
               end if;
            end loop;

            --------------------------------------------------
            -- Draw aircraft marker
            --------------------------------------------------
            if Row = Marker_Row then
               if Marker_Col > Current_Col then
                  for C in Current_Col + 1 .. Marker_Col loop
                     Line := Line & " ";
                  end loop;
               end if;

               Line := Line &
                 Character'Val (27) & "[93m" & "<*>" & Character'Val (27) & "[0m";

               Current_Col := Marker_Col + 3;
            end if;

            --------------------------------------------------
            -- Draw target line
            --------------------------------------------------
            if Row = Target_Row then
               if Current_Col < 2 then
                  for C in Current_Col + 1 .. 2 loop
                     Line := Line & " ";
                  end loop;
               end if;

               Line := Line & "===== TARGET";
               Current_Col := Current_Col + 12;
            end if;

            --------------------------------------------------
            -- HUD (unchanged)
            --------------------------------------------------
            if Row = Screen_Height - 1 then
               declare
                  Left : constant String :=
                    "t: " & Time_Str (DT) & " s";

                  Mid : constant String :=
                    "Thr: " & F (S_Loc.Throttle)
                    & "   Phase: " & Phase_Color (S_Loc.Phase);
               begin
                  Line := To_Unbounded_String ("| ")
                    & Pad_Right (Left, 20)
                    & Pad_Right (Mid, 20);
               end;

            elsif Row = Screen_Height - 2 then
               declare
                  Left : constant String :=
                    "Alt: " & F (Altitude);

                  Mid : constant String :=
                    "Pitch: "
                    & F (S_Loc.Pitch_Angle)
                    & " "
                    & Pitch_Indicator (S_Loc.Pitch_Angle);

                  Right : constant String :=
                    "Elev: " & F (S_Loc.Elevator);
               begin
                  Line := To_Unbounded_String ("| ")
                    & Pad_Right (Left, 20)
                    & Pad_Right (Mid, 25)
                    & Right;
               end;

            elsif Row = Screen_Height - 3 then
               declare
                  Left : constant String :=
                    "V.Spd: " & F (S_Loc.Velocity_Z);

                  Mid : constant String :=
                    "P.Rate: " & F (S_Loc.Pitch_Rate);

                  Right : constant String :=
                    "D.Pitch: " & F (S_Loc.Desired_Pitch);
               begin
                  Line := To_Unbounded_String ("| ")
                    & Pad_Right (Left, 20)
                    & Pad_Right (Mid, 25)
                    & Right;
               end;
            end if;

            Append_Line (To_String (Line));
         end;
      end loop;

      Append_Line ("+-----------------------------------------------------------------------------");
      Put (To_String (Buffer));

   end Render_Frame;


end Display;
