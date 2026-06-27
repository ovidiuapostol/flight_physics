------------------------------------------------------------
--  aircraft.ads
--  Package: Aircraft
--  Purpose: Contains/defines the aicraft model
--           Is updated by the Integrator.
--           All other packages reads it
--  Author : Ovi
------------------------------------------------------------
package body Aircraft is

   ---------------------------------------------------------
   --  Aircraft (Protected Body)
   --   Encapsulates shared simulation state and updates
   ---------------------------------------------------------
   protected body Aircraft is

      --   Update full aircraft state
      procedure Set_State (New_State : Aircraft_State) is
      begin
         S := New_State;
      end Set_State;

      --   Return current aircraft state
      function Get_State return Aircraft_State is
      begin
         return S;
      end Get_State;

      --   Check if simulation should terminate
      function Should_Stop return Boolean is
      begin
         return Stop_Flag;
      end Should_Stop;

      --  Return the ellapsed run time
      function Get_Run_Time return Integer is
      begin
         return Run_Time;
      end Get_Run_Time;
   end Aircraft;
   

end Aircraft;
