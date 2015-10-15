library ieee, std_developerskit;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use std_developerskit.std_iopak.all;


--Define the  entity & achitecture
entity DECODE is 
port(
      insn      :		in std_logic_vector(31 downto 0);
	    pc   :	 in std_logic_vector(31 downto 0);
	    vOP  : 	out std_logic_vector(5 downto 0);	-- OPCODE OUT
	    vS : out std_logic_vector(4 downto 0); --S REG out
      vT : out std_logic_vector(4 downto 0); -- T REG out
      vD : out std_logic_vector(4 downto 0); -- D REG out
      vSH : out std_logic_vector(4 downto 0); -- SHIFT AMOUT out
      vFN : out std_logic_vector(5 downto 0);-- FUNCTION out
      vIMMD : out std_logic_vector(15 downto 0); -- IMMEDIATE VALUE OUT
      vTAR : out std_logic_vector (25 downto 0); -- TARGET VALUE OUT
      alu_mux : out std_logic_vector (1 downto 0) :=b"00"; --control bit for alu input b
      rf_we : out std_logic_vector(1 downto 0) :=b"00"; --control bit for Reg File WE
      mem_we: out std_logic_vector(1 downto 0) :=b"00"; --control bit for data mem WE
      wb_mux: out std_logic_vector(1 downto 0) :=b"00"; --control bit for WB Mux
      jp  : out std_logic_vector(1 downto 0) :=b"00"; --control bit for jump insn
      stall : in std_logic_vector (1 downto 0) :=b"00"; --stall logic in decode mode
      jr_mux : out std_logic_vector(1 downto 0) :=b"00" --mux for jr, j and jal
);
end DECODE;

architecture main of DECODE is
  -- TEMPORARY INTERNAL SPLITOUTS
  signal tOP : std_logic_vector (5 downto 0);
  signal tS :std_logic_vector (4 downto 0);
  signal tT : std_logic_vector (4 downto 0);
  signal tD : std_logic_vector (4 downto 0);
  signal tSH : std_logic_vector(4 downto 0);
  signal tFN : std_logic_vector(5 downto 0);
  signal tIMMD : std_logic_vector(15 downto 0);
  signal tTAR : std_logic_vector (25 downto 0);
  
begin 
   tOP <= insn (31 downto 26);
   tS <= insn (25 downto 21);
   tT <= insn (20 downto 16);
   tD <= insn (15 downto 11);
   tSH <= insn (10 downto 6);
   tFN <= insn (5 downto 0);
   tIMMD <= insn (15 downto 0);
   tTAR <= insn (25 downto 0);
   
   
   vOP <= tOP when (stall ="00") else
          "000000";
                    
   vS <= tS when (stall ="00") else
          "00000";
          
   vT <= tT when (stall ="00") else
          "00000";
          
   vD <= tD when (stall ="00") and ((tOP = "000000")) else
         tT when (stall ="00") and ((tOP = "001010") or (tOP = "100011") or (tOP = "001001")or (tOP = "001101")or (tOP = "001111")) else
         "11111" when (stall="00") and (tOP="000011") else --jal
         "00000";
         
   vSH <= tSH when (stall ="00") else
          "00000";
          
   vFN <= tFN when (stall ="00") else
          "000000";
              
   vIMMD <= tIMMD when (stall ="00") else
          x"0000";
    
   vTAR <= tTAR when (stall ="00") and ((tOP = "000010") or (tOP="000011")) else --j, jal
         "00000000000000000000000000";
  
   alu_mux <= b"01" when (stall ="00") and ((tOP = "001010") or (tOP = "100011") or (tOP = "101011")or (tOP =  "001001") or (tOP = "001111") or (tOP ="001101")) else --lw, sw, slti,addiu, lui, ori
              b"00";
    
   rf_we <= b"01" when (stall ="00") and ((tOP ="000000") or (tOP = "001001")or (tOP ="001010") or (tOP = "100011") or (tOP ="001111") or (tOP = "001101") or (tOP="000011")) else
            b"00";
            
   wb_mux <= b"01" when (stall ="00") and ((tOP = "100011")) else --lw
             b"00";
    
   mem_we <= b"01" when (stall ="00") and ((tOP = "101011")) else --sw
             b"00";
    
   jp <= b"01" when (stall ="00") and ((tOP = "000010") or (tOP="000011") or ((tOP="000000") and (tFN="001000"))) else --j, jal, jr
         b"00";
   
   jr_mux <= b"01" when (stall="00") and (tOP="000000") and (tFN="001000") else --jr
             b"00";


end architecture;