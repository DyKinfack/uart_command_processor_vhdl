----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dylann Kinfack
-- 
-- Design Name:  uart-fpga-command-processor
-- Module Name: UART_TX - Behavioral
-- Project Name:  uart-fpga-command-processor
-- Target Devices: Spartan-7
-- Tool Versions: Vivado 2020.2
-- Description: 
-- EN:
-- UART transmitter implementing an FSM-based control 
--      with parameterizable baud rate and synchronized start detection. 
--      Transmits serial frames including start, data and stop bits.
--
-- DE:
--     UART-Sender mit FSM-basierter Steuerung, 
--     parametrisierbarer Baudrate und synchronisiertem Startsignal. 
--     Sendet serielle Frames (Startbit, 8 Datenbits, Stopbit).
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
use IEEE.std_logic_arith;
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity UART_TX is
    Port ( CLK : in STD_LOGIC;
           RESET : in STD_LOGIC;
           TX_START : in STD_LOGIC;
           TX_data : in STD_LOGIC_VECTOR (7 downto 0);
           q_busy :out STD_LOGIC;
           TX : out STD_LOGIC);
end UART_TX;


architecture Behavioral of UART_TX is

    -- Function to swap data
    function uart_bit_swap (data : in std_logic_vector) return std_logic_vector 
        is
        variable temp : std_logic_vector(7 downto 0);
    begin
        
        for  i in 0 to 7 loop
            temp(7-i) := data(i);
        end loop;
        return temp;
    end function;




    -- Constant for UART TX
    constant BAUDRATE : integer := 300_000;
    constant CLK_FREQ : integer := 50_000_000;
    constant CYCLES : integer := CLK_FREQ / BAUDRATE;
    
    -- UART FRAME SIZE
    constant UART_FRAME_SIZE : integer := 10;
    
    -- Component for Base generation
   component time_base_generation  generic (CYCLES : integer);
    Port ( CLK : in STD_LOGIC;
           RESET : in STD_LOGIC;
           Q : out STD_LOGIC);
end component;

-- Enable Signal to change the state 
signal enable : std_logic;

-- State for the Finite state machine
type STATE is (RES_ET, IDLE, SEND, DONE);

signal current_state: STATE;
signal next_state: STATE;

-- Synchron register to detected a start request
signal syn_reg : std_logic_vector (1 downto 0);
signal start_request : std_logic;
signal start_request_detected : std_logic := '0';

signal STOP_BIT : std_logic := '1';
signal START_BIT: std_logic := '0';
signal TXD_DATA: std_logic_vector (7 downto 0);

signal  txd_shift_reg_en : std_logic; 
signal  txd_shift_reg_init : std_logic;

signal txd_shift_reg : std_logic_vector (9 downto 0) := (others => '0');
signal bits_transmitted : integer range 0 to 15;


begin
        
        --time base generation
        counter: time_base_generation generic map( CYCLES => CYCLES )
            port map ( CLK => CLK,
                       RESET => RESET,
                       Q => enable);
                       
                       
       -- perform the synchron Register 
    synchron_reg: process(CLK, RESET)
       begin
        if RESET = '0' then
            syn_reg <= (others => '0');
        elsif CLK'event and CLK ='1' then
            syn_reg <= (syn_reg(0), TX_START);
        end if;
       end process;
       start_request <= '1' when (syn_reg = "01") else '0';
       
       -- INTERNAL START DETECTION - START REQUEST ARE ONLY ACCEPTED IN IDLE STATE
     START_DETEC_PRO:  process (CLK, RESET)
       begin
        if RESET = '0' then
            start_request_detected <= '0';
        
        elsif CLK'event and CLK ='1' then
               if current_state = DONE or current_state = SEND then
                    start_request_detected <= '0';
                    
               elsif (current_state = IDLE) and (not start_request_detected = '1') then
                    start_request_detected <= start_request;
                    
               end if;
        end if;
       end process;
       
       -- swap the TX data
       TXD_DATA <= uart_bit_swap(TX_data);
       
       txd_shift_reg_en <= '1' when (current_state = SEND and enable ='1') else '0';
         
       txd_shift_reg_init <= start_request and not start_request_detected;
       
       -- process to set txd_shift_reg and TX out
    Txd_shift_reg_pro: process (CLK, RESET) 
       begin
        if RESET = '0' then
            txd_shift_reg <= (others => '1');
        
        elsif rising_edge(CLK) then 
            if txd_shift_reg_init ='1' then
                txd_shift_reg <= (STOP_BIT & START_BIT & TXD_DATA);
            
            elsif txd_shift_reg_en = '1' then
                txd_shift_reg <= ( txd_shift_reg(8 downto 0) & STOP_BIT);
            end if;
        end if;
       end process;
       
       TX <= txd_shift_reg(9);
       
       
       -- Finite state Machine for state transition
       -- current state logic
    current_state_reg: process (CLK, RESET)
       begin
        if RESET = '0' then
            current_state <= RES_ET;
        
        elsif CLK'event and CLK ='1' then
            current_state <= next_state;
        end if;
       end process;
       
       -- Next state logic
     Next_state_comb:  process (current_state, start_request_detected, bits_transmitted)
       begin
            
            -- defaults state
            next_state <= current_state;
            
            case current_state  is
                when RES_ET => 
                    next_state <= IDLE;
                 
                when IDLE =>
                     if start_request_detected = '1' then
                        next_state <= SEND;  
                     end if;    
                 
                when SEND =>
                    if bits_transmitted = (bits_transmitted -1) then 
                        next_state <= DONE;
                    else
                        next_state <= SEND;
                    end if;
                  
                when DONE =>
                      next_state <= IDLE;
             end case;
                    
       end process;
       
       q_busy <= '1' when (current_state = IDLE) else '0';
       
       
       -- counter for bit transmitted
    bit_transmited:   process(CLK, RESET)
       begin
        if RESET = '0' then
            bits_transmitted <= 0;
        elsif CLK'event and CLK = '1' then
            if enable = '1' then
                if current_state = SEND then
                    bits_transmitted <= bits_transmitted +1;
                else
                    bits_transmitted <=0;
                end if;
            end if;
        end if;
        
       end process;


            
end Behavioral;


           
