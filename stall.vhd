library  ieee;
use  ieee.std_logic_1164.all;
use  ieee.numeric_std.all;

entity STALL is 
  port(    
      dx_rd         : in std_logic_vector(4 downto 0);
      xm_rd         : in std_logic_vector(4 downto 0);
      mw_rd         : in std_logic_vector(4 downto 0);
      young_insn    : in std_logic_vector(31 downto 0);
      branch, jump  : in std_logic;
      stall         : out std_logic_vector(1 downto 0) :=b"00"
    );
end STALL;

architecture main of STALL is
  -- TEMPORARY INTERNAL SPLITOUTS
  signal OP : std_logic_vector (5 downto 0);
  signal rS :std_logic_vector (4 downto 0);
  signal rT : std_logic_vector (4 downto 0);
  signal FN : std_logic_vector(5 downto 0);
  
begin 
   OP <= young_insn (31 downto 26);
   rS <= young_insn (25 downto 21);
   rT <= young_insn (20 downto 16);
   FN <= young_insn (5 downto 0);
   
   
   stall <= b"10" when (branch='1') or (jump='1') else
           b"01" when ((OP = "001010") or (OP = "100011") or (OP = "001001")  or (OP="001111") or (OP="001101")) and ( ((dx_rd/="00000")and(rS=dx_rd)) or ((xm_rd/="00000")and(rS=xm_rd)) or ((mw_rd/="00000")and(rS=mw_rd)) ) else --lw, slti, addiu, lui, ori
           b"01" when (((dx_rd/="00000") and (dx_rd/="UUUUU") and ((rT=dx_rd) or (rS=dx_rd))) or ((xm_rd/="00000") and (xm_rd/="UUUUU") and ((rT=xm_rd) or (rS=xm_rd))) or ((mw_rd/="00000") and (mw_rd/="UUUUU") and ((rT=mw_rd) or(rS=mw_rd)))) and ((OP/="001010")and(OP/="100011")and(OP/="001001")and(OP/="001111")and(OP/="001101")) else --all insn that have 3 operands
           b"00"; --no data dependency
   
 --  process(latch_clk)
--     begin
--       if falling_edge(latch_clk) then
--         if ((branch='1') or (jump='1')) then
--           stall <= b"10";
--         elsif ( ((OP = "001010") or (OP = "100011") or (OP = "001001")  or (OP="001111") or (OP="001101")) and ( (rT=dx_rd) or (rT=xm_rd) or (rT=mw_rd) )) then
--           stall <= b"01";
--         elsif ( ((dx_rd /= "00000") and (dx_rd /= "UUUUU") and ((rT=dx_rd) or (rS=dx_rd))) or ((xm_rd /= "00000") and (xm_rd /= "UUUUU") and ((rT=xm_rd) or (rS=xm_rd))) or ((mw_rd /= "00000") and (mw_rd /= "UUUUU") and ((rT=mw_rd) or(rS=mw_rd))) ) then
--           stall <= b"01";
--         else
--           stall <= b"00";
--         end if;
--       end if;
--    end process;
--            
           
end architecture;