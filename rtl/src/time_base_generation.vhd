----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.02.2026 20:34:19
-- Design Name: 
-- Module Name: time_base_generation - Behavioral
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
use IEEE.std_logic_arith;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity time_base_generation is generic (CYCLES : integer := 50000);
    Port ( CLK : in STD_LOGIC;
           RESET : in STD_LOGIC;
           Q : out STD_LOGIC);
end time_base_generation;

architecture Behavioral of time_base_generation is

   -- constant BITWIDTH : integer := clog2(CYCLES);
   function clog22( value : natural) return natural is
    variable res : natural := 0;
    variable temp : natural := value - 1;
    
    begin
        while temp > 0 loop
            temp := temp / 2;
            res := res +1;
        end loop;
     return res;
            
    end function;
    
    
    constant BITWIDTH : integer := clog22(CYCLES);
    signal counter : integer range 0 to (BITWIDTH -1);
    
begin
    
    process(CLK, RESET)
    begin
        if RESET = '0' then
            counter <= 0;
            
        elsif CLK'event and CLK ='1' then
            if counter = (CYCLES -1) then
                counter <= 0;
            else
                counter <= counter +1;
            end if;
        end if;
    end process;
    
    Q <= '1' when (counter = (CYCLES -1)) else '0';
    
end Behavioral;


