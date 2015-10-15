library  ieee;
use  ieee.std_logic_1164.all;
use  ieee.numeric_std.all;

entity fetch is
  port(
      clk     : in std_logic :='0';
      stall   : in std_logic;
      nxt_pc  : in std_logic_vector(31 downto 0) :=x"80002000";
      addr    : out std_logic_vector(31 downto 0):=x"80002000";
      rw      : out std_logic :='0'; --always equal to 0 for read
      pc      : out std_logic_vector(31 downto 0) :=x"80002000"
    );
end fetch;
      
      
architecture main of fetch is
  signal prog_counter : std_logic_vector(31 downto 0) :=X"80020000"; --default starting addr 
   
begin
  
  
  
  process(clk)
    --variable adder: unsigned(31 downto 0);
    --variable nxt_pc: unsigned(31 downto 0) := X"00000004";
    
    begin
      if rising_edge(clk) then
        if (stall = '0') then
          --output the addr stored in the prog counter to the pc and addr output port
          pc <= prog_counter;
          addr <= prog_counter;
        end if;                   
      end if;
      if falling_edge(clk) then
        if (stall = '0') then
          --increment prog_counter to the next appropriate instruction
          prog_counter <= nxt_pc;
        end if;
        if (stall = '1') then
          prog_counter <= prog_counter;
        end if;
      end if;
      
    end process;
    
  end architecture;
  