-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 30.7.2020 18:08:25 UTC

library ieee;
use ieee.std_logic_1164.all;

use IEEE.Numeric_Std.all;

entity tb_padding_dual_memory_unit is
end tb_padding_dual_memory_unit;

architecture tb of tb_padding_dual_memory_unit is

    component padding_dual_memory_unit
        port (clk       : in std_logic;
              ena       : in std_logic;
              enb       : in std_logic;
              address_a : in std_logic_vector (9 downto 0);
              address_b : in std_logic_vector (9 downto 0);
              wea       : in std_logic_vector (0 downto 0);
              data_out  : out std_logic_vector (7 downto 0);
              data_in   : in std_logic_vector (7 downto 0));
    end component;

    signal clk       : std_logic;
    signal ena       : std_logic;
    signal enb       : std_logic;
    signal address_a : std_logic_vector (9 downto 0);
    signal address_b : std_logic_vector (9 downto 0);
    signal wea       : std_logic_vector (0 downto 0);
    signal data_out  : std_logic_vector (7 downto 0);
    signal data_in   : std_logic_vector (7 downto 0);

    constant TbPeriod : time := 20 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';
    shared variable index : integer := 0;

begin

    dut : padding_dual_memory_unit
    port map (clk       => clk,
              ena       => ena,
              enb       => enb,
              address_a => address_a,
              address_b => address_b,
              wea       => wea,
              data_out  => data_out,
              data_in   => data_in);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        ena <= '0';
        enb <= '0';
        address_a <= (others => '0');
        address_b <= (others => '0');
        wea <= (others => '0');
        data_in <= (others => '0');
        
        ena <= '1';
        enb <= '1';
        wea <= (others => '1');
        
        while (index < 729) loop
            address_a <= std_logic_vector(to_unsigned(index, 10));
            address_b <= std_logic_vector(to_unsigned(index-1, 10));
            data_in <= std_logic_vector(to_unsigned((index+5) mod 8, 8));
            index := index + 1;
            wait for 100 ns;
        end loop;
        
        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_padding_dual_memory_unit of tb_padding_dual_memory_unit is
    for tb
    end for;
end cfg_tb_padding_dual_memory_unit;