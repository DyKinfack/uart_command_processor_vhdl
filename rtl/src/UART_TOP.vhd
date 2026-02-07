----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.02.2026 23:01:57
-- Design Name: 
-- Module Name: UART_TOP - Behavioral
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


-- In the TOP module, I included the outputs tx_out, rx_out, tx_out2, rec_data, and rec_valid. 
-- I added these to visualize the TX and RX signal traces in the simulation, 
-- as well as tx_out2 for monitoring the transmitted results. 
-- Additionally, rec_data allows for verifying the data processed by the UART_RX, 
-- while rec_valid serves as a single-cycle pulse for validation.

entity UART_TOP is
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
           
end UART_TOP;

architecture Behavioral of UART_TOP is

signal TX2, TX, q_busy, rx_valid, cmd_ack, cmd_valid, start_TX: std_logic;
signal rx_data: std_logic_vector (7 downto 0);
signal opcode : std_logic_vector (1 downto 0);
signal op1, op2 : std_logic_vector (2 downto 0);

component UART_TX is
    Port ( CLK : in STD_LOGIC;
           RESET : in STD_LOGIC;
           TX_START : in STD_LOGIC;
           TX_data : in STD_LOGIC_VECTOR (7 downto 0);
           q_busy :out STD_LOGIC;
           TX : out STD_LOGIC);
end component;

component UART_RX is
    Port ( CLK : in STD_LOGIC;
           RESET : in STD_LOGIC;
           RX : in STD_LOGIC;
           RX_DATA : out STD_LOGIC_VECTOR (7 downto 0);
           RX_VALID : out STD_LOGIC);
end component;

component ALU is
    Port ( CLK : in STD_LOGIC;
           RESET : in STD_LOGIC;
           cmd_valid : in STD_LOGIC;
           opcode : in STD_LOGIC_VECTOR (1 downto 0);
           op1 : in STD_LOGIC_VECTOR (2 downto 0);
           op2 : in STD_LOGIC_VECTOR (2 downto 0);
           start_TX : out STD_LOGIC;
           cmd_ACK : out STD_LOGIC;
           result : out STD_LOGIC_VECTOR (7 downto 0));
end component;


component decoder is
    Port ( CLK : in STD_LOGIC;
           RESET : in STD_LOGIC;
           RX_VALID : in STD_LOGIC;
           CMD_ACK : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR (7 downto 0);
           opcode : out STD_LOGIC_VECTOR (1 downto 0);
           op1 : out STD_LOGIC_VECTOR (2 downto 0);
           op2 : out STD_LOGIC_VECTOR (2 downto 0);
           cmd_valid : out STD_LOGIC);
end component;


begin
    transmitter: UART_TX port map(   
                                    CLK => CLK,
                                    RESET => RESET,
                                    TX_START => TX_start,
                                    TX_data => DATA,
                                    q_busy => q_busy,
                                    TX => TX
                                 );
                        
    receiver: UART_RX Port map ( 
                                    CLK => CLK,
                                    RESET => RESET,
                                    RX => TX,
                                    RX_DATA => rx_data,
                                    RX_VALID => rx_valid
                                );
                      rec_data <= rx_data;
                      rec_valid <= rx_valid;
                      rx_out <= TX;

    decoder1: decoder Port map ( 
                                    CLK => CLK,
                                    RESET => RESET,
                                    RX_VALID => rx_valid,
                                    CMD_ACK => cmd_ack,
                                    data => rx_data,
                                    opcode => opcode,
                                    op1 => op1,
                                    op2 => op2,
                                    cmd_valid => cmd_valid
                                );
                                
      ALU1:  ALU Port map      ( 
                                    CLK => CLK,
                                    RESET => RESET,
                                    cmd_valid => cmd_valid,
                                    opcode => opcode,
                                    op1 => op1,
                                    op2 => op2,
                                    start_TX=> start_TX,
                                    cmd_ACK => cmd_ack,
                                    result => result
                               );
                               
                               
      transmitter2: UART_TX port map(   
                                    CLK => CLK,
                                    RESET => RESET,
                                    TX_START => start_TX,
                                    TX_data => result,
                                    q_busy => open,
                                    TX => TX2
                                 );
                tx_out <= TX;
                tx_out2 <= TX2;

end Behavioral;
