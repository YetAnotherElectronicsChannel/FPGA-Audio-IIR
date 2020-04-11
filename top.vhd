----------------------------------------------------------------------------------
-- Engineer: github.com/YetAnotherElectronicsChannel
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity main is
    port (
    clk_16mhz : in std_logic;
	
    i2s_mclk_adc : out std_logic;
    i2s_bclk_adc : out std_logic;
    i2s_lr_adc : out std_logic;
    i2s_din : in std_logic;
	
    i2s_mclk_dac : out std_logic;
    i2s_bclk_dac : out std_logic;
    i2s_lr_dac : out std_logic;
	i2s_dout : out std_logic
    );

    

end main;

architecture Behavioral of main is

signal clk : std_logic;
signal pllsreset: std_logic := '0';

component main_pll is
port(
      REFERENCECLK: in std_logic;
      RESET: in std_logic;
      PLLOUTCORE: out std_logic;
      PLLOUTGLOBAL: out std_logic;
      LOCK: out std_logic
    );
end component;


component audiosystem is 
port(
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
end component;

begin

-- generatore low-to-high transition for PLL reset input
process (clk_16mhz)
begin
	if (rising_edge(clk_16mhz)) then
		pllsreset <= '1';
	end if;
end process;



pll:    main_pll
port map(

   REFERENCECLK => clk_16mhz,
      RESET => pllsreset,
      PLLOUTCORE => open,
      PLLOUTGLOBAL => clk,
      LOCK=> open
);

audiomodule : audiosystem
port map (
    clk => clk,
    i2s_mclk_adc => i2s_mclk_adc,
    i2s_bclk_adc => i2s_bclk_adc,
    i2s_lr_adc => i2s_lr_adc,
    i2s_din => i2s_din,    
    i2s_mclk_dac => i2s_mclk_dac,
    i2s_bclk_dac => i2s_bclk_dac,
    i2s_lr_dac => i2s_lr_dac,
    i2s_dout => i2s_dout   
    );
    

end Behavioral;
