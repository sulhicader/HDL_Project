----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/18/2020 09:40:22 AM
-- Design Name: 
-- Module Name: controler_unit - Behavioral
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

entity controler_unit is  
  Port (   clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           ena_controler_in : in STD_LOGIC;                                      
           done_controler_out : out STD_LOGIC := '0';                            
           ena_max_filter_out : out STD_LOGIC := '0';                            
           done_max_filter_out : in STD_LOGIC;                                   
           ena_padding_out : out STD_LOGIC := '0';                               
           done_padding_in : in STD_LOGIC;                                       
           ena_receiver_out : out STD_LOGIC := '0';                              
           done_receiver_out : in STD_LOGIC;                                     
           ena_transmiter_out : out STD_LOGIC := '0';                            
           done_transmiter_in : in STD_LOGIC );                                  
           
end controler_unit;

architecture Behavioral of controler_unit is

type state is (idle, apply_padding, max_filter, receiver, transmitter);
signal main_state : state;

begin

state_machine : process (clk, ena_controler_in, rst_n, done_max_filter_out, done_padding_in, done_receiver_out, done_transmiter_in)
    begin
        --reset to initial state
        if (rst_n = '0') then
            main_state <= idle;
            done_controler_out <= '0';
            ena_max_filter_out <= '0';
            ena_padding_out <= '0';
            ena_receiver_out <= '0';
            ena_transmiter_out <= '0';

        elsif rising_edge(clk) then
                case main_state is
                    when idle =>
                        done_controler_out <= '0';
                        ena_max_filter_out <= '0';
                        ena_padding_out <= '0';  
                        ena_receiver_out <= '0';
                        ena_transmiter_out <= '0';                           
                        if (ena_controler_in = '1') then
                            ena_receiver_out <= '1';
                            main_state <= receiver; 
                        end if;
                        
                    when receiver =>
                        if(done_receiver_out = '1') then
                            ena_receiver_out <= '0';
                            ena_padding_out <= '1';
                            main_state <= apply_padding;
                        end if;
               
                    when apply_padding =>
                        if (done_padding_in = '1') then
                            ena_padding_out <= '0';
                            ena_max_filter_out <= '1';
                            main_state <= max_filter;
                        end if;
                        
                    when max_filter =>
                        if (done_max_filter_out = '1') then
                            ena_max_filter_out <= '0';
                            ena_transmiter_out <= '1';
                            main_state <= transmitter;
                        end if;
                        
                    when transmitter =>
                        if (done_transmiter_in = '1') then
                            ena_transmiter_out <= '0';
                            done_controler_out <= '1';
                            
                        end if;
                    when others =>
                        main_state <= idle;                        
                end case;
        end if;
    end process state_machine;
end Behavioral;
