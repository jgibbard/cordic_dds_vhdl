---------------------------------------------------------------------------
-- Project  : Cordic DDS
-- Author   : James Gibbard (james@gibbard.me)
-- Date     : 2015-03-22
-- File     : cordic_sin_cos.vhd
-- Module   : cordic_sin_cos
---------------------------------------------------------------------------
-- Description : Outputs the sine and cosine of an inputted angle
---------------------------------------------------------------------------
-- Change Log
-- Version 0.0.1 : Initial version
---------------------------------------------------------------------------
-- Usage :
--  Input is 32 bits. i.e. 0 to (2^32 - 1) where:
--  0 = 0 deg and (2^32 - 1) = 659.999999... deg
--  Input width can be changed, but LUT will need recalculating
--
--  Output width can be changed as desired. Max width = 32
--  Outputs are signed and in 2s complement form.
--  Setting the output width also sets the number of cordic iterations
--
--  Gain of the module is set externally.
--  The cordic implementation has an inherent gain of approx. 1.646760258
--  Gain setting for 12bit full scale [((2^11) - 1)/1.646760258] = 0x4D8
--  Gain setting for 16bit full scale [((2^15) - 1)/1.646760258] = 0x4DB7
--  Gain setting for 32bit full scale [((2^32) - 1)/1.646760258] = 0x4DBA76D0
--  The gain value may need to have 4 or 5 subtracted from it.
--  This is to account for rounding errors which could lead to overflows.
--  Setting the gain higher than full scale range will cause overflows.
--
--  The operation of module is pipelined. (One sample out for each one in)
--  There is a delay of 'output_size_g' clock cycles from input to output.
---------------------------------------------------------------------------

library IEEE; use IEEE.STD_LOGIC_1164.all; use IEEE.numeric_std.all;

entity cordic_sin_cos is

generic (

    input_size_g    : integer := 32;  --Input size must match LUT width.
    output_size_g   : integer := 16 --Maximum = 32 bits. (Or LUT depth + 1)
);

 port (
    clk         : in std_logic;
    rst         : in std_logic;
    angle_in    : in std_logic_vector(input_size_g - 1 downto 0);
    gain_in     : in std_logic_vector(output_size_g - 1 downto 0);
    sine_out    : out std_logic_vector(output_size_g - 1 downto 0);
    cosine_out  : out std_logic_vector(output_size_g - 1 downto 0)
);
end cordic_sin_cos;


architecture behavioral of cordic_sin_cos is

---------------------------------------------------------------------------
--Define Cordic look up table (LUT)
---------------------------------------------------------------------------
--Total LUT size = 31*32 = 992bits = 124 bytes;
constant LUT_depth_c    : integer := 31;
constant LUT_width_c    : integer := 32;

--LUT Calculation is:
--Result of [ATAN(2^-i) * (2^32/360)] rounded and converted to HEX
--With in the range of 0 to LUT_depth_c - 1

type LUT_t is array (0 to LUT_depth_c - 1) of signed(LUT_width_c - 1 downto 0);
constant cordic_lut_c : LUT_t := (
    X"20000000",X"12E4051E",X"09FB385B",X"051111D4",X"028B0D43",X"0145D7E1",
    X"00A2F61E",X"00517C55",X"0028BE53",X"00145F2F",X"000A2F98",X"000517CC",
    X"00028BE6",X"000145F3",X"0000A2FA",X"0000517D",X"000028BE",X"0000145F",
    X"00000A30",X"00000518",X"0000028C",X"00000146",X"000000A3",X"00000051",
    X"00000029",X"00000014",X"0000000A",X"00000005",X"00000003",X"00000001",
    X"00000000"
);
---------------------------------------------------------------------------
--End of cordic look up table (LUT)
---------------------------------------------------------------------------

signal quadrant : std_logic_vector(1 downto 0);
signal gain     : std_logic_vector(output_size_g downto 0);

