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
	LEDG		: out std_logic_vector(9 downto 0)
);
end cordic_dds;


architecture behavioral of cordic_dds is

signal clk		: std_logic;
signal rst		: std_logic;
signal angle	: std_logic_vector(31 downto 0);
signal gain		: std_logic_vector(15 downto 0);
signal sine		: std_logic_vector(15 downto 0);
signal cosine	: std_logic_vector(15 downto 0);

begin

uut : entity work.cordic_sin_cos 
generic map (
	output_size_g	=> 16
)

port map (
	clk			=> clk,
	rst			=> rst,
	angle_in		=> angle,
	gain_in		=> gain,
	sine_out		=> sine,
	cosine_out	=> cosine 
);


angle_gen : process(clk, rst)
begin
	if rst = '1' then
		angle <= (others => '0');
		gain <= (others => '0');
	elsif rising_edge(clk) then
		gain <= X"04DB";
		angle <= std_logic_vector(unsigned(angle) + 100000);
	end if;

end process angle_gen;




end behavioral;