
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2026 12:56:58 PM
-- Design Name: 
-- Module Name: sevenseg_decoder_tb - Behavioral
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

entity sevenseg_decoder_tb is
end sevenseg_decoder_tb;

architecture test_bench of sevenseg_decoder_tb is 
	
  -- declare the component of your top-level design unit under test (UUT)
  component sevenseg_decoder is
    Port ( i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
           o_seg_n : out STD_LOGIC_VECTOR (6 downto 0));
   end component sevenseg_decoder;
  
 
	-- declare signals needed to stimulate the UUT inputs
	signal w_ins        : std_logic_vector(3 downto 0) := x"0"; -- the numbers being added
	signal w_outs       : std_logic_vector(6 downto 0);


begin
	-- PORT MAPS ----------------------------------------
	sevenseg_decoder_uut : sevenseg_decoder  port map (
	   i_Hex    => w_ins,
	   o_seg_n  =>  w_outs
	);
	
	-- PROCESSES ----------------------------------------	
	-- Test Plan Process
	-- Implement the test plan here.  Body of process is continuously from time = 0  
	test_process : process 
	begin
	
	   -- Test all zeros input
	   w_ins <= x"0"; wait for 10 ns;
	       assert (w_outs = "1000000") report "bad with zeros" severity failure;
	   w_ins <= x"1"; wait for 10 ns;
	       assert (w_outs = "1111001") report "bad with zeros" severity failure;
	   w_ins <= x"2"; wait for 10 ns;
	       assert (w_outs = "0100100") report "bad with zeros" severity failure;
	   w_ins <= x"3"; wait for 10 ns;
	       assert (w_outs = "0110000") report "bad with zeros" severity failure;
	   w_ins <= x"4"; wait for 10 ns;
	       assert (w_outs = "0011001") report "bad with zeros" severity failure;
	   w_ins <= x"5"; wait for 10 ns;
	       assert (w_outs = "0010010") report "bad with zeros" severity failure;
	   w_ins <= x"6"; wait for 10 ns;
	       assert (w_outs = "0000010") report "bad with zeros" severity failure;
	   w_ins <= x"7"; wait for 10 ns;
	       assert (w_outs = "1111000") report "bad with zeros" severity failure;
       -- Test with one input
       w_ins <= x"8"; wait for 10 ns;
	       assert (w_outs = "0000000") report "bad with zeros" severity failure;
	   w_ins <= x"9"; wait for 10 ns;
	       assert (w_outs = "0011000") report "bad with zeros" severity failure;
       -- TODO, a few other test cases
       w_ins <= x"A"; wait for 10 ns;
	       assert (w_outs = "0001000") report "bad with zeros" severity failure;
	   w_ins <= x"B"; wait for 10 ns;
	       assert (w_outs = "0000011") report "bad with zeros" severity failure;
	   w_ins <= x"C"; wait for 10 ns;
	       assert (w_outs = "0100111") report "bad with zeros" severity failure;
	   w_ins <= x"D"; wait for 10 ns;
	       assert (w_outs = "0100001") report "bad with zeros" severity failure;
	   w_ins <= x"E"; wait for 10 ns;
	       assert (w_outs = "0000110") report "bad with zeros" severity failure;
       w_ins <= x"F"; wait for 10 ns;
	       assert (w_outs = "0001110") report "bad with zeros" severity failure;
       
		wait; -- wait forever
	end process;	
	-----------------------------------------------------	
	
end test_bench;
