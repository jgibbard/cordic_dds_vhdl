---------------------------------------------------------------------------
-- Project	: Cordic DDS
-- Author	: James Gibbard (james@gibbard.me)
-- Date 		: 2015-03-22
-- File		: cordic_dds.vhd
-- Module	: cordic_dds
---------------------------------------------------------------------------
-- Description : Generates a sine and cosine signal at user setable frequency
---------------------------------------------------------------------------
-- Change Log
-- Version 0.0.1 : Initial version
---------------------------------------------------------------------------

library IEEE; use IEEE.STD_LOGIC_1164.all; use IEEE.numeric_std.all;
 
entity cordic_dds is port (
	clock 	: in std_logic;
	SW			: in std_logic_vector(9 downto 0);
	LEDG		: OUT std_logic_vector(9 downto 0)
);
end cordic_dds;


architecture behavioral of cordic_dds is

begin




end behavioral;