--Stores initial values for x, y, and z
signal initial_x    : signed(output_size_g downto 0);
signal initial_y    : signed(output_size_g downto 0);
signal initial_z    : signed(input_size_g - 1 downto 0);

--Stores x and y values for each pipeline stage of the cordic algorithm
--X and Y must be one bit wider than the output size due to adder carry bits
type pipeline_array_t is array (0 to output_size_g - 1)
                            of signed(output_size_g downto 0);

signal X : pipeline_array_t := (others => (others =>'0'));
signal Y : pipeline_array_t := (others => (others =>'0'));

--Stores z values for each pipeline stage of the cordic algorithm.
--Z must be as wide as the input angle
type pipeline_array_z_t is array (0 to output_size_g - 1)
                            of signed(input_size_g - 1 downto 0);

signal Z : pipeline_array_z_t := (others => (others =>'0'));

begin

--Top two bits of angle_in signal indicate its quadrant
quadrant <= angle_in(input_size_g - 1 downto input_size_g - 2);

--Expand gain_in by one bit while preserving the sign bit
gain <= ('1' & gain_in) when gain_in(output_size_g - 1) = '1'
    else ('0' & gain_in);

--This cordic implementation only works between -90 and +90
--This process rotates the input by +/- 90 degrees so that -90 >= Z(0) <= +90
angle_input : process(quadrant, gain, angle_in)
begin

        case quadrant is

            when "00" =>
                initial_x <= signed(gain);
                initial_y <= (others => '0');
                initial_z <= signed(angle_in);
            when "01" =>
                initial_x <= (others => '0');
                initial_y <= signed(gain);
                initial_z <= signed(("00" & angle_in(input_size_g-3 downto 0)));
            when "10" =>
                initial_x <= (others => '0');
                initial_y <= -(signed(gain));
                initial_z <= signed(("11" & angle_in(input_size_g-3 downto 0)));
            when "11" =>
                initial_x <= signed(gain);
                initial_y <= (others => '0');
                initial_z <= signed(angle_in);
            when others =>
                initial_x <= (others => '0');
                initial_y <= (others => '0');
                initial_z <= (others => '0');

        end case;

end process angle_input;

--This process generates the pipelined stages of the cordic algorithm
--See the Microchip Application note AN1061 for more details on cordic functions.
pipelined_cordic : process(clk, rst)
begin

        if (rst = '1') then

            --Clear the whole pipeline on reset
            for gen_var in 0 to (output_size_g - 1) loop
                X(gen_var ) <= (others => '0');
                Y(gen_var) <= (others => '0');
                Z(gen_var) <= (others => '0');
            end loop;

        elsif rising_edge(clk) then

            --Register initial values
            X(0) <= initial_x;
            Y(0) <= initial_y;
            Z(0) <= initial_z;

            generate_pipeline : for gen_var in 0 to output_size_g - 2 loop
                if (Z(gen_var) < 0) then
                    X(gen_var + 1) <= X(gen_var) + (shift_right((Y(gen_var)), gen_var));
                    Y(gen_var + 1) <= Y(gen_var) - (shift_right((X(gen_var)), gen_var));
                    Z(gen_var + 1) <= Z(gen_var) + cordic_lut_c(gen_var);
                else
                    X(gen_var + 1) <= X(gen_var) - (shift_right((Y(gen_var)), gen_var));
                    Y(gen_var + 1) <= Y(gen_var) + (shift_right((X(gen_var)), gen_var));
                    Z(gen_var + 1) <= Z(gen_var) - cordic_lut_c(gen_var);
                end if;
            end loop generate_pipeline;

        end if;

end process pipelined_cordic;

--Assign output
--As long as gain is set to ensure full scale range of output width (or less) then
--MSBit can be discarded to obtain the desired output width
sine_out    <= std_logic_vector(Y(output_size_g - 1)(output_size_g - 1 downto 0));
cosine_out  <= std_logic_vector(X(output_size_g - 1 )(output_size_g - 1 downto 0));

end behavioral;