library ieee, std_developerskit;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use std_developerskit.std_iopak.all;

--use ieee.std_logic_textio.all;
--use work.txt_util.all; 
 
entity parser is
  port(
       CLK    : in std_logic;
       ADDR   : out std_logic_vector(31 downto 0) :=X"00000000";
       DATA   : out std_logic_vector(31 downto 0) :=X"00000000";
       WE     : out std_logic :='0'
      );
end parser;

architecture main of parser is
    
    file myfile: TEXT open read_mode is "BubbleSort.srec";
       
    subtype byte is std_logic_vector(31 downto 0);
    type byte_array is array( natural range <> ) of byte;
        
begin


-- read data from input file
read_file: process

variable byte_offset: byte_array(1 to 4);
variable l: line;
variable tmp_char: character;
variable byte_count: string(1 to 2);
variable byte_hex: bit_vector(7 downto 0);
variable byte_int: integer;
variable address: string(1 to 8);
variable addr_hex: bit_vector(31 downto 0);
variable data_out: string(1 to 8);
variable data_hex: bit_vector(31 downto 0);
   
  begin    
  --each line in the SREC file will write 16 byte starting from the addr 
  --so we must increase the base address by 4 and write 4 byte at a time
  byte_offset(1) := x"00000000";
  byte_offset(2) := x"00000004";
  byte_offset(3) := x"00000008";
  byte_offset(4) := x"0000000C";
    
  
   while not endfile(myfile) loop
        
     readline(myfile, l);
     read(l, tmp_char);
     read(l,tmp_char);
     
        if(tmp_char = '3') then --seems like the record type is always S3; but need to ask prof
          wait until CLK = '1';
          --get the byte count from the file
          read(l, byte_count);
          byte_hex := From_HexString(byte_count);
          byte_int := to_integer(unsigned(to_stdlogicvector(byte_hex)));
          byte_int := (byte_int - 5)/4;
         
          --decode the address from hex format
          read(l, address);
          addr_hex := From_HexString(address);               
              
          --output a 32bit(4 byte) data for 'byte_int' number of times (most of time is 4, but sometimes it's less)
          for i in 1 to byte_int loop 
            WE <= '1';
            ADDR <= to_stdlogicvector(addr_hex) + byte_offset(i);  
            read(l, data_out);
            data_hex := From_HexString(data_out);
            DATA <= to_stdlogicvector(data_hex);
            if(i /= byte_int) then
              wait until CLK = '1';
            end if;            
          end loop;                    
        end if;  
   end loop; 
   
   wait until CLK='1'; 
  
   WE <= '0';
   wait; -- do nothing when end of file is reached

 end process;

end architecture;