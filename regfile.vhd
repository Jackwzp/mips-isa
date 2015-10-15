LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; -- needed for CONV_INTEGER()

ENTITY regfile IS 
  port(
      clk       : IN std_logic; --clock
      WE        : IN std_logic; --write enable
      Rd        : IN std_logic_vector(4 DOWNTO 0); --write address
      C         : IN std_logic_vector(31 DOWNTO 0); --input
      Rs, Rt    : IN std_logic_vector(4 DOWNTO 0); --read address port A & B
      A, B      : OUT std_logic_vector(31 DOWNTO 0));--output port A & B
END regfile;


ARCHITECTURE main OF regfile IS
  
SUBTYPE reg IS std_logic_vector(31 DOWNTO 0);
TYPE regArray IS array(0 to 31) OF reg;
SIGNAL RF: regArray := (x"00000000", x"00000001", x"00000002", x"00000003", x"00000004", x"00000005",
x"00000006", x"00000007", x"00000008", x"00000009", x"0000000A", x"0000000B", x"0000000C", x"0000000D",
x"0000000E", x"0000000F", x"00000010", x"00000011", x"00000012", x"00000013", x"00000014", x"00000015",
x"00000016", x"00000017", x"00000018", x"00000019", x"0000001A", x"0000001B", x"0000001C", x"00010000",
x"0000001E", x"0000001F" ); --initial register file contents

BEGIN
  
  WriteReg: PROCESS (clk)
  BEGIN
      IF falling_edge(clk) THEN
        IF (WE = '1') THEN
          RF(CONV_INTEGER(Rd)) <= C; 
        END IF;
      END IF;
  END PROCESS;


  ReadReg: PROCESS (clk)
  BEGIN
      IF rising_edge(clk) THEN
        A <= RF(CONV_INTEGER(Rs));
        B <= RF(CONV_INTEGER(Rt));
      END IF;
  END PROCESS;

  
END main;
