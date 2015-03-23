---------------------------------------------------------------------------
-- Project  : Cordic DDS
-- Author   : James Gibbard (james@gibbard.me)
-- Date     : 2015-03-22
-- File     : tb_cordic_sin_cos.vhd
-- Module   : tb_cordic_sin_cos
---------------------------------------------------------------------------
-- Description : Test bench for cordic based sine and cosine module
---------------------------------------------------------------------------
-- Change Log
-- Version 0.0.1 : Initial version
---------------------------------------------------------------------------

library IEEE; use IEEE.STD_LOGIC_1164.all; use IEEE.numeric_std.all;

entity tb_cordic_sin_cos is
end tb_cordic_sin_cos;

architecture testbench of tb_cordic_sin_cos is

signal clk      : std_logic := '0';
signal rst      : std_logic := '0';
signal angle    : std_logic_vector(31 downto 0) := (others => '0');
signal gain     : std_logic_vector(11 downto 0);
signal sine     : std_logic_vector(11 downto 0);
signal cosine   : std_logic_vector(11 downto 0);

constant clk_period : time := 1 ns;

begin

uut : entity work.cordic_sin_cos
generic map (
    output_size_g   => 12
)
port map (
    clk         => clk,
    rst         => rst,
    angle_in    => angle,
    gain_in     => gain,
    sine_out    => sine,
    cosine_out  => cosine
);

clk_gen : process
begin
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
end process clk_gen;

rst_gen : process
begin
    rst <= '1';
    wait for clk_period * 3.5;
    rst <= '0';
    wait;
end process rst_gen;

angle_gen : process(clk, rst)
begin
    if rst = '1' then
        angle <= (others => '0');
        gain <= (others => '0');
    elsif rising_edge(clk) then
        gain    <= X"4D8";
        angle   <= std_logic_vector(unsigned(angle) + 10000000);
    end if;

end process angle_gen;

end testbench;