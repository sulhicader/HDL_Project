----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/30/2020 01:37:56 PM
-- Design Name: 
-- Module Name: tb_padding_unit_with_two_memory - Behavioral
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

entity tb_padding_unit_with_two_memory is
--  Port ( );
end tb_padding_unit_with_two_memory;

architecture Behavioral of tb_padding_unit_with_two_memory is

component padding_unit_with_two_memory is
  Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start_padding_in : in STD_LOGIC;                   
           finished_padding_out : out STD_LOGIC);
end component;

signal clk :  STD_LOGIC;
signal reset :  STD_LOGIC;
signal start_padding_in :  STD_LOGIC;                   
signal finished_padding_out :  STD_LOGIC ;

begin

padd_meory : padding_unit_with_two_memory
    port map ( clk => clk,
           reset => reset,
           start_padding_in => start_padding_in,                   
           finished_padding_out => finished_padding_out) ;
 
clk <= not clk after 5ns;

stimuli : process 
        begin
            reset <= '1';
            start_padding_in <= '0';
            wait for 20ns;
            
            reset <= '0';
            start_padding_in <= '1';
            wait;
            
        end process;
         

end Behavioral;
