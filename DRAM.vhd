library  ieee;
use  ieee.std_logic_1164.all;
use  ieee.numeric_std.all;

--Define the Memory entity & achitecture
entity DRAM is 
port(	clk     :		in std_logic;
	    WE        :		in std_logic;
	    addr      :		in std_logic_vector(31 downto 0);
	    data_in   :	 in std_logic_vector(31 downto 0);
	    data_out  : 	out std_logic_vector(31 downto 0)	
);
end DRAM;


architecture main of DRAM is

--define the memory array, which is a 2D array of std_logic vector of 8 bits
--size of mem_array is 1MB = 1024 KB = 1024*1024 Byte or 2^20
constant mem_size: integer :=1048576; --allocate 1MB of memory
subtype byte is std_logic_vector(7 downto 0);
type mem_array is array( natural range <> ) of byte;
signal mem: mem_array(0 to mem_size);
signal new_addr : std_logic_vector(31 downto 0);

begin 
--internal mapping of the addresses, so we can stored the first data in the mem(0) 
   new_addr(31 downto 16) <= X"0000";
   new_addr(15 downto 0)  <= addr(15 downto 0);
  
process(clk)
begin
  if rising_edge(clk) then
    if WE = '1' then
      --assign the Most significant bits in data_in to the lower address byte since its Big-Endien
      mem( to_integer( unsigned(new_addr)))     <= data_in(31 downto 24);
      mem( to_integer( unsigned(new_addr)) + 1) <= data_in(23 downto 16);
      mem( to_integer( unsigned(new_addr)) + 2) <= data_in(15 downto 8);
      mem( to_integer( unsigned(new_addr)) + 3) <= data_in(7 downto 0);
    end if;
  end if;
  if falling_edge(clk) then
    if WE='0' then
      --output the data;
      data_out(31 downto 24)  <= mem( to_integer( unsigned(new_addr)));
      data_out(23 downto 16)  <= mem( to_integer( unsigned(new_addr)) + 1);
      data_out(15 downto 8)   <= mem( to_integer( unsigned(new_addr)) + 2);
      data_out(7 downto 0)    <= mem( to_integer( unsigned(new_addr)) + 3);
    end if;
  end if;
end process;

end architecture;
