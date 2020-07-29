----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/27/2020 09:41:12 PM
-- Design Name: 
-- Module Name: main_program - Behavioral
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

entity main_unit is
  Port ( clk : in STD_LOGIC;
         reset : in STD_LOGIC;  
         padding_done_in : in STD_LOGIC;  
         max_op_done_in : in STD_LOGIC;  
         start_op_in : in STD_LOGIC;
         start_padding_op_out : out STD_LOGIC := '0';
         start_max_op_out : out STD_LOGIC := '0';
         task_finished_out : out STD_LOGIC := '0'
        );
end main_unit;

architecture Behavioral of main_unit is

type state is ( not_started, padding, max_filtering, finished );
signal curr_state : state;

begin

    state_machine : process(clk,reset)
        begin
            if (reset = '1' ) then
                curr_state  <= not_started;
                start_max_op_out <= '0';
                task_finished_out <= '0';
                start_padding_op_out <= '0';
            elsif ( clk'event and clk = '1' ) then
                case curr_state is
                    when not_started =>
                        start_max_op_out <= '0';
                        start_padding_op_out <= '0';
                        if (start_op_in = '1') then
                            curr_state<= padding;
                            start_padding_op_out <= '1';
                        end if;
                    when padding => 
                        if( padding_done_in = '1') then
                            start_padding_op_out <= '0';
                            curr_state<= max_filtering;
                            start_max_op_out <= '1';
                        end if;
                    when max_filtering =>
                        if ( max_op_done_in = '1') then
                            start_max_op_out <= '0';
                            curr_state <= finished;
                            task_finished_out <= '1';
                        end if;
                    when finished =>
                        task_finished_out <= '0';
                        curr_state <= not_started;
                    when others =>
                        curr_state <=  not_started;
                end case;
            end if;
        end process state_machine;
       
end Behavioral;
