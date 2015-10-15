LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY latch IS GENERIC(size: INTEGER := 31);
  PORT (
    clk: IN STD_LOGIC :='0';
    WE: IN STD_LOGIC;
    D: IN STD_LOGIC_VECTOR(size DOWNTO 0);
    Q: OUT STD_LOGIC_VECTOR(size DOWNTO 0)
    );
END latch;


ARCHITECTURE main OF latch IS
  
BEGIN
  
  PROCESS(clk)
  BEGIN      
     IF rising_edge(clk) THEN
      IF WE = '1' THEN
        Q <= D;
      END IF;
     END IF;
  END PROCESS;
  
END main;