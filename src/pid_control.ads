------------------------------------------------------------
--  pid_control.ads
--  Package: PID_Control
--  Purpose:
--    Provides the multiloop PID/PD control logic for the
--    vertical flight channel of the aircraft simulation.
--    The controller operates in a cascaded structure:
--      * Outer loop  : Altitude => Desired Pitch (P-control)
--      * Inner loop  : Pitch => Elevator Command (PD-control)
--      * Energy loop : Altitude Error + Velocity Damping
--                      => Throttle Command (PI-control)
--    The PID_Step procedure performs one complete control
--    iteration using the current aircraft state and the
--    configured cycle period.
--  Role in Architecture:
--    - Reads the current Aircraft_State (altitude, pitch,
--      pitch rate, velocity).
--    - Computes elevator and throttle commands.
--    - Writes updated commands back into Aircraft_State.
--    - Called once per simulation cycle by the
--      Simulation_Loop task.
--  Notes:
--    - Period is given in milliseconds and used to compute
--      the integration step for the I-term.
--    - Anti-windup and command clamping are implemented in
--      the package body.
--    - The controller is stateless except for its internal
--      integrator.
--  Author : Ovi
------------------------------------------------------------

with Aircraft;
package PID_Control is
   ---------------------------------------------------------
   --  PID_Step
   --  Performs one control iteration for the vertical
   --  flight control system. The procedure:
   --    * Computes altitude error.
   --    * Generates desired pitch (outer loop).
   --    * Computes elevator command (inner loop).
   --    * Computes throttle command (energy loop).
   --    * Applies clamping and anti windup.
   --    * Writes commands back into Aircraft_State.
   --  Parameters:
   --    S      : in out Aircraft.Aircraft_State
   --             Current aircraft state. Updated with new
   --             elevator, throttle, and desired pitch.
   --    Period : in Natural
   --             Control cycle time in milliseconds.
   ---------------------------------------------------------
   procedure PID_Step (S : in out Aircraft.Aircraft_State;  Period : Natural);

end PID_Control;
