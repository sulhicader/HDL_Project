----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/28/2020 09:29:31 AM
-- Design Name: 
-- Module Name: out_memory_unit - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity padding_dual_memory_unit is
    Port ( 
        clk : in std_logic;
        ena : in std_logic;
        enb : in std_logic;
        address_a : in std_logic_vector(9 downto 0);
        address_b : in std_logic_vector(9 downto 0);
        wea : in std_logic_vector(0 downto 0);
        data_out : out std_logic_vector(7 downto 0);
        data_in : in std_logic_vector(7 downto 0)
    );
end padding_dual_memory_unit;

architecture Behavioral of padding_dual_memory_unit is

component blk_mem_gen_3 is 
    port (  
        clka : in std_logic;
        clkb : in std_logic;
        ena : in std_logic;
        enb : in std_logic;
        addra : in std_logic_vector(9 downto 0);
        addrb : in std_logic_vector(9 downto 0);
        wea : in std_logic_vector(0 downto 0);
        doutb : out std_logic_vector(7 downto 0);
        dina : in std_logic_vector(7 downto 0) 
    );
    end component;

begin

out_ram : blk_mem_gen_3
    port map (
        clka => clk,
        ena => ena,
        wea => wea,
        addra => address_a,
        clkb => clk,
        enb => enb,
        addrb => address_b,
        dina => data_in,
        doutb => data_out 
    );
    
end Behavioral;
