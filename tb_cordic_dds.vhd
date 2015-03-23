---------------------------------------------------------------------------
-- Project  : Cordic DDS
-- Author   : James Gibbard (james@gibbard.me)
-- Date     : 2015-03-22
-- File     : tb_cordic_dds.vhd
-- Module   : tb_cordic_dds
---------------------------------------------------------------------------
-- Description : Test bench for cordic based DDS module
---------------------------------------------------------------------------
-- Change Log
-- Version 0.0.1 : Initial version
---------------------------------------------------------------------------

library IEEE; use IEEE.STD_LOGIC_1164.all; use IEEE.numeric_std.all;

entity tb_cordic_dds is
end tb_cordic_dds;

architecture testbench of tb_cordic_dds is

signal clk          : std_logic := '0';
signal rst          : std_logic := '0';
signal step_size    : std_logic_vector(31 downto 0);
signal gain         : std_logic_vector(15 downto 0);
signal sine         : std_logic_vector(15 downto 0);
signal cosine       : std_logic_vector(15 downto 0);

constant clk_period : time := 20 ns;

begin

uut : entity work.cordic_dds
generic map (
    output_size_g   => 16,
    phase_accum_size_g => 32
)
port map (
    clk         => clk,
    rst         => rst,
    step_size   => step_size,
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

test_vectors : process
begin
    gain <= X"4DB7"; 
    step_size <= X"051EB852";   -- 1MHz
    wait for 5 us;
    gain <= X"2DB7";
    step_size <= X"147AE148";   -- 4MHz
    wait;

end process test_vectors;

end testbench;