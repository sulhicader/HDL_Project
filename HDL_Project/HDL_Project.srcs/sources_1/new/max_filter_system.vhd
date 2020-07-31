----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/30/2020 04:34:50 PM
-- Design Name: 
-- Module Name: max_filter_system - Behavioral
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

entity max_filter_system is
 Port ( clk : in std_logic;
        reset : in STD_LOGIC;
        start_op_in : in STD_LOGIC;
        task_finished_out : out STD_LOGIC := '0'
  );
end max_filter_system;

architecture Behavioral of max_filter_system is

component in_memory_unit is
    Port (
        clk : in std_logic;
        ena : in std_logic;
        address : in std_logic_vector(9 downto 0);
        wea : in std_logic_vector(0 downto 0);
        data_out : out std_logic_vector(7 downto 0);
        data_in : in std_logic_vector(7 downto 0));

end component;

component out_memory_unit is
    Port ( 
        clk : in std_logic;
        ena : in std_logic;
        address : in std_logic_vector(9 downto 0);
        wea : in std_logic_vector(0 downto 0);
        data_out : out std_logic_vector(7 downto 0);
        data_in : in std_logic_vector(7 downto 0)
 );

end component;

component padding_dual_memory_unit is
    Port ( 
        clk : in std_logic;
        ena : in std_logic;
        enb : in std_logic;
        address_a : in std_logic_vector(9 downto 0);
        address_b : in std_logic_vector(9 downto 0);
        wea : in std_logic_vector(0 downto 0);
        data_out : out std_logic_vector(7 downto 0);
        data_in : in std_logic_vector(7 downto 0)
    );
end component;

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

component main_unit is
  Port ( clk : in STD_LOGIC ;
         reset : in STD_LOGIC;  
         padding_done_in : in STD_LOGIC;  
         max_op_done_in : in STD_LOGIC;  
         start_op_in : in STD_LOGIC;
         start_padding_op_out : out STD_LOGIC ;
         start_max_op_out : out STD_LOGIC ;
         task_finished_out : out STD_LOGIC 
        );

end component;

component max_filter_unit is
    Port ( clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        start_filter_in : in STD_LOGIC;
        finished_filter_out : out STD_LOGIC;
        ram_enable_out : out  STD_LOGIC ;
        ram_initial_address_out : out STD_LOGIC_VECTOR(9 DOWNTO 0) ;
        ram_initial_data_in : in STD_LOGIC_VECTOR( 7 DOWNTO 0);
        ram_filtered_write_enable_out : out  STD_LOGIC_VECTOR(0 DOWNTO 0) ;
        ram_filtered_enable_out : out  STD_LOGIC ;
        ram_filtered_address_out : out STD_LOGIC_VECTOR(9 DOWNTO 0) ;
        ram_filtered_data_out : out STD_LOGIC_VECTOR(7 DOWNTO 0) 
  );

end component;

signal start_padding :  STD_LOGIC;                   
signal finished_padding_out :  STD_LOGIC;
signal input_ram_enable : std_logic;
signal input_ram_address :  std_logic_vector(9 downto 0);
signal input_ram_wea :  std_logic_vector(0 downto 0);
signal input_ram_data_out :  std_logic_vector(7 downto 0);
signal padding_ram_ena :  std_logic;
signal padding_ram_address :  std_logic_vector(9 downto 0);
signal padding_ram_wea :  std_logic_vector(0 downto 0);
signal padding_ram_data_in :  std_logic_vector(7 downto 0) ;
signal max_op_finished :  STD_LOGIC;
signal max_op_start :  STD_LOGIC;
signal ram_padded_write_enable  : std_logic_vector(0 downto 0);
signal ram_padded_enable  : STD_LOGIC;
signal ram_padded_address  : std_logic_vector(9 downto 0);
signal ram_padded_data  : std_logic_vector(7 downto 0);
signal ram_filtered_write_enable  : std_logic_vector(0 downto 0);
signal ram_filtered_enable  : STD_LOGIC;
signal ram_filtered_address  : std_logic_vector(9 downto 0);
signal ram_filtered_data  : std_logic_vector(7 downto 0);
signal out_ram_data_out :   std_logic_vector(7 downto 0);

begin

main_unit_1 : main_unit
    port map ( clk => clk,
         reset => reset,  
         padding_done_in => finished_padding_out,  
         max_op_done_in => max_op_finished,  
         start_op_in => start_op_in,
         start_padding_op_out => start_padding,
         start_max_op_out => max_op_start,
         task_finished_out => task_finished_out
);
padding_2 : padding_unit 
    port map ( clk => clk,
           reset => reset,
           start_padding_in => start_padding,                   
           finished_padding_out => finished_padding_out,                  
           input_ram_enable_out => input_ram_enable,
           output_ram_enable_out => padding_ram_ena,
           input_ram_in => input_ram_data_out,                    
           output_ram_out => padding_ram_data_in,                
           input_ram_write_enable_out => input_ram_wea,                  
           output_ram_write_enable_out => padding_ram_wea,               
           input_ram_address_out => input_ram_address,   
           output_ram_address_out => padding_ram_address);
           
in_memory_2 : in_memory_unit 
    port map ( clk => clk,                
           ena => input_ram_enable,
           data_out => input_ram_data_out,                                 
           wea => input_ram_wea, 
           data_in => "00000000",                              
           address => input_ram_address);
           
padding_memory_2 : padding_dual_memory_unit 
    Port map ( 
        clk => clk,
        ena => padding_ram_ena,
        enb => ram_padded_enable,
        address_a =>padding_ram_address,
        address_b => ram_padded_address,
        wea => padding_ram_wea,
        data_out =>ram_padded_data,
        data_in =>padding_ram_data_in
    );


out_memory_1 : out_memory_unit 
    Port map ( 
        clk => clk,
        ena => ram_filtered_enable,
        address => ram_filtered_address,
        wea => ram_filtered_write_enable,
        data_out => out_ram_data_out,
        data_in => ram_filtered_data
 );

max_filter_unit_1 : max_filter_unit
    Port map ( clk => clk,
        reset => reset,
        start_filter_in => max_op_start,
        finished_filter_out => max_op_finished,
        ram_enable_out => ram_padded_enable,
        ram_initial_address_out => ram_padded_address,
        ram_initial_data_in => ram_padded_data,
        ram_filtered_write_enable_out => ram_filtered_write_enable,
        ram_filtered_enable_out => ram_filtered_enable,
        ram_filtered_address_out => ram_filtered_address,
        ram_filtered_data_out => ram_filtered_data
  );
end Behavioral;

