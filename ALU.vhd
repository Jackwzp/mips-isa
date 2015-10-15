library ieee, std_developerskit;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.std_logic_unsigned.all;
use std.textio.all;
use std_developerskit.std_iopak.all;
use ieee.std_logic_unsigned.all;



--Define the  entity & achitecture
entity ALU is 
port(
      A,B :	in std_logic_vector(31 downto 0); 
	    PC  :	in std_logic_vector(31 downto 0); --PC for jal insn
	    OP  : in std_logic_vector(5 downto 0);	-- OPCODE input from decode
	    FN  : in std_logic_vector (5 downto 0); -- function input from decode
      SH  : in std_logic_vector(4 downto 0); -- SHIFT AMOUnt from the decode unit
	    C   : out std_logic_vector(31 downto 0); --output of alu 	  
      BR  : out std_logic 
);
end ALU;

architecture main of ALU is 
  
begin 
  
       BR <= '1' when (op="000100") and (A=B) else --beq
             '1' when (op="000101") and (A/=B) else --bne
             '1' when (op="000110") and (A<=0) else --blez
             '1' when (op="000001") and (A>=0) and (B="00001") else --bgez
             '1' when (op="000001") and (A<0) and (B="00000") else --bltz
             '1' when (op="000111") and (A>0) else --bgtz
             '0';

              
       C <= A + B when (op="001001") or (op="100011") or (op="101011") else --addiu, lw, sw            
            A + B when (op="000000") and ((fn="100000") or (fn="100001")) else --Add, Addu
            A - B when (op="000000") and ((fn="100010") or (fn="100011")) else --sub, subu
           (A and B) when (op="000000") and (fn="100100") else --AND
           (A or B) when ((op="000000") and (fn="100101")) or (op="001101") else --OR, ORi
           (A xor B) when (op="000000") and (fn="100110") else --xor
           (A nor B) when (op="000000") and (fn="100111") else --nor
            B when (op="001111") else --lui
            PC when (op="000011") else --jal
            x"00000001" when (op="001010") and (signed(A)<signed(B)) else  --slti
            x"00000001" when (op="000000") and (signed(A)<signed(B)) and (fn="101010") else --slt
            x"00000001" when (op="000000") and (A<B) and (fn="101011") else --sltu
            to_stdlogicvector(to_bitvector(B) sll conv_integer(SH)) when (op="000000") and (fn="000000") else --sll
            to_stdlogicvector(to_bitvector(B) srl conv_integer(SH)) when (op="000000") and (fn="000010") else --srl
            to_stdlogicvector(to_bitvector(B) ror conv_integer(SH)) when (op="000000") and (fn="000011") else --sra
            x"00000000"; 



end architecture;


