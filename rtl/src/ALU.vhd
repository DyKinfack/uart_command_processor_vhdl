----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dylann Kinfack
-- 

-- Design Name: uart-fpga-command-processor
-- Module Name: ALU - Behavioral
-- Project Name: uart-fpga-command-processor
-- Target Devices:  Spartan-7
-- Tool Versions: Vivado 2020.2
-- Description: 
--  EN: Synchronous ALU module performing arithmetic operations (add, subtract, multiply, divide) 
--      and generating result data for transmission.
--
--  DE: Synchrones ALU-Modul zur Ausführung arithmetischer Operationen (Add, Sub, Mul, Div). 
--      Erzeugt Ergebnisdaten und steuert die Rückübertragung.
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

entity ALU is
    Port ( CLK : in STD_LOGIC;
           RESET : in STD_LOGIC;
           cmd_valid : in STD_LOGIC;
           opcode : in STD_LOGIC_VECTOR (1 downto 0);
           op1 : in STD_LOGIC_VECTOR (2 downto 0);
           op2 : in STD_LOGIC_VECTOR (2 downto 0);
           start_TX : out STD_LOGIC;
           cmd_ACK : out STD_LOGIC;
           result : out STD_LOGIC_VECTOR (7 downto 0));
end ALU;

architecture Behavioral of ALU is

signal op1_u, op2_u : unsigned(7 downto 0);
signal ope1, ope2: std_logic_vector(7 downto 0);
begin
          op1_u <=("00000" & unsigned(op1));
          op2_u <= ("00000" & unsigned(op2));
          ope1 <= ("00000" & op1);
          ope2 <= ("00000" & op2);
          
        process(CLK, RESET)
        begin
            if RESET = '0' then
            
                start_TX <= '0';
                cmd_ACK <= '0';
                result <= (others => '0');
            
            elsif CLK'event and CLK = '1' then
            
                if  cmd_valid = '1' then
                
                    case opcode is
                        when "00" =>
                            result <= std_logic_vector(unsigned(ope1) + unsigned (ope2));
                        
                        when "01" =>
                            result <= std_logic_vector(unsigned(ope1) - unsigned (ope2));
                        
                        when "10" =>
                             result <= ("00" & std_logic_vector(unsigned(op1) * unsigned (op2)));
                             
                        when "11" => 
                              
                                if op2_u /= 0 then
                                    result <= std_logic_vector(op1_u / op2_u);
                                else
                                    result <= (others=> '1');
                                end if;
                        when others =>
                            result <= (others => '0');
                                
                     end case;
                     start_TX <= '1';
                     cmd_ack <= '1';
              end if;
                     
         end if;
         
        end process;

end Behavioral;
