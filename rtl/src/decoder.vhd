----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dylann Kinfack
-- 
--
-- Design Name:  uart-fpga-command-processor
-- Module Name: decoder - Behavioral
-- Project Name:  uart-fpga-command-processor
-- Target Devices: Spartan-7
-- Tool Versions: Vivado 2020.2
-- Description: 
--  EN: Decodes received UART data into opcode and operands. 
--              Implements a handshake protocol (cmd_valid / cmd_ack) for safe communication with the ALU.
--
--  DE: Dekodiert empfangene UART-Daten in Opcode und Operanden. 
--      Implementiert ein Handshake-Protokoll (cmd_valid / cmd_ack) zur sicheren Übergabe an die ALU.
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

entity decoder is
    Port ( CLK : in STD_LOGIC;
           RESET : in STD_LOGIC;
           RX_VALID : in STD_LOGIC;
           CMD_ACK : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR (7 downto 0);
           opcode : out STD_LOGIC_VECTOR (1 downto 0);
           op1 : out STD_LOGIC_VECTOR (2 downto 0);
           op2 : out STD_LOGIC_VECTOR (2 downto 0);
           cmd_valid : out STD_LOGIC);
end decoder;

architecture Behavioral of decoder is

    -- FSM state
    type t_states is (IDLE, VALID);
    signal state : t_states;
    signal rx_data : std_logic_vector (7 downto 0);
    signal valid_cmd : std_logic;
   
begin
    -- command valid Logic and Command acknowlegment
        process (CLK, RESET) 
        begin
            if RESET = '0' then
                valid_cmd <= '0';
                rx_data <= (others => '0');
                state <= IDLE;
            
            elsif CLK'event and CLK = '1' then
                
                case state is 
                
                    when IDLE =>
                        if RX_VALID = '1' and not valid_cmd='1' then
                            rx_data <= data;
                            valid_cmd <= '1';
                            state <= VALID;
                        end if;
                        
                    when VALID =>
                        if CMD_ACK = '1' and valid_cmd = '1' then
                            valid_cmd <= '0';
                            state <= IDLE;
                        end if;
                end case;
            end if;
                    
        end process;
        cmd_valid <=  valid_cmd;
        
        -- opcode and operand process --
        process (state)
        begin
            if state = VALID then
                opcode <= rx_data( 7 downto 6);
                op2 <= rx_data(5 downto 3);
                op1 <= rx_data(2 downto 0);
            end if;
            
        end process;
        

end Behavioral;
