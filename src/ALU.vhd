----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is

  -- declare the component of your top-level design unit under test (UUT)
  component ripple_adder is
    Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
           B : in STD_LOGIC_VECTOR (3 downto 0);
           Cin : in STD_LOGIC;
           S : out STD_LOGIC_VECTOR (3 downto 0);
           Cout : out STD_LOGIC
       );
   end component ripple_adder;
   
   signal sum_result : std_logic_vector(7 downto 0);
   signal c1         : std_logic;
   signal cout       : std_logic;

   
  
begin


-- PORT MAPS ----------------------------------------
	ripple_adder_uut1 : ripple_adder port map (
	   A    => i_A(3 downto 0),
	   B    => i_B(3 downto 0),
	   Cin  => '0',
	   S    => sum_result(3 downto 0),
	   Cout => c1
	);
	
	ripple_adder_uut2 : ripple_adder port map (
	   A    => i_A(7 downto 4),
	   B    => i_B(7 downto 4),
	   Cin  => c1,
	   S    => sum_result(7 downto 4),
	   Cout => cout
	);
	
	
	process(i_A, i_B, i_op, sum_result, cout)
	   variable alu_result : std_logic_vector(7 downto 0);
	begin
	
	alu_result := (others => '0');
	o_flags <= "0000";
	
	--deals with operations
	case i_op is 
	   
	   when "000" => 
        alu_result := sum_result;
        
       when "001" => 
        alu_result := std_logic_vector(unsigned(i_A) + unsigned(not i_B) + 1);
        
       when "010" => 
        alu_result := i_A AND i_B;
        
       when "011" => 
        alu_result := i_A OR i_B;
        
       when others => 
        alu_result := (others => '0');
    
    end case;
    
 
    o_result <= alu_result;
    



	
	--for the flags negative, zero, carry, overflow
	o_flags(0) <= alu_result(7);
	
	
	
	if (alu_result = "00000000") then
	   --flag is zero
	   o_flags(1) <= '1';
	else 
	   o_flags(1) <= '0';
	end if;
	
	--flag is carry
	
	if (i_op = "000" or i_op = "001") then
	   --flag is carry
	   o_flags(2) <= cout;
	end if;
	
	--flag is overflow
	if (i_op = "000") then
	   --flag is carry
	   o_flags(3) <= (i_A(7) XNOR i_B(7)) AND (i_A(7) XOR alu_result(7));
	elsif i_op = "001" then 
	   o_flags(3) <= (i_A(7) XOR i_B(7)) AND (i_A(7) XOR alu_result(7));
	else 
	   o_flags(3) <= '0';
	end if;
	
    end process;

    


end Behavioral;
