----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/28/2020 06:04:34 PM
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity max_filter_unit is
  Generic ( ram_address_length_g : Integer := 10; --size of the memory address(10bits)
            pixel_size_g : Integer := 8; --size of the pixel data (8bits)
            padded_image_width_g : Integer := 27;
            output_image_width_g : Integer := 25);

             

  Port ( clk : in STD_LOGIC;
    
        reset : in STD_LOGIC;
  
        start_filter_in : in STD_LOGIC;
        
        finished_filter_out : out STD_LOGIC := '0';
        
        ram_write_enable_out : out  STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
        
        ram_enable_out : out  STD_LOGIC := '0';
        
        ram_initial_address_out : out STD_LOGIC_VECTOR(ram_address_length_g-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(0, ram_address_length_g));
        
        ram_initial_data_in : in STD_LOGIC_VECTOR(pixel_size_g -1 DOWNTO 0);
        
        ram_filtered_write_enable_out : out  STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
        
        ram_filtered_enable_out : out  STD_LOGIC := '0';
        
        ram_filtered_address_out : out STD_LOGIC_VECTOR(ram_address_length_g -1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(0, ram_address_length_g));
        
        ram_filtered_data_out : out STD_LOGIC_VECTOR(pixel_size_g -1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(0, pixel_size_g))
  );
end max_filter_unit;

architecture Behavioral of max_filter_unit is

begin
    max_filter : process ( clk, reset, ram_initial_data_in, start_filter_in )
    
        constant image_size : INTEGER := 625;
        variable row_op :  INTEGER := 0;
        variable kernal_count : INTEGER := 0;
        variable column_op :  INTEGER := 0;
        variable sub_row : INTEGER := 0;
        variable sub_column : INTEGER := 0;
        variable current_pixel_reading : INTEGER := 0;
        variable current_pixel_count : INTEGER := 0;
        variable max_pixel_value :  STD_LOGIC_VECTOR( 7 DOWNTO 0 ) := "00000000";
        variable current_pixel_value : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
        
    begin
        if (reset = '0') then
            row_op := 0;
            column_op := 0;
            kernal_count := 0;
            sub_row := 0;
            sub_column := 0;
            current_pixel_count :=  0;
            max_pixel_value :=  "00000000";
            finished_filter_out <= '0';
            ram_filtered_write_enable_out <= "0";
        elsif ( clk 'event and clk = '1' ) then
            if start_filter_in = '1' then
                if (current_pixel_count = image_size) then
                    finished_filter_out <= '1';
                
                else
                    if (kernal_count < 8 ) then
                        current_pixel_reading := (row_op+sub_row)*padded_image_width_g + column_op + sub_column;
                        ram_initial_address_out <= std_logic_vector(to_unsigned(current_pixel_reading, ram_address_length_g));
                        ram_write_enable_out <= "0";
                        ram_enable_out <= '1';
                        current_pixel_value := ram_initial_data_in ;
                        if (current_pixel_value > max_pixel_value) then
                            max_pixel_value := current_pixel_value;
                        end if;
                        
                        kernal_count := kernal_count + 1;
                        if (sub_column = 2) then
                             sub_column := 0;
                             sub_row := sub_row+1;
                        else
                            sub_column := sub_column+1;
                        end if;
                        
                        
                    else
                        ram_filtered_address_out <= std_logic_vector(to_unsigned(current_pixel_count, ram_address_length_g));
                        ram_filtered_data_out <= std_logic_vector(max_pixel_value); 
                        ram_filtered_write_enable_out <= "0";
                        ram_filtered_enable_out <= '1'; 
                        kernal_count := 0;
                        current_pixel_count := current_pixel_count+1;
                        sub_row := 0;
                        sub_column := 0;
                        if  (column_op = output_image_width_g-1) then
                            column_op := 0;
                            row_op := row_op+1;
                        else
                            column_op := column_op+1;
                        end if; 
                           
                                     
                    end if;  
                end if;
            end if;
        end if;
    end process;
                
            

end Behavioral;
