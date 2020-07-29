----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/28/2020 05:48:45 PM
-- Design Name: 
-- Module Name: padding_unit - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity padding is generic (
     input_address_size_g : integer := 10;          --width/height of input image 
     pixel_size_g: integer := 8;                    --number of bits in a pixel
     input_image_size_g : integer := 25);                                                         
 
  Port (   clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start_padding_in : in STD_LOGIC;                      --enable padding_unit
           finished_padding_out : out STD_LOGIC;                    --enable the out
           input_ram_enable_out : out STD_LOGIC;
           output_ram_enable_out : out STD_LOGIC;
           input_ram_in : in STD_LOGIC_VECTOR (pixel_size_g-1 downto 0);                    
           output_ram_out : out STD_LOGIC_VECTOR (pixel_size_g-1 downto 0);                 
           input_ram_write_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);                     --enable writing values to input ram
           output_ram_write_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);                    --enable writing values to output ram
           input_ram_address_out : out STD_LOGIC_VECTOR (input_address_size_g-1 downto 0);   --address for reading values from input ram
           output_ram_address_out : out STD_LOGIC_VECTOR (input_address_size_g-1 downto 0));     --address for writing values to output ram
           
           
end padding;

architecture Behavioral of padding is

begin

padding_process : process (clk, reset, start_padding_in)

    --define constants and variables used for padding process
    constant original_image_size : integer := input_image_size_g * input_image_size_g;                     --size of input image in pixels
    constant padded_image_size : integer := (input_image_size_g +2) * (input_image_size_g +2);                                  --width of output image in pixels
    variable current_pixel_count : integer := 0;                                       --used for stepping through each pixel in output image (0 -> output_img_size)
    variable original_raw : integer := 0;                                                --horizontal index of output image pixel
    variable original_column : integer := 0;                                                --vertical index of output image pixel
    variable padded_row : integer := 0;                                                --horizontal index of output image pixel
    variable padded_column : integer := 0;                                                --vertical index of output image pixel
    variable read_delay : integer := 3;                                                 --ram read delay counter
    variable write_delay : integer := 3;                                                --ram write delay counter
    
    begin
    
    --rst_n to initial state
        if (reset = '0') then
            current_pixel_count := 0;
            padded_row := 0;
            padded_column := 0;
            read_delay := 0;
            write_delay := 0;
            finished_padding_out <= '0';
            input_ram_enable_out <= '0';
            output_ram_enable_out <= '0';
            input_ram_address_out <= "0000000000";
            output_ram_address_out <= "0000000000";
                    
        elsif rising_edge(clk) then
            if start_padding_in = '1' then
            
                 
                 if (current_pixel_count = padded_image_size) then
                    finished_padding_out <= '1';
                 end if; 
                             
                 output_ram_enable_out <= '0';              
                 
                 if (padded_row=0 or padded_row=input_image_size_g+1 or padded_column=0 or padded_column=input_image_size_g+1) then
                    if (read_delay=0) then 
                        write_delay :=4;
                        output_ram_enable_out <= '0';
                        output_ram_write_enable_out <= "0";
                        output_ram_address_out <= std_logic_vector(to_unsigned(current_pixel_count, input_address_size_g));
                        output_ram_out <= "00000000";
                        output_ram_enable_out <= '1';
                        output_ram_write_enable_out <= "1";
                    end if;
                    current_pixel_count:= current_pixel_count+1;
                    if (padded_column = input_image_size_g+1) then
                        padded_column := 0;
                        padded_row := padded_row+1;
                    else
                        padded_column := padded_column+1;
                    end if;  
                 end if;
                 
                 else
                     if (write_delay = 0) then 
                         read_delay := 4;       
                         input_ram_address_out <= std_logic_vector(to_unsigned((input_image_size_g*padded_row) + padded_column, input_address_size_g));
                         input_ram_enable_out <= '1';
                         input_ram_write_enable_out <= "0";
                        
                     end if;

                     if (read_delay = 0) then
                         write_delay := 4;   
                         output_ram_address_out <= std_logic_vector(to_unsigned(current_pixel_count, input_address_size_g));               
                         output_ram_out <= input_ram_in;
                         output_ram_enable_out <= '1';
                         output_ram_write_enable_out <= "1"; 
                         current_pixel_count := current_pixel_count + 1;
                         padded_column := padded_column+1;
                     end if;
                        
                     
                 read_delay := read_delay - 1;
                 write_delay := write_delay - 1;
                 
             end if;
        end if;
    end process padding_process;
end Behavioral;