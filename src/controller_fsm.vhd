----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is

-- CONSTANTS ------------------------------------------------------------------
  signal f_Q   : std_logic_vector(3 downto 0) := "0001"; 
  signal f_Q_next  : std_logic_vector(3 downto 0) := "0001"; 

begin


	-- CONCURRENT STATEMENTS --------------------------------------------------------	
	-- Next state logic
	f_Q_next(0) <= (f_Q(0) AND i_reset) OR (f_Q(1) AND i_reset) OR (f_Q(2) AND i_reset) OR (f_Q(3) AND i_reset) OR (f_Q(3) AND NOT(i_reset) AND i_adv) OR (f_Q(0) AND NOT(i_reset) AND NOT(i_adv));
	f_Q_next(1) <= (f_Q(0) AND NOT(i_reset) AND i_adv) OR (f_Q(1) AND NOT(i_reset) AND NOT(i_adv));
	f_Q_next(2) <= (f_Q(1) AND NOT(i_reset) AND i_adv) OR (f_Q(2) AND NOT(i_reset) AND NOT(i_adv));
	f_Q_next(3) <= (f_Q(2) AND NOT(i_reset) AND i_adv) OR (f_Q(3) AND NOT(i_reset) AND NOT(i_adv));
	
	
	--Output Logic
	o_cycle(0) <= f_Q(0);
	o_cycle(1) <= f_Q(1);
	o_cycle(2) <= f_Q(2); 
	o_cycle(3) <= f_Q(3);
    ---------------------------------------------------------------------------------
	
	-- PROCESSES --------------------------------------------------------------------
    register_proc : process (i_adv, i_reset)
	begin
			--Reset state is clear
        if i_reset = '1' then
            f_Q <= "0001";        -- reset state is clear
        elsif (i_reset = '0' AND i_adv = '0') then
            f_Q <= f_Q;         -- stays at current state
        elsif (i_reset = '0' AND i_adv = '1') then
            f_Q <= f_Q_next;    -- next state becomes current state
        end if;

	end process register_proc;
	-----------------------------------------------------					   
				  

end FSM;
