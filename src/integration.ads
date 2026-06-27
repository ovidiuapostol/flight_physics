------------------------------------------------------------
--  Integration.ads
--  Package: Integration
--  Purpose:
--    Provides the numerical integration step for the aircraft
--    simulation. This package updates the aircraft state by
--    integrating the linear and angular accelerations over a
--    given time step.
--    The Integrate procedure performs:
--      - Angular motion integration (pitch rate, pitch angle)
--      - Linear vertical motion integration (velocity, altitude)
--      - Application of aerodynamic and dynamic accelerations
--      - Time-step based state propagation
--  Notes:
--    - Integration is intentionally stateless. All state is
--      passed in and out via the Aircraft_State record.
--    - The caller (Simulation_Loop) is responsible for:
--        * obtaining aerodynamic forces
--        * computing accelerations
--        * writing back the updated state
--    - Time_Step_ms is given in milliseconds and converted
--      internally to seconds.
--  Author : Ovi
------------------------------------------------------------
with Aircraft;
with Dynamics;
package Integration is
   ---------------------------------------------------------
   --  Integrate
   --  Updates the aircraft state by integrating the provided
   --  accelerations over the given time step.
   --  Parameters:
   --    S            : in out Aircraft.Aircraft_State
   --                   The current aircraft state. Updated
   --                   in place with new position, velocity,
   --                   pitch rate, and pitch angle.
   --    A            : in Dynamics.Acceleration
   --                   Linear and angular accelerations
   --                   computed by the Dynamics package.
   --    Time_Step_ms : in Natural
   --                   Integration time step in milliseconds.
   --  Algorithm:
   --    - Converts Time_Step_ms to seconds.
   --    - Integrates pitch rate and pitch angle.
   --    - Integrates vertical velocity and altitude.
   --    - Leaves all other state fields unchanged.
   ---------------------------------------------------------
   procedure Integrate (S : in out Aircraft.Aircraft_State; A : Dynamics.Acceleration; Time_Step_ms : Natural);


end Integration;
