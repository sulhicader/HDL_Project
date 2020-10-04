----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/18/2020 10:13:06 AM
-- Design Name: 
-- Module Name: uart_com_unit - Behavioral
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

entity uart_com_unit is
--  Port ( );
    Generic (mem_addr_size_g : integer := 10;
             pixel_data_size_g : integer := 8;
             base_val_g : integer := 0);
             
    PORT (
        clk : in std_logic;
        rst_n : in std_logic;
        rx : IN STD_LOGIC;
        tx : OUT STD_LOGIC;
        ena_recv : in std_logic;
        ena_transmit : in std_logic;
        done_recv : out std_logic;
        done_transmit : out std_logic;
        write_en : out std_logic_vector(0 downto 0) := "0";
--        start_op : in std_logic;
--        done_op : out std_logic;
--        send_recv_sel : in std_logic;
--        write_en : out std_logic_vector(0 downto 0) := "0";
        data_in : in std_logic_vector(pixel_data_size_g -1 downto 0); --data out of ram
        data_out : out std_logic_vector(pixel_data_size_g -1 downto 0) := std_logic_vector(to_unsigned(base_val_g, pixel_data_size_g)); --data in of ram
        in_mem_address : out std_logic_vector(mem_addr_size_g -1 downto 0) := std_logic_vector(to_unsigned(base_val_g, mem_addr_size_g));
        out_mem_address : out std_logic_vector(mem_addr_size_g -1 downto 0) := std_logic_vector(to_unsigned(base_val_g, mem_addr_size_g)));
        
end uart_com_unit;

architecture Behavioral of uart_com_unit is

signal sig_interrupt : STD_LOGIC;
signal sig_s_axi_awaddr : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
signal sig_s_axi_awvalid : STD_LOGIC := '0';
signal sig_s_axi_awready : STD_LOGIC;
signal sig_s_axi_wdata : STD_LOGIC_VECTOR(31 DOWNTO 0) := std_logic_vector(to_unsigned(base_val_g, 32));
signal sig_s_axi_wstrb : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
signal sig_s_axi_wvalid : STD_LOGIC := '0';
signal sig_s_axi_wready : STD_LOGIC ;
signal sig_s_axi_bresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
signal sig_s_axi_bvalid : STD_LOGIC;
signal sig_s_axi_bready : STD_LOGIC := '0';
signal sig_s_axi_araddr : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
signal sig_s_axi_arvalid : STD_LOGIC := '0';
signal sig_s_axi_arready : STD_LOGIC;
signal sig_s_axi_rdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal sig_s_axi_rresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
signal sig_s_axi_rvalid : STD_LOGIC;
signal sig_s_axi_rready : STD_LOGIC := '0';

component axi_uartlite_0 is
     PORT (
        s_axi_aclk : IN STD_LOGIC;
        s_axi_aresetn : IN STD_LOGIC;
        interrupt : OUT STD_LOGIC;
        s_axi_awaddr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        s_axi_awvalid : IN STD_LOGIC;
        s_axi_awready : OUT STD_LOGIC;
        s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        s_axi_wvalid : IN STD_LOGIC;
        s_axi_wready : OUT STD_LOGIC;
        s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        s_axi_bvalid : OUT STD_LOGIC;
        s_axi_bready : IN STD_LOGIC;
        s_axi_araddr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        s_axi_arvalid : IN STD_LOGIC;
        s_axi_arready : OUT STD_LOGIC;
        s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        s_axi_rvalid : OUT STD_LOGIC;
        s_axi_rready : IN STD_LOGIC;        
        rx : IN STD_LOGIC;
        tx : OUT STD_LOGIC
      );
end component;

type state is (Idle, Set_CTRL_Reg, 
                Fetching, Sending, 
                Receiving, Storing, 
                Incrementing_Send, Incrementing_Rec, 
                Done);

type axi_rx_state is (Interrupt_wait,
                        Set_rx_write_up,
                        Wait_rx_ready,
                        Get_rx_data,
                        Set_read_ready_high,
                        Set_read_ready_low);
                        
type axi_tx_state is (Set_tx_write_up,
                        Wait_tx_ready,
                        Set_tx_write_down,
                        Set_write_resp_up_tx,
                        Set_write_resp_down_tx,
                        Wait_tx_done);
                        
type axi_cr_state is (Set_cr_write_up,
                        Wait_cr_ready,
                        Set_cr_write_down,
                        Set_write_resp_up_cr,
                        Set_write_resp_down_cr,
                        Set_cr_normal);
                        
signal main_state : state;
signal rx_state : axi_rx_state;
signal tx_state : axi_tx_state;
signal cr_state : axi_cr_state;

