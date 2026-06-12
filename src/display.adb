---------------------------------------------------------------------------
--  display.adb
--  Package: Display
--  Purpose: Text-based visualization of the vertical flight controller.
--           Uses ANSI escape sequences to render the aircraft position,
--           target altitude, and system values (position, velocity,
--           throttle) in a simple ASCII layout.
--  Author : Ovi
-------------------------------------------------------------------------
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.Strings; use Ada.Strings;
with Physics;

package body Display is
   ---------------------------------------------------------
   --  Render_Frame
   --   Builds and prints one complete ASCII frame.
   --   - Reads aircraft state from Physics
   --   - Maps altitude to screen rows
   --   - Draws aircraft (red) and target line
   --   - Uses buffering to avoid flicker
   ---------------------------------------------------------

   procedure Render_Frame is
      --  Current aircraft state (read-only)
      S_Loc : constant Physics.Aircraft_State := Physics.Aircraft.Get_State;

      --  Display configuration
      Screen_Height : constant Positive := 25;
      Max_Altitude  : constant Float := 1200.0;
      Target        : constant Float := 1000.0;

      --  Screen coordinates
      Marker_Row : Integer;
      Target_Row : Integer;

      --  Full frame buffer (avoids partial redraw)
      Buffer : Unbounded_String := To_Unbounded_String ("");

      ------------------------------------------------------
      --  Append_Line
      --   Add a line (with newline) to the buffer
      ------------------------------------------------------
      procedure Append_Line (Text : String) is
      begin
         Buffer := Buffer & Text & ASCII.LF;
      end Append_Line;

      ------------------------------------------------------
      --  F
      --   Format a Float for display (trim spaces)
      ------------------------------------------------------
      function F (X : Float) return String is
      begin
         return Trim (Float'Image (X), Both);
      end F;

   begin
      --  clear and Move cursor to top-left
      Buffer := Buffer & Character'Val (27) & "[2J";
      Buffer := Buffer & Character'Val (27) & "[H";
      Marker_Row :=
        Integer (Float (Screen_Height - 1)
        * S_Loc.Position / Max_Altitude);

      Target_Row :=
        Integer (Float (Screen_Height - 1)
        * Target / Max_Altitude);

      --  Keep aircraft marker within screen bounds
      if Marker_Row < 0 then
         Marker_Row := 0;
      elsif Marker_Row > Screen_Height - 1 then
         Marker_Row := Screen_Height - 1;
      end if;

      --  Draw scene from top -> bottom
      for Row in reverse 0 .. Screen_Height - 1 loop
         declare
            Line : Unbounded_String :=
              To_Unbounded_String ("|");
         begin
            --  Aircraft marker (RED)
            if Row = Marker_Row then
               Line := Line &
                 Character'Val (27) & "[31m" &  -- red
                 "  <*>" &
                 Character'Val (27) & "[0m";    -- reset
            end if;
            --  Target line (always visible)
            if Row = Target_Row then
               Line := Line & "  ===== TARGET";
            end if;
            --  Info panel
            if Row = Screen_Height - 1 then
               Line := Line & "    Alt: " & F (S_Loc.Position);
            elsif Row = Screen_Height - 2 then
               Line := Line & "    Vel: " & F (S_Loc.Velocity);
            elsif Row = Screen_Height - 3 then
               Line := Line & "    Thr: " & F (S_Loc.Throttle);
            end if;

            Append_Line (To_String (Line));
         end;
      end loop;

      --  Bottom border
      Append_Line ("+---------------------------");

      Put (To_String (Buffer));

   end Render_Frame;

end Display;
