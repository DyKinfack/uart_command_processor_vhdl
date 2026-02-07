----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dylann Kinfack
-- 
-- Create Date: 07.02.2026 10:42:20
-- Design Name: uart-fpga-command-processor
-- Module Name: UART_TOP_tb - Behavioral
-- Project Name: uart-fpga-command-processor
-- Target Devices: Spartan-7
-- Tool Versions: Vivado 2020.2
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

entity UART_TOP_tb is
--  Port ( );
end UART_TOP_tb;

architecture Behavioral of UART_TOP_tb is

signal CLK, RESET, TX_start, TX, TX_out2, RX, rec_valid: std_logic;
signal to_send_data, result, received_data: std_logic_vector (7 downto 0);

component UART_TOP 
    Port ( CLK : in STD_LOGIC;
           RESET : in STD_LOGIC;
           DATA : in STD_LOGIC_VECTOR (7 downto 0);
           TX_start : in STD_LOGIC;
           tx_out : out std_logic;
           rx_out : out std_logic;
           tx_out2: out std_logic;
           rec_data : out std_logic_vector (7 downto 0);
           rec_valid : out std_logic;
           result : inout STD_LOGIC_VECTOR (7 downto 0));
end component;


begin

        uart_top1: UART_TOP port map (
                                       CLK => CLK,
                                       RESET => RESET,
                                       DATA => to_send_data,
                                       TX_start => TX_start,
                                       tx_out => TX,
                                       rx_out => RX,
                                       tx_out2 => TX_out2,
                                       rec_data => received_data,
                                       rec_valid =>  rec_valid,
                                       result => result
                                       );
                                       
                                      
       RESET <= '0' , '1' after 10000ns ;
       
       process 
       begin
        CLK <= '0';
        wait for 5ns;
        CLK <= not CLK;
        wait for 5ns; 
       end process;
       
       
        process 
        begin
           
            TX_start <= '0';
            to_send_data <= (others => '0');
            
            --------------------------------------------
            -- send command: opcode=00, op1=3, op2=1 result must be 4 ---
            --------------------------------------------
            wait for 15000ns;
            TX_start <= '1';
            to_send_data <= "00001011";
            wait for 5000ns;
            TX_start <='0';
            
            wait for 45000ns;
            
            --------------------------------------------
            -- send command: opcode=01, op1=3, op2=2 result must be 1 ---
            --------------------------------------------
            TX_start <= '1';
            to_send_data <= "01010011";
            wait for 5000ns;
            TX_start <='0';
            
            wait for 45000 ns;
            
        end process;
end Behavioral;
