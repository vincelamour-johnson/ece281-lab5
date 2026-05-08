--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals
	
	component button_debounce
	   Port(	clk: in  STD_LOGIC;
			    reset : in  STD_LOGIC;
			    button: in STD_LOGIC;
			    action: out STD_LOGIC);
    end component;
	
	component controller_fsm
        port (  
            i_reset : in STD_LOGIC;
            i_adv   : in STD_LOGIC;
            o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
    end component;
    
    component ALU
        port (
            i_A      : in  std_logic_vector(7 downto 0);
            i_B      : in  std_logic_vector(7 downto 0);
            i_op     : in  std_logic_vector(2 downto 0);
            o_result : out std_logic_vector(7 downto 0);
            o_flags  : out std_logic_vector(3 downto 0)   -- N  Z  C  V
        );
    end component;
    
    component clock_divider
	   generic ( constant k_DIV : natural := 2	); -- How many clk cycles until slow clock toggles
											   -- Effectively, you divide the clk double this 
											   -- number (e.g., k_DIV := 2 --> clock divider of 4)
	   port ( 	i_clk    : in std_logic;
			    i_reset  : in std_logic;		   -- asynchronous
			    o_clk    : out std_logic		   -- divided (slow) clock
	   );
    end component;
    
    component twos_comp
        port (
            i_bin : in std_logic_vector(7 downto 0);
            o_sign: out std_logic;
            o_hund: out std_logic_vector(3 downto 0);
            o_tens: out std_logic_vector(3 downto 0);
            o_ones: out std_logic_vector(3 downto 0)
        );
    end component;
    
    component TDM4
	   generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
       Port ( i_clk		: in  STD_LOGIC;
              i_reset	: in  STD_LOGIC; -- asynchronous
              i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		      i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		      i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		      i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		      o_data	: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		      o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
	   );
    end component;
    
    component sevenseg_decoder
        Port ( i_Hex   : in STD_LOGIC_VECTOR (3 downto 0);
               o_seg_n : out STD_LOGIC_VECTOR (6 downto 0));
    end component;
    
    signal w_clk    : STD_LOGIC; 
    signal w_sign   : STD_LOGIC; 
    signal w_adv    : STD_LOGIC; 
    signal w_hunds  : STD_LOGIC_VECTOR(3 downto 0); 
    signal w_tens   : STD_LOGIC_VECTOR(3 downto 0); 
    signal w_ones   : STD_LOGIC_VECTOR(3 downto 0); 
    signal w_data   : STD_LOGIC_VECTOR(3 downto 0);
    signal w_result : STD_LOGIC_VECTOR(7 downto 0);
    signal w_flags  : STD_LOGIC_VECTOR(3 downto 0);
    signal w_cycle  : STD_LOGIC_VECTOR(3 downto 0);
    signal w_sign_digit  : STD_LOGIC_VECTOR(3 downto 0);
    signal w_sign_seg  : STD_LOGIC_VECTOR(6 downto 0);
    signal w_A_reg  : STD_LOGIC_VECTOR(7 downto 0);
    signal w_B_reg  : STD_LOGIC_VECTOR(7 downto 0);
    signal w_display_input : STD_LOGIC_VECTOR(7 downto 0);
    constant SEG_MINUS : std_logic_vector(6 downto 0) := "1111110";
    constant SEG_BLANK : std_logic_vector(6 downto 0) := "1111111";
    signal w_seg_decoded : STD_LOGIC_VECTOR(6 downto 0);
    signal w_an         : std_logic_vector(3 downto 0);
    

    
    
begin

    w_sign_digit <= "000" & w_sign;
    w_sign_seg <= SEG_MINUS when w_sign = '1' else SEG_BLANK;
    
	-- PORT MAPS ----------------------------------------
	
	uut0 : button_debounce
        port map (
            clk     => clk,
			reset   => btnU,
			button  => btnC,
			action  => w_adv
        );
        
     uut1 : controller_fsm
        port map (
            i_reset => btnU,
            i_adv   => w_adv,
            o_cycle => w_cycle
        );

	uut2 : ALU
        port map (
            i_A      => w_A_reg,
            i_B      => w_B_reg,
            i_op     => sw(2 downto 0),
            o_result => w_result,
            o_flags  => w_flags
        );
        
     uut3 : clock_divider
        port map (
            i_clk    => clk,
			i_reset  => btnU,
			o_clk    => w_clk
        );
       
      uut4 : twos_comp
        port map (
            i_bin  => w_display_input,
            o_sign => w_sign,
            o_hund => w_hunds,
            o_tens => w_tens,
            o_ones => w_ones
        );
        
        uut5 : TDM4
        port map (
              i_clk		=> w_clk,
              i_reset	=> btnU,
              i_D3 		=> w_sign_digit,
		      i_D2 		=> w_hunds,
		      i_D1 		=> w_tens,
		      i_D0 		=> w_ones,
		      o_data	=> w_data,
		      o_sel		=> w_an
        );
        
        uut6 : sevenseg_decoder
        port map (
            i_Hex   => w_data,
            o_seg_n => w_seg_decoded
        );
        
        
	
	-- CONCURRENT STATEMENTS ----------------------------
	
	process(clk)
	begin 
	   if btnU = '1' then
	        w_A_reg <= (others => '0');
	        w_B_reg <= (others => '0');
	        
	       
	   elsif rising_edge(clk) then
	   
	   
	       case w_cycle is 
	           when "0001" => 
	               w_A_reg <= sw;
	           
	           when "0010" => 
	               w_B_reg <= sw;
	           
	           when others => 
	               null;
	               
	       end case;
	           
	   end if;    
	end process;  
	
	with w_cycle select 
	   w_display_input <= w_A_reg when "0001",
	                      w_B_reg when "0010",
	                      w_result when "0100",
	                      (others => '0') when others;   
	                      
	                      
	 
	                      
	                      
	led(15 downto 12) <= w_flags when w_cycle = "0100" else "0000";
	
	led(3 downto 0) <= w_cycle; 
	
	an <= w_an;
	
	seg <= w_sign_seg when w_an = "0111" else w_seg_decoded;
	
end top_basys3_arch;
