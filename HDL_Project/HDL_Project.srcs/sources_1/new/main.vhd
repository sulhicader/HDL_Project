----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/18/2020 10:14:35 AM
-- Design Name: 
-- Module Name: main - Behavioral
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

entity main is
    Port ( clk : in STD_LOGIC;                            -- clock to drive entire system
         rst_n : in STD_LOGIC;                            -- reset signal for the entire system
         enable_max_filter_in : in STD_LOGIC;             -- enable signal for the system
         max_filter_done_out : out STD_LOGIC := '0';      -- goes high when the system finishes the filtering operation
         rx_in : in STD_LOGIC;                            -- rx pin of uart communication module
         tx_out : out STD_LOGIC );                        -- tx pin of uart communication module
end main;

architecture Behavioral of main is

component blk_mem_gen_0 is 
  port (clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
end component;

component blk_mem_gen_1 is 
  Port (clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
end component;

component blk_mem_gen_2 is 
  Port (clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
end component;

component padding_unit is 
    generic (
        pixel_size_g: integer := 8;           -- size of an image pixel                                                             
        input_width_g : integer := 25;        -- width of the input image for the component                     
        address_width_g : integer := 10);     -- width of the address of memory unit       
      
    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           input_img_pixel_in : in STD_LOGIC_VECTOR (pixel_size_g-1 downto 0);                   
           output_img_pixel_out : out STD_LOGIC_VECTOR (pixel_size_g-1 downto 0);                
           start_op_in : in STD_LOGIC;                                                         
           done_op_out : out STD_LOGIC;                                                       
           input_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0);        
           output_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0);                        
           output_img_write_en_out : out STD_LOGIC_VECTOR(0 DOWNTO 0)); 
end component; 

component max_filter_unit is 
    generic (
        pixel_size_g: integer := 8;           -- size of an image pixel                                                     
        input_width_g : integer := 27;        -- width of the input image for the component                                             
        address_width_g : integer := 10);     -- width of the address of memory unit                                             
                                        
    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;                 
           input_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0);
           input_img_in : in STD_LOGIC_VECTOR (pixel_size_g-1 downto 0);                 
           output_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);    
           output_img_address_out : out STD_LOGIC_VECTOR (address_width_g-1 downto 0);                 
           output_img_out : out STD_LOGIC_VECTOR (pixel_size_g-1 downto 0);
           start_op_in : in STD_LOGIC;                                                
           done_op_out : out STD_LOGIC);                                              
--           input_img_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0););        
end component;

component uart_com_unit is generic (
     pixel_size_g: integer := 8;              -- size of an image pixel                                       
     input_width_g : integer := 25;           -- width of the input image for the component                                        
     address_width_g : integer := 10);        -- width of the address of memory unit                                       

    Port (  clk : in std_logic;
            rst_n : in std_logic;
            rx : IN STD_LOGIC;
            tx : OUT STD_LOGIC;
            ena_recv : in std_logic;
            ena_transmit : in std_logic;
            done_recv : out std_logic;
            done_transmit : out std_logic;
            write_en : out std_logic_vector(0 downto 0) := "0";
            data_in : in std_logic_vector(pixel_size_g -1 downto 0); --data out of ram
            data_out : out std_logic_vector(pixel_size_g -1 downto 0) := std_logic_vector(to_unsigned(0, pixel_size_g)); --data in of ram
            in_mem_address : out std_logic_vector(address_width_g -1 downto 0) := std_logic_vector(to_unsigned(0, address_width_g));
            out_mem_address : out std_logic_vector(address_width_g -1 downto 0) := std_logic_vector(to_unsigned(0, address_width_g)));      
    end component;          

component controler_unit is
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
end component;

-- signals to hold the intermediate values 

signal input_img_padding : STD_LOGIC_VECTOR (7 downto 0);                    
signal output_img_padding : STD_LOGIC_VECTOR (7 downto 0);                  
signal enable_padding : STD_LOGIC;                                      
signal done_padding : STD_LOGIC;                                    
--signal input_img_ena_padding : STD_LOGIC_VECTOR(0 DOWNTO 0);           
signal output_img_ena_padding : STD_LOGIC_VECTOR(0 DOWNTO 0);          
signal input_img_address_padding : STD_LOGIC_VECTOR (9 downto 0);         
signal output_img_address_padding : STD_LOGIC_VECTOR (9 downto 0);  

