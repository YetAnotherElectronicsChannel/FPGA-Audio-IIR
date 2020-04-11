----------------------------------------------------------------------------------
-- Engineer: github.com/YetAnotherElectronicsChannel
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity audiosystem is
port (
    clk  : in std_logic;
    
    i2s_mclk_adc : out std_logic;
    i2s_bclk_adc : out std_logic;
    i2s_lr_adc : out std_logic;
    i2s_din : in std_logic;
	
    i2s_mclk_dac : out std_logic;
    i2s_bclk_dac : out std_logic;
    i2s_lr_dac : out std_logic;
	i2s_dout : out std_logic
	
    );
end audiosystem;

architecture Behavioral of audiosystem is


   
component i2s_rxtx is
    port (
    clk : in std_logic;
    
    i2s_bclk : in std_logic;
    i2s_lr : in std_logic;
    i2s_din : in std_logic;
    i2s_dout : out std_logic;
    
    out_l : out signed (23 downto 0);
    out_r : out signed (23 downto 0);
    
    in_l : in signed (23 downto 0);
    in_r : in signed (23 downto 0);
    
    sync  : out std_logic
    );
end component;
 
component IIR is
port (
    clk  : in std_logic := '0';
    
    iir_in : in signed (31 downto 0) := (others=>'0');
    sample_valid_in  : in std_logic := '0';
    
    iir_out : out signed(31 downto 0) := (others=>'0');
    sample_valid_out : out std_logic := '0';
    
    busy : out std_logic := '0';

-- a0, a1, a2, b1, b2 must be multiplied with 2^30 before
	
    a0 : integer;
    a1 : integer;
    a2 : integer;
    b1 : integer;
    b2 : integer
    );
end component; 



--i2s data control signals
signal sync : std_logic:= '0';

--24 bit i2s i/o signals
signal i2s_l_in, i2s_r_in, i2s_l_out, i2s_r_out :signed (23 downto 0):= (others=>'0');

--32 bit IIR i/o signals
signal iir_l_in, iir_r_in, iir_l_out, iir_r_out : signed (31 downto 0):= (others=>'0');


--timers for i2s clk generation
signal mclk_state : std_logic := '1';
signal lr_counter : unsigned (7 downto 0):= (others=>'0');
signal bclk_counter : unsigned(1 downto 0):= (others=>'0');



begin


-- i2s clock generation
-- clk = 25 MHz
-- mclk = clk/2 = 12.5 MHz (ideally 12.288 MHz)
-- bclk = clk/4 = 6.25 MHz (ideally 6.144 MHz)
-- lr = clk/256 = 97.6 kHz (ideally 96 kHz)

i2s_mclk_adc <= mclk_state;
i2s_mclk_dac <= mclk_state;
i2s_bclk_adc <= bclk_counter(1);
i2s_bclk_dac <= bclk_counter(1);
i2s_lr_adc <= lr_counter(7); 
i2s_lr_dac <= lr_counter(7); 

process (clk)
begin
if (rising_edge(clk)) then

	mclk_state <= not mclk_state;
	lr_counter <= lr_counter+to_unsigned(1,8);
	bclk_counter <= bclk_counter+to_unsigned(1,2);          

end if;

end process;



--i2s transmitter / receiver
i2s_l_out <= resize(iir_l_out,24);
i2s_r_out <= resize(iir_r_out,24);

rxtx : i2s_rxtx
    port map (
        clk => clk,
        
        
        i2s_bclk => bclk_counter(1),
		i2s_lr => lr_counter(7),
        i2s_din => i2s_din,
        i2s_dout => i2s_dout,
        
        out_l => i2s_l_in,
        out_r => i2s_r_in,
        
        in_l => i2s_l_out,
        in_r => i2s_r_out,
        
        sync => sync
      );




-- iir-lowpass, fs=96kHz, f_cut=1kHz, q=0.7
iir_l_in <= resize(i2s_l_in, 32);

iir_lp : IIR
	port map (
    clk => clk,
    
    iir_in => iir_l_in,
    sample_valid_in  => sync,
    
    iir_out => iir_l_out,
    sample_valid_out => open,
    
    busy => open,

	-- a0, a1, a2, b1, b2 must be multiplied with 2^30 before 
	
	-- 0.0010232172047183973*(2^30)
    a0 => 1098671,	
	-- 0.0020464344094367946*(2^30)
    a1 => 2197342,	
	-- 0.0010232172047183973*(2^30)
    a2 => 1098671,
	-- -1.9075008174364765*(2^30)
    b1 => -2048163407,
	-- 0.91159368625535*(2^30)
    b2 => 978816267
    );


--iir-highpass, fs=96kHz, f_cut=1kHz, q=0.7
iir_r_in <= resize(i2s_r_in, 32);

iir_hp : IIR
	port map (
    clk => clk,
    
    iir_in => iir_r_in,
    sample_valid_in  => sync,
    
    iir_out => iir_r_out,
    sample_valid_out => open,
    
    busy => open,

	-- a0, a1, a2, b1, b2 must be multiplied with 2^30 before   
	
	-- 0.9547736259229567*(2^30)
    a0 => 1025180375,	
	-- -1.9095472518459133*(2^30)
    a1 => -2050360749,	
	-- 0.9547736259229567*(2^30)
    a2 => 1025180375,
	-- -1.9075008174364765*(2^30)
    b1 => -2048163407,
	-- 0.91159368625535*(2^30)
    b2 => 978816267
    );
end Behavioral;