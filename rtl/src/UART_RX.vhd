----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dylann Kinfack
-- 
-- Design Name: uart-fpga-command-processor
-- Module Name: UART_RX - Behavioral
-- Project Name: uart-fpga-command-processor
-- Target Devices: Spartan-7
-- Tool Versions: Vivado 2020.2
-- Description: 
--  EN: UART receiver using 16× baud rate oversampling, 
--      start-bit detection, and synchronized RX input to prevent metastability.

--  DE: UART-Empfänger mit Oversampling (16× Baudrate), Startbit-Erkennung 
--  und synchronisierter RX-Leitung zur Vermeidung von Metastabilität.

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

entity UART_RX is
    Port ( CLK : in STD_LOGIC;
           RESET : in STD_LOGIC;
           RX : in STD_LOGIC;
           RX_DATA : out STD_LOGIC_VECTOR (7 downto 0);
           RX_VALID : out STD_LOGIC);
end UART_RX;

architecture Behavioral of UART_RX is

-- Baudrate and Clock frequence defintion
 constant  BAUDRATE :  integer := 300_000 * 16;
 constant  CLK_FREQ :  integer := 50_000_000;
 constant CYCLES : integer     := CLK_FREQ / BAUDRATE;   

signal rx_synch1, rx_synch2 : std_logic;

-- For time base generation--
signal baud_tick : STD_LOGIC;
signal counter : integer  range 0 to CYCLES -1;


 -- Finite State Machine data--
 type STATE is ( IDLE, START, DATA, STOP, DONE);
 signal current_state : STATE;
 signal next_state : STATE;
 signal bit_time : integer range 0 to 255;
 signal pos : integer range 0 to 7;
 signal read_count : integer range 0 to 8;

begin
    -- Receive RX Synchronisation
      rx_synchron : process (CLK)
      begin
          if rising_edge(CLK) then
            rx_synch1 <= RX;
            rx_synch2 <= rx_synch1; 
          end if;    
      end process;
      
      -- Process for time base generation
      time_base: process (CLK, RESET)
      begin
            if RESET ='0' then
                counter <= 0;
                
            elsif CLK'event and CLK = '1' then
                if counter = (CYCLES - 1 ) then
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;
            end if;
      end process;
      baud_tick <= '1' when (counter = CYCLES-1) else '0';
      
      -- current state logic synopsys method
      current_state_pro: process (CLK, RESET)
      begin
        if RESET = '0' then
            current_state <= IDLE;
        elsif CLK'event and CLK = '1' then
            current_state <= next_state;
        end if;
       
      end process;
      
      -- Next state logic combinatorisch
      next_state_proc: process (current_state, rx_synch2, baud_tick, bit_time, read_count)
      begin
        next_state <= current_state; -- default default
        
        case current_state is 
            when IDLE => 
                if not rx_synch2 = '1' then
                    next_state <= START;
                end if;
                
            when START =>
                if (baud_tick = '1') and (bit_time = 7) then
                    if not rx_synch2 = '1' then
                        next_state <= DATA;
                    else
                        next_state <= IDLE;
                    end if;
                else
                    next_state <= START;
                end if;
            
            when DATA =>
                if (baud_tick = '1') and (read_count=8) then
                    next_state <= STOP;
                else
                    next_state <= DATA;
                end if;
                
            when STOP => 
                if (baud_tick = '1') and (bit_time = 15) and (rx_synch2 = '1') then
                    next_state <= DONE;
                else
                    next_state <= STOP;
                end if;
                
            when  DONE =>
                next_state <= IDLE;
                
            when others =>
                next_state <= IDLE;
            end case;
               
      end process;
      
      
      -- Finite state machine for Data Path
      data_process: process (CLK, RESET)
      begin
            if RESET = '0' then
                read_count <= 0;
                pos <= 0;
                bit_time <= 0;
                RX_VALID <= '0';
            
            elsif CLK'event and CLK = '1' then
                
                -- counter bit_time increment
                if baud_tick = '1' then
                    bit_time <= bit_time +1;
                end if;
                
                case current_state is
                    when IDLE =>
                        read_count <= 0;
                        pos <= 0;
                        bit_time <= 0;
                        RX_VALID <= '0';
                     
                    when START => -- reset the bit time counter to 0
                        if (baud_tick = '1') and (bit_time = 7) then
                            bit_time <= 0;
                        end if;
                    
                    when DATA =>
                        if (baud_tick = '1') and (bit_time = 15) then
                            RX_DATA(pos) <= rx_synch2;
                            pos <= pos +1;
                            read_count <= read_count +1;
                            bit_time <= 0;
                         end if;
                     
                     when STOP =>
                        if (baud_tick = '1') and (bit_time = 15) then
                            bit_time <= 0;
                        end if;
                        
                    when DONE =>
                        RX_VALID <= '1';
               
                 end case;        
             end if;
                
      end process;
     
end Behavioral;