signal input_img_filter : STD_LOGIC_VECTOR (7 downto 0);                    
signal output_img_filter : STD_LOGIC_VECTOR (7 downto 0);                  
signal enable_filter : STD_LOGIC;                                      
signal done_filter : STD_LOGIC;                                    
--signal input_img_ena_filter : STD_LOGIC_VECTOR(0 DOWNTO 0);           
signal output_img_ena_filter : STD_LOGIC_VECTOR(0 DOWNTO 0);          
signal input_img_address_filter : STD_LOGIC_VECTOR (9 downto 0);         
signal output_img_address_filter : STD_LOGIC_VECTOR (9 downto 0);  

signal input_img_uart : STD_LOGIC_VECTOR (7 downto 0);                 
signal output_img_uart : STD_LOGIC_VECTOR (7 downto 0);                  
signal read_en : STD_LOGIC;                                                      
signal write_en : STD_LOGIC;                                                   
signal read_done : STD_LOGIC;                                                   
signal write_done : STD_LOGIC;                                                  
--signal input_img_ena_uart : STD_LOGIC_VECTOR(0 DOWNTO 0);                        
signal output_img_ena_uart : STD_LOGIC_VECTOR(0 DOWNTO 0);                        
signal input_img_address_uart : STD_LOGIC_VECTOR (9 downto 0);         
signal output_img_address_uart : STD_LOGIC_VECTOR (9 downto 0);

begin

-- Port mapping of all the components
input_ram : blk_mem_gen_0
        port map ( clka => clk,                                    
                   clkb => clk,                     
                   wea => output_img_ena_uart,                 
                   addra => output_img_address_uart,
                   dina => output_img_uart,         
                   addrb => input_img_address_padding,
                   doutb => input_img_padding); 

padded_ram : blk_mem_gen_2
        port map ( clka => clk,                                    
                   clkb => clk,                     
                   wea => output_img_ena_padding,                 
                   addra => output_img_address_padding,
                   dina => output_img_padding,         
                   addrb => input_img_address_filter,
                   doutb => input_img_filter); 
                   
output_ram : blk_mem_gen_1
        port map ( clka => clk,                                    
                   clkb => clk,                     
                   wea => output_img_ena_filter,                 
                   addra => output_img_address_filter,
                   dina => output_img_filter,         
                   addrb => input_img_address_uart,
                   doutb => input_img_uart); 
                              
padding_1 : padding_unit
        port map ( clk => clk,    
                   rst_n => rst_n,  
                   input_img_pixel_in => input_img_padding,
                   output_img_pixel_out => output_img_padding,
                   start_op_in => enable_padding,
                   done_op_out => done_padding,
                   input_img_address_out => input_img_address_padding,
                   output_img_address_out => output_img_address_padding,
                   output_img_write_en_out => output_img_ena_padding);
                   
filter_1 : max_filter_unit
        port map ( clk => clk,    
                   rst_n => rst_n,  
                   input_img_in => input_img_filter,
                   output_img_out => output_img_filter,
                   start_op_in => enable_filter,
                   done_op_out => done_filter,
                   input_img_address_out => input_img_address_filter,
                   output_img_address_out => output_img_address_filter,
                   output_img_enable_out => output_img_ena_filter);

uart_com_1 : uart_com_unit
        port map ( clk => clk,
                   rst_n => rst_n,  
                   rx => rx_in, 
                   tx => tx_out,
                   ena_recv => write_en,
                   ena_transmit => read_en,
                   write_en => output_img_ena_uart,
                   done_recv => write_done,
                   done_transmit => read_done,
                   data_in => input_img_uart, 
                   data_out => output_img_uart, 
                   in_mem_address => input_img_address_uart,
                   out_mem_address => output_img_address_uart);
        
controler_1 : controler_unit
        port map ( clk => clk,
                   rst_n => rst_n,
                   ena_controler_in => enable_max_filter_in,
                   done_controler_out => max_filter_done_out,
                   ena_max_filter_out => enable_filter,
                   done_max_filter_out => done_filter,
                   ena_padding_out => enable_padding,
                   done_padding_in => done_padding,
                   ena_receiver_out => write_en,
                   done_receiver_out => write_done, 
                   ena_transmiter_out => read_en,
                   done_transmiter_in => read_done);

end Behavioral;
