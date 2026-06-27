------------------------------------------------------------
--  display.ads
--  Package: Display
--  Purpose: Text-based visualization of the vertical flight controller.
--           Uses ANSI escape sequences to render the aircraft position,
--           target altitude, and system values (position, velocity,
--           throttle) in a simple ASCII layout.
--  Author : Ovi
------------------------------------------------------------
package Display is
   --  Renders the current simulation state as an ASCII frame
   --  in the terminal. Reads aircraft state internally.
   procedure Render_Frame (Period : Natural);

end Display;
