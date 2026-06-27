------------------------------------------------------------
--  logger.adb
--  Package: Logger
--  Purpose: Logs simulation data to a CSV file.
--           Writes aircraft state values (position, velocity,
--           throttle) for later analysis and visualization.
--  Author : Ovi
------------------------------------------------------------
with Ada.Text_IO; use Ada.Text_IO;
--with Integration;
with Aircraft;

package body Logger is

   --  Output file used for logging
   File : Ada.Text_IO.File_Type;

   --   Opens the CSV file for writing
   procedure Initialize_Logging is
   begin
      Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, "log.csv");
   end Initialize_Logging;

   --   Closes the log file
   procedure Finalize_Logging is
   begin
      Ada.Text_IO.Close (File);
   end Finalize_Logging;

   ---------------------------------------------------------
   --  Log_Data
   --   Writes one simulation step:
   --   Position, Velocity, Throttle
   ---------------------------------------------------------
   procedure Log_Data is
      --  Read current aircraft state
      S_Local : constant Aircraft.Aircraft_State := Aircraft.Aircraft.Get_State;
   begin
      Ada.Text_IO.Put_Line
        (File, Float'Image (S_Local.Position) & ","
         & Float'Image (S_Local.Velocity) & "," & Float'Image (S_Local.Throttle) & ","
         & Float'Image (S_Local.Pitch_Angle) & "," & Float'Image (S_Local.Pitch_Rate) & ","
         & Float'Image (S_Local.Desired_Pitch) & "," & Float'Image (S_Local.Elevator)
        );
   end Log_Data;

begin
   ----------------------------------------------------------
   --  PACKAGE INITIALIZATION (runs BEFORE scheduler starts)
   ------------------------------------------------------------
   --  Open log file
   Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, "log.csv");

   --  Write CSV header
   Ada.Text_IO.Put_Line (File, "Position,Velocity,Throttle, Pitch_Angle,Pitch_Rate,Desired_Pitch,Elevator");

exception
   ---------------------------------------------------------
   --  Safety: ensure file is closed on error
   ---------------------------------------------------------
   when others =>
      if Ada.Text_IO.Is_Open (File) then
         Ada.Text_IO.Close (File);
      end if;
   raise;
end Logger;
