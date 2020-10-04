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
  Port (   clk : in STD_LOGIC;								-- clock to drive the controler unit
           rst_n : in STD_LOGIC;							-- reset signal to reset the controler unit
           ena_controler_in : in STD_LOGIC;                 -- enable signal for controler unit             
           done_controler_out : out STD_LOGIC := '0';       -- signal to indicate wheather the process is finished
           ena_max_filter_out : out STD_LOGIC := '0';       -- signal to enable max_filter
           done_max_filter_out : in STD_LOGIC;              -- goes high when max_filter is done
           ena_padding_out : out STD_LOGIC := '0';          -- signal to enable padding
           done_padding_in : in STD_LOGIC;                  -- goes high when padding is done
           ena_receiver_out : out STD_LOGIC := '0';         -- signal to enable receiver                     
           done_receiver_out : in STD_LOGIC;                -- goes high when receiver is done                     
           ena_transmiter_out : out STD_LOGIC := '0';       -- signal to enable transmitter                     
           done_transmiter_in : in STD_LOGIC );             -- goes high when transmitter is done                     
           
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

                -- Idle state
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
                       
                -- Receives image data through uart unit
                    when receiver =>
                        if(done_receiver_out = '1') then
                            ena_receiver_out <= '0';
                            ena_padding_out <= '1';
                            main_state <= apply_padding;
                        end if;
                
                -- Padding is applied to the image in this state
                    when apply_padding =>
                        if (done_padding_in = '1') then
                            ena_padding_out <= '0';
                            ena_max_filter_out <= '1';
                            main_state <= max_filter;
                        end if;
                        
                -- Max_filter is applied to the padded image in this state
                    when max_filter =>
                        if (done_max_filter_out = '1') then
                            ena_max_filter_out <= '0';
                            ena_transmiter_out <= '1';
                            main_state <= transmitter;
                        end if;
                      
                -- Filtered image is transmited through uart in this state  
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
