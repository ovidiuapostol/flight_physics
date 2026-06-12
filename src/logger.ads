------------------------------------------------------------
--  logger.ads
--  Package: Logger
--  Purpose: Logs simulation data to a CSV file.
--           Records aircraft state values (position, velocity,
--           throttle) for analysis and evaluation of the
--           control system behavior.
--  Author : Ovi
------------------------------------------------------------
package Logger is

   --  Initialize logging (open file, write header)
   procedure Initialize_Logging;

   --  Finalize logging (close file)
   procedure Finalize_Logging;

   --  Log one simulation step (current aircraft state)
   procedure Log_Data;

end Logger;
