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
             
image_shape_g : Integer := 25 --length of the input image
            ); 
             

  Port ( clk : in STD_LOGIC;
    
        reset : in STD_LOGIC;
  
        start_filter_in : in STD_LOGIC;
        
        finished_filter_out : out STD_LOGIC := '0';
        
        ram_write_enable_out : out  STD_LOGIC := '0';
        
        ram_enable_out : out  STD_LOGIC := '0';
        
        ram_initial_address_out : out STD_LOGIC_VECTOR(ram_address_length_g -1 DOWNTO 0) := std_logic_vector(to_unsigned(0, ram_address_length_g));
        
        ram_initial_data_in : out STD_LOGIC_VECTOR(pixel_size_g -1 DOWNTO 0);
        
        ram_filtered_write_enable_out : out  STD_LOGIC := '0';
        
        ram_filtered_enable_out : out  STD_LOGIC := '0';
        
        ram_filtered_address_out : out STD_LOGIC_VECTOR(ram_address_length_g -1 DOWNTO 0) := std_logic_vector(to_unsigned(0, ram_address_length_g));
        
        ram_filtered_data_out : out STD_LOGIC_VECTOR(pixel_size_g -1 DOWNTO 0) := std_logic_vector(to_unsigned(0, pixel_size_g))
  );
end max_filter_unit;

architecture Behavioral of max_filter_unit is

begin
    max_filter : process ( clk, rst_n, ram_initial_data_in, start_filter_in )
    
        constant image_size : INTEGER := 25;
        variable row_op :  INTEGER := 0;
        variable column_op :  INTEGER := 0;
        
        
        

end Behavioral;
