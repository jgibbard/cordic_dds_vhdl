---------------------------------------------------------------------------
-- Project	: Cordic DDS
-- Author	: James Gibbard (james@gibbard.me)
-- Date 		: 2015-03-22
-- File		: cordic_sin_cos.vhd
-- Module	: cordic_sin_cos
---------------------------------------------------------------------------
-- Description : Outputs the sine and cosine of an inputted angle
---------------------------------------------------------------------------
-- Change Log
-- Version 0.0.1 : Initial version
---------------------------------------------------------------------------

library IEEE; use IEEE.STD_LOGIC_1164.all; use IEEE.numeric_std.all;
 
entity cordic_sin_cos is

generic (
	input_size_g	: integer := 32;
	output_size_g	: integer := 32
);

 port (
	clk			: in std_logic;
	reset			: in std_logic;
	angle_in		: in std_logic_vector(input_size_g - 1 downto 0);
	sine_out		: out std_logic_vector(output_size_g - 1 downto 0);
	cosine_out	: out std_logic_vector(output_size_g - 1 downto 0)
);
end cordic_sin_cos;


architecture behavioral of cordic_sin_cos is

begin




end behavioral;