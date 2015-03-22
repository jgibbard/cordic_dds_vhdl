---------------------------------------------------------------------------
-- Project	: Cordic DDS
-- Author	: James Gibbard (james@gibbard.me)
-- Date		: 2015-03-22
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
	input_size_g	: integer := 32;  --Must be 32
	output_size_g	: integer := 32;
	LUT_width		: integer := 32;
	LUT_depth		: integer := 31
);

 port (
	clk			: in std_logic;
	rst			: in std_logic;
	angle_in		: in std_logic_vector(input_size_g - 1 downto 0);
	sine_out		: out std_logic_vector(output_size_g - 1 downto 0);
	cosine_out	: out std_logic_vector(output_size_g - 1 downto 0)
);
end cordic_sin_cos;


architecture behavioral of cordic_sin_cos is

--Define Cordic look up table (LUT)
type LUT_t is array (0 to LUT_depth - 1) of signed(LUT_width - 1 downto 0);
constant cordic_lut_c : LUT_t := (
	X"20000000",X"12E4051E",X"09FB385B",X"051111D4",X"028B0D43",X"0145D7E1",
	X"00A2F61E",X"00517C55",X"0028BE53",X"00145F2F",X"000A2F98",X"000517CC",
	X"00028BE6",X"000145F3",X"0000A2FA",X"0000517D",X"000028BE",X"0000145F",
	X"00000A30",X"00000518",X"0000028C",X"00000146",X"000000A3",X"00000051",
	X"00000029",X"00000014",X"0000000A",X"00000005",X"00000003",X"00000001",
	X"00000000"
);

constant gain_c : signed(output_size_g - 1 downto 0) := X"006E8C0A";

signal quadrant : std_logic_vector(1 downto 0);

type pipeline_array_t is array (0 to output_size_g - 1) of signed(output_size_g downto 0);

signal X : pipeline_array_t;
signal Y : pipeline_array_t;
signal Z : pipeline_array_t;


begin

quadrant <= angle_in(input_size_g-1 downto input_size_g - 2);

angle_input : process(clk,rst)
begin

	if (rst = '1') then
		
	elsif rising_edge(clk) then
	
		case quadrant is
		
			when "00" =>
				X(0) <= gain_c;
				Y(0) <= (others => '0');
				Z(0) <= signed(angle_in);
			when "01" =>
				X(0) <= (others => '0');
				Y(0) <= gain_c;
				Z(0) <= signed(("00" & angle_in(input_size_g-3 downto 0))); 
			when "10" =>
				X(0) <= (others => '0');
				Y(0) <= -(gain_c);
				Z(0) <= signed(("11" & angle_in(input_size_g-3 downto 0)));
			when "11" =>
				X(0) <= gain_c;
				Y(0) <= (others => '0');
				Z(0) <= signed(angle_in);
				
		end case;

	end if;

end process angle_input;

pipelined_cordic : process(clk, rst)
begin


end process pipelined_cordic;



end behavioral;