----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2020 06:22:02 AM
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity padding_unit is generic (
     pixel_size_g: integer := 8;                -- size of an image pixel                                                        
     image_width_g : integer := 25;             -- width of the input image for the padding unit                   
     address_width_g : integer := 10);          -- width of the address of memory unit
 
  Port (   clk : in STD_LOGIC;                                                                          -- clock signal to drive the padding unit
           rst_n : in STD_LOGIC;                                                                        -- signal to reset the padding unit
           input_img_pixel_in : in STD_LOGIC_VECTOR (pixel_size_g-1 downto 0);                          -- holds input image pixel
           output_img_pixel_out : out STD_LOGIC_VECTOR (pixel_size_g-1 downto 0);                       -- holds output image pixel
           start_op_in : in STD_LOGIC;                                                                  -- signal tostart the padding process
           done_op_out : out STD_LOGIC;                                                                 -- goes high when the padding process is done
           input_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0);                   -- address of the input image pixel
           output_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0);                  -- address to write output image pixel
           output_img_write_en_out : out STD_LOGIC_VECTOR(0 DOWNTO 0));                                 -- signal to enable output ram
           
end padding_unit;

architecture Behavioral of padding_unit is

begin

pad_image : process (clk, input_img_pixel_in, rst_n, start_op_in)

    constant padded_img_width : integer := image_width_g +2;                                            -- width of the padded image                       
    constant padded_img_size : integer := padded_img_width * padded_img_width;                          -- size of the padded image
    variable output_pixel_counter : integer := 0;                                                       -- counter to count output image pixels
    variable pad_img_col : integer := 0;                                                                -- vertical position in padded image
    variable pad_img_row : integer := 0;                                                                -- horizontal position in padded image
    variable org_img_col : integer := 0;                                                                -- vertical position in input image
    variable org_img_row : integer := 0;                                                                -- horizontal position in input image
    variable read_delay : integer := 3;                                                                 -- holds timer to read delay
    variable write_delay : integer := 3;                                                                -- holds timer to write delay
    
    begin

        if (rst_n = '0') then
            output_pixel_counter := 0;
            read_delay := 0;
            write_delay := 0;
            done_op_out <= '0';
            output_img_write_en_out <= "0";
            input_img_address_out <= "0000000000";
            output_img_address_out <= "0000000000";
                    
        elsif rising_edge(clk) then
            if start_op_in = '1' then
            
                 if (output_pixel_counter = padded_img_size) then
                    done_op_out <= '1';
                 end if; 
                             
                 output_img_write_en_out <= "0";            
                 
                 pad_img_col := output_pixel_counter mod padded_img_width;
                 pad_img_row := output_pixel_counter / padded_img_width;
                 
                 if (pad_img_col = 0) then 
                    org_img_col := 0;
                 elsif (pad_img_col > 0 and pad_img_col < (padded_img_width - 1)) then
                    org_img_col := pad_img_col - 1;
                 end if;
            
                 if (pad_img_row = 0) then
                    org_img_row := 0;        
                 elsif (pad_img_row > 0 and pad_img_row < (padded_img_width - 1)) then
                    org_img_row := pad_img_row - 1;
                 end if;      
                 
                 if (write_delay = 0) then 
                     read_delay := 4;       
                     input_img_address_out <= std_logic_vector(to_unsigned((image_width_g*org_img_row) + org_img_col, address_width_g));
                 end if;
                     
                 if (read_delay = 0) then
                     write_delay := 4;   
                     output_img_address_out <= std_logic_vector(to_unsigned(output_pixel_counter, address_width_g));                 
                     output_img_pixel_out <= input_img_pixel_in;
                     output_img_write_en_out <= "1";
                     output_pixel_counter := output_pixel_counter + 1;
                 end if;
                     
                 read_delay := read_delay - 1;
                 write_delay := write_delay - 1;
                 
             end if;
        end if;
    end process pad_image;
end Behavioral;

