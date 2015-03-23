---------------------------------------------------------------------------
-- Project	: Cordic DDS
-- Author	: James Gibbard (james@gibbard.me)
-- Date 		: 2015-03-22
-- File		: cordic_dds.vhd
-- Module	: cordic_dds
---------------------------------------------------------------------------
-- Description : Generates sine and cosine signals at a user setable frequency
---------------------------------------------------------------------------
-- Change Log
-- Version 0.0.1 : Initial version
---------------------------------------------------------------------------
-- Usage :
--	The step size determines the frequency of the sin/cos signals.
--	The output frequency is set by Fout = (M*Fsamp)/(2^n)
--	Where M is the step size, Fsamp is the clock frequency, and n is 
--	the phase accumulator size in bits.
--
--	Phase accumulator size is user settable but must be >= 32 bits
--	A larger phase accumulator lets the frequency be set more accurately.
--	The frequency resolution is given by Fsamp/(2^n)
--
--	If the phase accumulator is >32 bits wide then the phase accumulator 
--	is truncated before it is sent to the cordic algorithm. The 
--	resolution still increases but a small amount of phase noise is added.
--				
--	The maximum output frequency is theoretically Fsamp/2, but
--	in practice Fsamp/3 should be considered the limit.
--
--	The gain and frequency can be changed every clock cycle.
-- There	will be a delay of 'output_size_g' clock cycles before the 
--	change appears at the output.
--
--	See the usage instructions for the cordic_sin_cos module for more 
--	information on the gain setting and CORDIC algorithm.
---------------------------------------------------------------------------

library IEEE; use IEEE.STD_LOGIC_1164.all; use IEEE.numeric_std.all;
 
entity cordic_dds is 

generic (
	output_size_g			: integer := 16; --Maximum = 32 bits (Unless LUT changed)
	phase_accum_size_g 	: integer := 32  --Minimum = 32 bits (Unless LUT changed)
);

port (
	clk 			: in std_logic;
	rst			: in std_logic;
	step_size	: in std_logic_vector(phase_accum_size_g - 1 downto 0);
	gain_in		: in std_logic_vector(output_size_g - 1 downto 0);
	sine_out 	: out std_logic_vector(output_size_g - 1 downto 0);
	cosine_out	: out std_logic_vector(output_size_g - 1 downto 0)
);
end cordic_dds;


architecture behavioral of cordic_dds is

signal phase_accum 	: std_logic_vector(phase_accum_size_g - 1 downto 0);
signal gain 			: std_logic_vector(output_size_g - 1 downto 0);

begin

--Instantiate CORDIC module
cordic_module : entity work.cordic_sin_cos 
generic map (
	output_size_g	=> output_size_g
)
port map (
	clk			=> clk,
	rst			=> rst,
	angle_in		=> phase_accum(phase_accum_size_g - 1 
												downto phase_accum_size_g - 32),
	gain_in		=> gain,
	sine_out		=> sine_out,
	cosine_out	=> cosine_out 
);

--Calculate next pahse value
phase_calc : process(clk, rst)
begin

	if rst = '1' then
		phase_accum <= (others => '0');
	elsif rising_edge(clk) then
		gain <= gain_in;
		phase_accum <= std_logic_vector(unsigned(phase_accum) + unsigned(step_size));
	end if;

end process phase_calc;

end behavioral;