signal pixel_value : STD_LOGIC_VECTOR (pixel_data_size_g -1 downto 0);
signal send_op : std_logic;
--signal write_en : std_logic_vector(0 downto 0) := "0";

begin
uart_component : axi_uartlite_0
    port map(
        s_axi_aclk => clk,
        s_axi_aresetn => rst_n,
        interrupt => sig_interrupt,
        s_axi_awaddr => sig_s_axi_awaddr,
        s_axi_awvalid => sig_s_axi_awvalid,
        s_axi_awready => sig_s_axi_awready,
        s_axi_wdata => sig_s_axi_wdata,
        s_axi_wstrb => sig_s_axi_wstrb,
        s_axi_wvalid => sig_s_axi_wvalid,
        s_axi_wready => sig_s_axi_wready,
        s_axi_bresp => sig_s_axi_bresp,
        s_axi_bvalid => sig_s_axi_bvalid,
        s_axi_bready => sig_s_axi_bready,
        s_axi_araddr => sig_s_axi_araddr,
        s_axi_arvalid => sig_s_axi_arvalid,
        s_axi_arready => sig_s_axi_arready,
        s_axi_rdata => sig_s_axi_rdata,
        s_axi_rresp => sig_s_axi_rresp,
        s_axi_rvalid => sig_s_axi_rvalid,
        s_axi_rready => sig_s_axi_rready,
        rx => rx,
        tx => tx
    );

    process (clk, rst_n)
        constant mem_size : integer := 100;
        constant write_delay : integer := 3;
        constant read_delay : integer := 3;
        variable mem_adrs : integer := 0;
        variable write_wait : integer := 0;
        variable read_wait : integer := 0;
        variable clear_rx_tx : STD_LOGIC := '1';
        
        begin
            if (rst_n = '0') then
                main_state <= Idle;
                pixel_value <= std_logic_vector(to_unsigned(base_val_g, pixel_value 'length));
                mem_adrs := 0;
                write_wait := 0;
                clear_rx_tx := '1';
                done_recv <= '0';
                done_transmit <= '0';
--                done_op <= '0';
                send_op <= '1';
            elsif (clk 'event and clk = '1') then
                case main_state is
                    when Idle =>
                        write_en <= "0";
                        done_recv <= '0';
                        done_transmit <= '0';
--                        done_op <= '0';
                        pixel_value <= std_logic_vector(to_unsigned(base_val_g, pixel_value 'length));
                        
                        if (ena_recv = '1') then
                            send_op <= '0';
                        elsif (ena_transmit = '1') then
                            send_op <= '1';
                        end if;
                        main_state <= Set_CTRL_Reg;
                        cr_state <= Set_CR_Write_Up;
                        clear_rx_tx := '1';
                        
                    
                    when Set_CTRL_Reg =>
                        case cr_state is
                            when Set_CR_Write_Up =>
                                sig_s_axi_awaddr <= "1100";
                                sig_s_axi_wstrb <= "0001";
                                if (clear_rx_tx = '1') then
                                    sig_s_axi_wdata <= "00000000000000000000000000010011";
                                else
                                    sig_s_axi_wdata <= "00000000000000000000000000010000";
                                end if;
                                sig_s_axi_awvalid <= '1';
                                sig_s_axi_wvalid <= '1';
                                cr_state <= Wait_CR_Ready;
                            when Wait_CR_Ready =>
                                if (sig_s_axi_awready = '1' and sig_s_axi_wready = '1') then
                                    cr_state <= Set_CR_Write_Down;
                                end if;
                            when Set_CR_Write_Down =>
                                sig_s_axi_awvalid <= '0';
                                sig_s_axi_wvalid <= '0';
                                cr_state <= Set_write_resp_up_cr;
                            when Set_Write_Resp_Up_cr =>
                                if (sig_s_axi_bvalid = '1') then
                                    sig_s_axi_bready <= '1';
                                    cr_state <= Set_Write_Resp_Down_cr;
                                end if;
                            when Set_Write_Resp_Down_cr =>
                                sig_s_axi_bready <= '0';
                                cr_state <= Set_CR_Normal;
                            when Set_CR_Normal =>
                                if (clear_rx_tx = '1') then
                                    clear_rx_tx := '0';
                                    cr_state <= Set_CR_Write_Up;
                                else
                                    if (send_op = '0') then
                                        main_state <= Receiving;
                                        rx_state <= Interrupt_wait;
                                    else
                                        main_state <= Fetching;
                                    end if;
                                end if;
                            when others =>
                                null;
                        end case;
                    
                    when Receiving =>
                        case rx_state is
                            when Interrupt_wait =>
                                if(sig_interrupt = '1') then
                                    rx_state <= Set_Rx_Write_Up;
                                end if;
                            when Set_Rx_Write_Up =>
                                sig_s_axi_araddr <= "0000";
                                sig_s_axi_arvalid <= '1';
                                rx_state <= Wait_Rx_Ready;
                            when Wait_Rx_Ready =>
                                if (sig_s_axi_arready = '1') then
                                    rx_state <= Get_Rx_Data;
                                end if;
                            when Get_Rx_Data =>
                                sig_s_axi_arvalid <= '0';
                                rx_state <= Set_Read_Ready_High;
                            when Set_Read_Ready_High =>
                                sig_s_axi_rready<='1';
                                if (sig_s_axi_rvalid = '1') then
                                    pixel_value <= std_logic_vector(resize(unsigned(sig_s_axi_rdata), data_out 'length));
                                    rx_state <= Set_Read_Ready_Low;
                                end if;
                            when Set_Read_Ready_Low =>
                                sig_s_axi_rready <= '0';
                                rx_state <= Interrupt_wait;
                                main_state <= Storing;
                            when others =>
                                null;
                        end case;
                        
                    when Storing =>
                        if (write_wait = 0) then
                            in_mem_address <= std_logic_vector(to_unsigned(mem_adrs, in_mem_address 'length));
                            data_out <= pixel_value;
                            write_en <= "1";
                            write_wait := 1;
                        elsif (write_wait = write_delay) then
                            write_en <= "0";
                            write_wait := 0;
                            main_state <= Incrementing_Rec;
                        else
                            write_wait := write_wait + 1;
                        end if;
                        
                    when Fetching =>
                        if (read_wait = 0) then
                            write_en <= "0";
                            out_mem_address <= std_logic_vector(to_unsigned(mem_adrs, out_mem_address 'length));
                            read_wait := 1;
                        elsif (read_wait = read_delay) then
                            pixel_value <= data_in;
                            read_wait := 0;
                            main_state <= Sending;
                            tx_state <= Set_Tx_Write_Up;
                        else
                            read_wait := read_wait + 1;
                        end if;
                    
                    when Sending =>
                        case tx_state is
                            when Set_Tx_Write_Up =>
                                sig_s_axi_awaddr <= "0100";
                                sig_s_axi_wdata <= std_logic_vector(resize(unsigned(pixel_value), sig_s_axi_wdata 'length));
                                sig_s_axi_awvalid <= '1';
                                sig_s_axi_wvalid <= '1';
                                tx_state <= Wait_Tx_Ready;
                            when Wait_Tx_Ready =>
                                if (sig_s_axi_awready = '1' and sig_s_axi_wready = '1') then
                                    tx_state <= Set_Tx_Write_Down;
                                end if;
                            when Set_Tx_Write_Down =>
                                sig_s_axi_awvalid <= '0';
                                sig_s_axi_wvalid <= '0';
                                tx_state <= Set_Write_Resp_Up_tx;
                            when Set_Write_Resp_Up_tx =>
                                if (sig_s_axi_bvalid = '1') then
                                    sig_s_axi_bready <= '1';
                                    tx_state <= Set_Write_Resp_Down_tx;
                                end if;
                            when Set_Write_Resp_Down_tx =>
                                sig_s_axi_bready <= '0';
                                tx_state <= Wait_Tx_Done;
                            when Wait_Tx_Done =>
                                if (sig_interrupt = '1') then
                                    tx_state <= Set_Tx_Write_Up;
                                    main_state <= Incrementing_Send;
                                end if;
                            when others =>
                                null;
                        end case;
                        
                    when Incrementing_Rec =>
                        write_en <= "0";
                        if (mem_adrs = mem_size-1) then
                            main_state <= Done;
                            done_recv <= '1';
                        else
                            mem_adrs := mem_adrs + 1;
                            main_state <= Receiving;
                        end if;
                        
                    when Incrementing_Send =>
                        if (mem_adrs = mem_size-1) then
                            main_state <= Done;
                            done_transmit <= '1';
                        else
                            mem_adrs := mem_adrs + 1;
                            main_state <= Fetching;
                        end if;
                        
                    when Done =>
                        mem_adrs := 0;
                        write_wait := 0;
                        read_wait := 0;
                        pixel_value <= std_logic_vector(to_unsigned(base_val_g, pixel_value 'length));
                        main_state <= Idle;
--                        done_op <= '1';
                    when others =>
                        null;
                end case;
            end if;
    end process;
end Behavioral;

