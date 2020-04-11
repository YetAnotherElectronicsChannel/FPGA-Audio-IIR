----------------------------------------------------------------------------------
-- Engineer: github.com/YetAnotherElectronicsChannel
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity IIR is
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
end IIR;

architecture Behavioral of IIR is


signal state : integer := 0;

--signals for multiplier
signal mult_in_a, mult_in_b : signed (31 downto 0) := (others=>'0');
signal mult_out : signed (63 downto 0):= (others=>'0');

--temp regs and delay regs
signal temp : signed (39 downto 0):= (others=>'0');
signal temp_in, in_z1, in_z2, out_z1, out_z2 : signed (31 downto 0):= (others=>'0');


begin

-- multiplier
process(mult_in_a, mult_in_b)
begin
mult_out <= mult_in_a * mult_in_b;
end process;



process (clk)
begin
if (rising_edge(clk)) then    

	--start process when valid sample arrived
    if (sample_valid_in = '1' and state = 0) then
        -- load multiplier with samplein * a0
        mult_in_a <= iir_in;
        temp_in <= iir_in;
        mult_in_b <= to_signed(a0,32);
        state <= 1;
        busy <= '1';

    elsif (state = 1) then
        --save result of (samplein*a0) to temp and apply right-shift of 30
        --and load multiplier with in_z1 and a1
        temp <= resize(shift_right(mult_out,30),40);
        mult_in_a <= in_z1;
        mult_in_b <= to_signed(a1,32);
        state <= 2;

     elsif (state = 2) then
        --save and sum up result of (in_z1*a1) to temp and apply right-shift of 30
        --and load multiplier with in_z2 and a2
        temp <= temp + resize(shift_right(mult_out,30),40);
        mult_in_a <= in_z2;
        mult_in_b <= to_signed(a2,32);
        state <= 3;

         
      elsif (state = 3) then
        --save and sum up result of (in_z2*a2) to temp and apply right-shift of 30
        -- and load multiplier with out_z1 and b1
        temp <= temp + resize(shift_right(mult_out,30),40);
        mult_in_a <= out_z1;
        mult_in_b <= to_signed(b1,32);
        state <= 4;

      elsif (state = 4) then
        --save and sum up (negative) result of (out_z1*b1) and apply right-shift of 30
        --and load multiplier with out_z2 and b2
        temp <= temp - resize(shift_right(mult_out,30),40);
        mult_in_a <= out_z2;
        mult_in_b <= to_signed(b2,32);
        state <= 5;

      elsif (state = 5) then
        --save and sum up (negative) result of (out_z2*b2) and apply right-shift of 30
        temp <= temp - resize(shift_right(mult_out,30),40);
        state <= 6;
        
      elsif (state = 6) then
        --save result to output, save all delay registers, apply ouput-valid signal
        iir_out <= resize(temp,32);
        out_z1 <= resize(temp,32);
        out_z2 <= out_z1;       
        in_z2 <= in_z1;
        in_z1 <= temp_in;
        sample_valid_out <= '1';
        state <= 7;
        
      elsif (state = 7) then
        sample_valid_out <= '0';
        state <= 0;
        busy <= '0';
      end if;      
    

end if;
end process;
end Behavioral;
