----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/17/2020 08:43:26 PM
-- Design Name: 
-- Module Name: max_filter_unit - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity max_filter_unit is generic (
     pixel_depth_g: integer := 8;               -- size of an image pixel                                                
     input_width_g : integer := 27;             -- width of the input image for the max_filter_unit                                  
     address_width_g : integer := 10);          -- width of the address of memory unit                                                

    Port ( input_img_in : in STD_LOGIC_VECTOR (pixel_depth_g-1 downto 0);                                   -- holds input image pixel        
           output_img_out : out STD_LOGIC_VECTOR (pixel_depth_g-1 downto 0);                                -- holds output image pixel
           clk : in STD_LOGIC;                                                                              -- clk to drive max filter unit     
           rst_n : in STD_LOGIC;                                                                            -- signal to reset max filter unit
           start_op_in : in STD_LOGIC;                                                                      -- signal to start the filtering operation
           done_op_out : out STD_LOGIC;                                                                     -- goes high when filtering operation is done
           input_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);                                         -- enable pin to enable input image memory
           output_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);                                        -- enable pin to enable output image memory
           input_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0);                       -- addres of input image pixel
           output_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0));                     -- addres to write output image pixel
           
end max_filter_unit;

architecture Behavioral of max_filter_unit is

begin

convolve_image : process (clk, input_img_in, rst_n, start_op_in)
                 
    constant output_width : integer := input_width_g -2;                            -- width of output image from the filter unit                 
    constant output_img_size : integer := output_width * output_width;              -- size of the output image
    constant kernel_width : integer := 3;                                           -- width of the kernel
    constant kernel_size : integer := kernel_width * kernel_width;                  -- size of the kernel
           
    variable output_pixel_counter : integer := 0;                                   -- counter to count output image pixels
    variable kernel_pixel_counter : integer := 0;                                   -- counter to count kernel pixels to iterate within the kernel
    variable kernel_x_index : integer := 0;                                         -- horizontal position in kernel
    variable kernel_y_index : integer := 0;                                         -- vertical position in kernel
    variable img_x_index : integer := 0;                                            -- horizontal position in image
    variable img_y_index : integer := 0;                                            -- vertical position in image
    variable img_pixel : integer := 0;                                              -- holds processing pixel value            
    variable max_pixel_val : integer := 0;                                          -- holds larger pixel value within a kernel

    begin

        if (rst_n = '0') then
            output_pixel_counter := 0;
            kernel_pixel_counter := 0;
            done_op_out <= '0';
            input_img_enable_out <= "0";
            output_img_enable_out <= "0";
            
            input_img_address_out <= "0000000000";
            output_img_address_out <= "0000000000";
            img_pixel := 0;
            max_pixel_val := 0;
                    
        elsif rising_edge(clk) then
            if start_op_in = '1' then
                
                kernel_x_index := kernel_pixel_counter mod kernel_width;
                kernel_y_index := kernel_pixel_counter / kernel_width;
                img_x_index := output_pixel_counter mod output_width;
                img_y_index := output_pixel_counter / output_width;
                input_img_address_out <= std_logic_vector(to_unsigned(((img_y_index + kernel_y_index) * input_width_g) + (img_x_index +kernel_x_index), address_width_g));
                
                img_pixel := to_integer(unsigned(input_img_in));

                if (kernel_pixel_counter = 0) then                                                        
                    max_pixel_val := img_pixel;                                                       
                else
                    if (img_pixel > max_pixel_val) then
                        output_img_enable_out <= "0";  
                        max_pixel_val := img_pixel;
                    end if;
                end if;
                                
               kernel_pixel_counter := kernel_pixel_counter + 1;                                            
               
                if (kernel_pixel_counter = kernel_size) then                                              
                    kernel_pixel_counter := 0;
                    if (output_pixel_counter < output_img_size) then
                        output_img_address_out <= std_logic_vector(to_unsigned(output_pixel_counter, address_width_g));
                        output_img_out <= std_logic_vector(to_unsigned(max_pixel_val, pixel_depth_g));
                        output_img_enable_out <= "1";  
                    end if;                                                            
                    output_pixel_counter := output_pixel_counter + 1;                                       
                end if;
                
                if (output_pixel_counter = output_img_size) then
                    done_op_out <= '1';
                end if;

            end if;
        end if;

    end process convolve_image;

end Behavioral;
