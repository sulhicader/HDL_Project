----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/29/2020 06:27:41 PM
-- Design Name: 
-- Module Name: tb_padding_unit - Behavioral
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

entity tb_padding_unit is
--  Port ( );
end tb_padding_unit;

architecture Behavioral of tb_padding_unit is

component padding_unit is 
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start_padding_in : in STD_LOGIC;                   
           finished_padding_out : out STD_LOGIC;                   
           input_ram_enable_out : out STD_LOGIC;
           output_ram_enable_out : out STD_LOGIC;
           input_ram_in : in STD_LOGIC_VECTOR (7 downto 0);                    
           output_ram_out : out STD_LOGIC_VECTOR (7 downto 0);                 
           input_ram_write_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);                  
           output_ram_write_enable_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);               
           input_ram_address_out : out STD_LOGIC_VECTOR (9 downto 0);   
           output_ram_address_out : out STD_LOGIC_VECTOR (9 downto 0));

end component;

component in_memory_unit is
    Port (
        clk : in std_logic;
        ena : in std_logic;
        address : in std_logic_vector(9 downto 0);
        wea : in std_logic_vector(0 downto 0);
        data_out : out std_logic_vector(7 downto 0);
        data_in : in std_logic_vector(7 downto 0) 
    );
end component;

component padding_memory_unit is
    Port (
        clk : in std_logic;
        ena : in std_logic;
        address : in std_logic_vector(9 downto 0);
        wea : in std_logic_vector(0 downto 0);
        data_out : out std_logic_vector(7 downto 0);
        data_in : in std_logic_vector(7 downto 0) 
    );
end component;

signal clk : STD_LOGIC := '0' ;
signal reset : STD_LOGIC;
signal start_padding_in : STD_LOGIC;                                      
signal finished_padding_out : STD_LOGIC;
signal input_ram_enable : std_logic;
signal input_ram_address :  std_logic_vector(9 downto 0);
signal input_ram_wea :  std_logic_vector(0 downto 0);
signal input_ram_data_out :  std_logic_vector(7 downto 0);
signal padding_ram_ena :  std_logic;
signal padding_ram_address :  std_logic_vector(9 downto 0);
signal padding_ram_wea :  std_logic_vector(0 downto 0);
signal padding_ram_data_in :  std_logic_vector(7 downto 0) ;
signal padding_data_out : std_logic_vector(7 downto 0) ;
begin

padding_1 : padding_unit 
    port map ( clk => clk,
           reset => reset,
           start_padding_in => start_padding_in,                   
           finished_padding_out => finished_padding_out,                  
           input_ram_enable_out => input_ram_enable,
           output_ram_enable_out => padding_ram_ena,
           input_ram_in => input_ram_data_out,                    
           output_ram_out => padding_ram_data_in,                
           input_ram_write_enable_out => input_ram_wea,                  
           output_ram_write_enable_out => padding_ram_wea,               
           input_ram_address_out => input_ram_address,   
           output_ram_address_out => padding_ram_address);
           

in_memory_1 : in_memory_unit 
    port map ( clk => clk,
                            
           ena => input_ram_enable,
           
           data_out => input_ram_data_out,                    
                          
           wea => input_ram_wea, 
           
           data_in => "00000000",                 
                          
           address => input_ram_address);
padding_memory_1 : padding_memory_unit 
    port map ( clk => clk,
                            
           ena => padding_ram_ena,
           
           data_out => padding_data_out,                    
                          
           wea => padding_ram_wea, 
           
           data_in => padding_ram_data_in,                 
                          
           address => padding_ram_address);           

clk <= not clk after 5ns;

stimuli : process 
        begin
            reset <= '1';
            start_padding_in <= '0';
            wait for 20ns;
            
            reset <= '0';
            start_padding_in <= '1';
            wait;
            
        end process;

end Behavioral;
