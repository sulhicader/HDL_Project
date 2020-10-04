-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 22.9.2020 06:32:19 UTC

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity tb_max_filter_unit is
generic (
     pixel_depth_g: integer := 8;                                                         
     input_width_g : integer := 27;                                         
     address_width_g : integer := 10); 
end tb_max_filter_unit;

architecture tb of tb_max_filter_unit is

    component max_filter_unit
        port (input_img_in           : in std_logic_vector (pixel_depth_g-1 downto 0);
              output_img_out         : out std_logic_vector (pixel_depth_g-1 downto 0);
              clk                    : in std_logic;
              rst_n                  : in std_logic;
              start_op_in            : in std_logic;
              done_op_out            : out std_logic;
              input_img_enable_out   : out std_logic_vector (0 downto 0);
              output_img_enable_out  : out std_logic_vector (0 downto 0);
              input_img_address_out  : out std_logic_vector (address_width_g-1 downto 0);
              output_img_address_out : out std_logic_vector (address_width_g-1 downto 0));
    end component;

    signal input_img_in           : std_logic_vector (pixel_depth_g-1 downto 0);
    signal output_img_out         : std_logic_vector (pixel_depth_g-1 downto 0);
    signal clk                    : std_logic;
    signal rst_n                  : std_logic;
    signal start_op_in            : std_logic;
    signal done_op_out            : std_logic;
    signal input_img_enable_out   : std_logic_vector (0 downto 0);
    signal output_img_enable_out  : std_logic_vector (0 downto 0);
    signal input_img_address_out  : std_logic_vector (address_width_g-1 downto 0);
    signal output_img_address_out : std_logic_vector (address_width_g-1 downto 0);

    constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : max_filter_unit
    port map (input_img_in           => input_img_in,
              output_img_out         => output_img_out,
              clk                    => clk,
              rst_n                  => rst_n,
              start_op_in            => start_op_in,
              done_op_out            => done_op_out,
              input_img_enable_out   => input_img_enable_out,
              output_img_enable_out  => output_img_enable_out,
              input_img_address_out  => input_img_address_out,
              output_img_address_out => output_img_address_out);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    variable index : integer := 0;
    begin
        -- EDIT Adapt initialization as needed
        input_img_in <= (others => '0');
        start_op_in <= '0';

        -- Reset generation
        -- EDIT: Check that rst_n is really your reset signal
        rst_n <= '0';
        wait for 100 ns;
        rst_n <= '1';
        wait for 100 ns;

        while (index < 625) loop
            input_img_in <= std_logic_vector(to_unsigned(index, pixel_depth_g));
            index := index + 1;
            wait for 100 ns;
        end loop;
--         EDIT Add stimuli here
        wait for 100 * TbPeriod;
        
        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_max_filter_unit of tb_max_filter_unit is
    for tb
    end for;
end cfg_tb_max_filter_unit;