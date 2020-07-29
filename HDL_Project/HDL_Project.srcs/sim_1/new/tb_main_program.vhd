----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/29/2020 10:08:19 PM
-- Design Name: 
-- Module Name: tb_main_program - Behavioral
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

entity tb_main_program is
--  Port ( );
end tb_main_program;

architecture Behavioral of tb_main_program is

component main_unit is 
    Port ( clk : in STD_LOGIC;
         reset : in STD_LOGIC;  
         padding_done_in : in STD_LOGIC;  
         max_op_done_in : in STD_LOGIC;  
         start_op_in : in STD_LOGIC;
         start_padding_op_out : out STD_LOGIC := '0';
         start_max_op_out : out STD_LOGIC := '0';
         task_finished_out : out STD_LOGIC := '0'
        );
end component;

signal clk : STD_LOGIC := '1';
signal reset : STD_LOGIC;
signal padding_done_in : STD_LOGIC;  
signal max_op_done_in :  STD_LOGIC;  
signal start_op_in :  STD_LOGIC;
signal start_padding_op_out :  STD_LOGIC := '0';
signal start_max_op_out :  STD_LOGIC := '0';
signal task_finished_out :  STD_LOGIC := '0';

begin

    main_1 : main_unit
        port map (
         clk => clk,
         reset => reset,  
         padding_done_in => padding_done_in, 
         max_op_done_in => max_op_done_in,  
         start_op_in => start_op_in,
         start_padding_op_out => start_padding_op_out,
         start_max_op_out => start_max_op_out,
         task_finished_out => task_finished_out
        );

    clk <= not clk after 5ns;

    stimuli_1 : process 
        begin
            reset <= '1';
            start_op_in <= '0';
            wait for 20ns;
            
            reset <= '0';
            start_op_in <= '1';
            wait for 20ns;
            
            padding_done_in <= '1';
            wait for 100ns;
            
            max_op_done_in <= '1';
            wait for 200ns;
            
        end process;
end Behavioral;
