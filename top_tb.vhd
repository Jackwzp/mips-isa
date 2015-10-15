library  ieee;
use  ieee.std_logic_1164.all;
use  ieee.numeric_std.all;


entity top_tb is
end top_tb;

architecture main of top_tb is
  
-------------------------------------------------------
----- Declaration of all Signals and components   ------
-------------------------------------------------------
  
  --component declaration of latch
  component latch
    generic(size: integer :=31);
    port(
      clk: IN STD_LOGIC;
      WE: IN STD_LOGIC;
      D: IN STD_LOGIC_VECTOR(size DOWNTO 0);
      Q: OUT STD_LOGIC_VECTOR(size DOWNTO 0)
    );
  end component;
  
  --global latch clock signal
  signal latch_clk : std_logic :='0'; --all latches share this same clock
  signal pc_latch_we  : std_logic;
  
  --signal for parser (p)
  signal p_addr, p_data : std_logic_vector(31 downto 0);
  signal p_clk, p_we : std_logic;
  
  --signal for Insn Mem (IM)
  signal im_addr, im_do, im_di  : std_logic_vector(31 downto 0);
  signal im_clk, im_we : std_logic;
  
  --signal for Fetch (F)
  signal f_addr, f_pc, f_nxt_pc : std_logic_vector(31 downto 0);
  signal f_stall, f_clk, f_rw : std_logic :='0';
  signal f_pc_4 : std_logic_vector(31 downto 0); --tmp signal for PC control logic
 
  --signal for F/D latches (FD)
  signal fd_we  : std_logic :='1'; --all latches in F/D share same WE
  signal fd_ir_d, fd_ir_q : std_logic_vector(31 downto 0);
  signal fd_pc_d, fd_pc_q : std_logic_vector(31 downto 0);
  
  --signals for Decode (D)
  signal d_insn, d_pc : std_logic_vector(31 downto 0);
  signal d_S, d_T, d_D, d_SH  : std_logic_vector(4 downto 0);
  signal d_OP, d_FN : std_logic_vector(5 downto 0);
  signal d_IMMD : std_logic_vector(15 downto 0);
  signal d_TAR  : std_logic_vector(25 downto 0);
  signal d_alu_mux : std_logic_vector(1 downto 0) :=b"00";
  signal d_rf_we : std_logic_vector(1 downto 0) :=b"00";
  signal d_mem_we : std_logic_vector(1 downto 0) :=b"00";
  signal d_wb_mux : std_logic_vector(1 downto 0) :=b"00";
  signal d_jp : std_logic_vector(1 downto 0) :=b"00";
  signal d_stall : std_logic_vector(1 downto 0) :=b"00";
  signal d_jr_mux : std_logic_vector(1 downto 0) :=b"00";
  
  --signals for Register File (RF)
  signal rf_clk, rf_we  : std_logic :='0';
  signal rf_rd, rf_rs, rf_rt  : std_logic_vector(4 DOWNTO 0);
  signal rf_a, rf_b, rf_c : std_logic_vector(31 DOWNTO 0);
  
  --signals for D/X latches (DX)
  signal dx_we  : std_logic :='1'; --all latches in D/X share sme WE
  signal dx_pc_d, dx_pc_q : std_logic_vector(31 downto 0);
  signal dx_a_d, dx_a_q : std_logic_vector(31 downto 0);
  signal dx_b_d, dx_b_q : std_logic_vector(31 downto 0);
  signal dx_op_d, dx_op_q : std_logic_vector(5 downto 0);
  signal dx_fn_d, dx_fn_q : std_logic_vector(5 downto 0);
  signal dx_sh_d, dx_sh_q : std_logic_vector(4 downto 0);
  signal dx_rd_d, dx_rd_q : std_logic_vector(4 downto 0);
  signal dx_immd_d, dx_immd_q : std_logic_vector(15 downto 0);
  signal dx_tar_d, dx_tar_q : std_logic_vector(25 downto 0);
  signal dx_alu_mux_d, dx_alu_mux_q : std_logic_vector(1 downto 0);
  signal dx_rf_we_d, dx_rf_we_q : std_logic_vector(1 downto 0);
  signal dx_mem_we_d, dx_mem_we_q : std_logic_vector(1 downto 0); 
  signal dx_wb_mux_d, dx_wb_mux_q : std_logic_vector(1 downto 0);
  signal dx_jp_d, dx_jp_q : std_logic_vector(1 downto 0);
  signal dx_jr_mux_d, dx_jr_mux_q : std_logic_vector(1 downto 0);

  --signals for Execute stage (X)
  signal x_a, x_b, x_c  : std_logic_vector(31 downto 0);
  signal x_op, x_fn : std_logic_vector(5 downto 0);
  signal x_sh  :  std_logic_vector(4 downto 0);
  signal x_br, x_jp  :  std_logic;
  signal x_sx_immd  : std_logic_vector(31 downto 0);
  signal x_pc :std_logic_vector(31 downto 0); 
      --tmp signals for branch control
  signal x_pc_br: std_logic_vector(31 downto 0);
  signal x_pc_add : std_logic_vector(31 downto 0);
  signal x_pc_mux: std_logic_vector(31 downto 0);
  signal x_pc_targ : std_logic_vector(31 downto 0);
  signal x_pc_nxt : std_logic_vector(31 downto 0);
  signal x_pc_jump : std_logic_vector(31 downto 0);
  
  --signals for X/M latch (XM)
  signal xm_we  : std_logic :='1'; --all latches in X/M share sme WE
  signal xm_b_d, xm_b_q : std_logic_vector(31 downto 0);
  signal xm_c_d, xm_c_q : std_logic_vector(31 downto 0);
  signal xm_rd_d, xm_rd_q : std_logic_vector(4 downto 0);   
  signal xm_rf_we_d, xm_rf_we_q : std_logic_vector(1 downto 0); 
  signal xm_mem_we_d, xm_mem_we_q : std_logic_vector(1 downto 0); 
  signal xm_wb_mux_d, xm_wb_mux_q : std_logic_vector(1 downto 0);
  
  --signals for Data Mem (DM)
  signal dm_addr, dm_do, dm_di  : std_logic_vector(31 downto 0);
  signal dm_clk, dm_we : std_logic;
  
  --signals for M/W latch (MW)
  signal mw_we  : std_logic :='1'; --all latches in M/W share sme WE
  signal mw_c_d, mw_c_q : std_logic_vector(31 downto 0);
  signal mw_do_d, mw_do_q : std_logic_vector(31 downto 0);
  signal mw_rd_d, mw_rd_q : std_logic_vector(4 downto 0);
  signal mw_rf_we_d, mw_rf_we_q : std_logic_vector(1 downto 0);
  signal mw_wb_mux_d, mw_wb_mux_q : std_logic_vector(1 downto 0);
  
  --signal for Write Back Stage (WB)
  signal wb_data  : std_logic_vector(31 downto 0);
  
  --signal for Stall(STL)
  signal stl_dx_rd, stl_xm_rd, stl_mw_rd : std_logic_vector(4 downto 0);
  signal stl_young_insn   : std_logic_vector(31 downto 0);
  signal stl_branch, stl_jump   : std_logic;
  signal stl_stall  : std_logic_vector(1 downto 0);
  
begin
  
-------------------------------------------------------
---  component instantiation of various modules   -----
-------------------------------------------------------

  parser : entity work.parser(main)
  port map (
    CLK => p_clk,
    WE => p_we,
    ADDR => p_addr,
    DATA => p_data
  );
  
  insn_mem : entity work.DRAM(main)
  port map (
    clk => im_clk,
    WE => im_we,
    ADDR => im_addr,
    data_in => im_di,
    data_out => im_do
  ); 

  fetch_mod : entity work.fetch(main)
  port map (
    clk => f_clk,
    stall => f_stall,
    addr => f_addr,
    rw => f_rw,
    pc => f_pc,
    nxt_pc => f_nxt_pc
  );

  decode_mod : entity work.DECODE(main)
  port map  (
    insn => d_insn,
    pc => d_pc,
    vOP => d_OP,
	  vS => d_S,
    vT => d_T,
    vD => d_D,
    vSH => d_SH,
    vFN => d_FN,
    vIMMD => d_IMMD,
    vTAR => d_TAR,
    alu_mux => d_alu_mux,
    rf_we => d_rf_we,
    mem_we => d_mem_we,
    wb_mux => d_wb_mux,
    jp => d_jp,
    stall => d_stall,
    jr_mux => d_jr_mux
  );

  REGFILE : entity work.regfile(main)
  port map (
    clk => rf_clk,
    WE => rf_we,
    Rd => rf_rd,
    C => rf_c,
    Rs => rf_rs,
    Rt => rf_rt,
    A => rf_a,
    B => rf_b
  );

  alu_mod : entity work.ALU(main)
  port map (
    A => x_a,
    B => x_b,
    C => x_c,
    OP => x_op,
    FN => x_fn,
    SH => x_sh,
    BR => x_br,
    PC => x_pc
  );
  
  data_mem : entity work.DRAM(main)
  port map (
    clk => dm_clk,
    WE => dm_we,
    ADDR => dm_addr,
    data_in => dm_di,
    data_out => dm_do
  ); 
  
  stall_logic : entity work.stall(main)
  port map (
    dx_rd => stl_dx_rd,
    xm_rd => stl_xm_rd,
    mw_rd => stl_mw_rd,
    young_insn => stl_young_insn,
    branch => stl_branch,
    jump => stl_jump,
    stall => stl_stall
  ); 

  --component instantiation of various latches
  fd_pc : latch generic map (size => 31) port map (latch_clk, pc_latch_we, fd_pc_d, fd_pc_q);  
  fd_ir : latch generic map (size => 31) port map (latch_clk, fd_we, fd_ir_d, fd_ir_q);
  dx_pc : latch generic map (size => 31) port map (latch_clk, pc_latch_we, dx_pc_d, dx_pc_q); 
  dx_a  : latch generic map (size => 31) port map (latch_clk, dx_we, dx_a_d, dx_a_q); 
  dx_b  : latch generic map (size => 31) port map (latch_clk, dx_we, dx_b_d, dx_b_q); 
  dx_op : latch generic map (size => 5) port map (latch_clk, dx_we, dx_op_d, dx_op_q); 
  dx_fn : latch generic map (size => 5) port map (latch_clk, dx_we, dx_fn_d, dx_fn_q);
  dx_sh : latch generic map (size => 4) port map (latch_clk, dx_we, dx_sh_d, dx_sh_q); 
  dx_rd : latch generic map (size => 4) port map (latch_clk, dx_we, dx_rd_d, dx_rd_q);
  dx_immd : latch generic map (size => 15) port map (latch_clk, dx_we, dx_immd_d, dx_immd_q); 
  dx_tar : latch generic map (size => 25) port map (latch_clk, dx_we, dx_tar_d, dx_tar_q);
  dx_alu_mux : latch generic map (size => 1) port map (latch_clk, dx_we, dx_alu_mux_d, dx_alu_mux_q);
  dx_rf_we : latch generic map (size => 1) port map (latch_clk, dx_we, dx_rf_we_d, dx_rf_we_q);  
  dx_mem_we : latch generic map (size => 1) port map (latch_clk, dx_we, dx_mem_we_d, dx_mem_we_q);  
  dx_wb_mux : latch generic map (size => 1) port map (latch_clk, dx_we, dx_wb_mux_d, dx_wb_mux_q);
  dx_jr_mux : latch generic map (size => 1) port map (latch_clk, dx_we, dx_jr_mux_d, dx_jr_mux_q);  
  dx_jp : latch generic map (size => 1) port map (latch_clk, dx_we, dx_jp_d, dx_jp_q);   
  xm_b  : latch generic map (size => 31) port map (latch_clk, xm_we, xm_b_d, xm_b_q);
  xm_c  : latch generic map (size => 31) port map (latch_clk, xm_we, xm_c_d, xm_c_q);
  xm_rd : latch generic map (size => 4) port map (latch_clk, xm_we, xm_rd_d, xm_rd_q);
  xm_rf_we : latch generic map (size => 1) port map (latch_clk, xm_we, xm_rf_we_d, xm_rf_we_q);
  xm_mem_we : latch generic map (size => 1) port map (latch_clk, xm_we, xm_mem_we_d, xm_mem_we_q); 
  xm_wb_mux : latch generic map (size => 1) port map (latch_clk, xm_we, xm_wb_mux_d, xm_wb_mux_q);    
  mw_c  :  latch generic map (size => 31) port map (latch_clk, mw_we, mw_c_d, mw_c_q);
  mw_do  :  latch generic map (size => 31) port map (latch_clk, mw_we, mw_do_d, mw_do_q);
  mw_rd  :  latch generic map (size => 4) port map (latch_clk, mw_we, mw_rd_d, mw_rd_q);
  mw_rf_we  :  latch generic map (size => 1) port map (latch_clk, mw_we, mw_rf_we_d, mw_rf_we_q);    
  mw_wb_mux  :  latch generic map (size => 1) port map (latch_clk, mw_we, mw_wb_mux_d, mw_wb_mux_q); 
    
  
-------------------------------------------------------    
---    connect wires of diff components together   ----
-------------------------------------------------------

  im_di <= p_data; --connect parser and insn mem together
  
  f_nxt_pc <= x_pc_nxt; --connect the ouput of PC control logic to input of FETCH
  f_stall <= stl_stall(0); --connect stall signal from stall logic unit to stall port of fetch
  fd_pc_d <= f_pc_4; --connect pc+4 from fetch to F/D latch
    
  d_insn <= fd_ir_q; --connect F/D latch to input of decoder
  d_pc <= fd_pc_q; --connect F/D latch to input of decoder 
  d_stall <= stl_stall; --connect stall signal from stall logic unit to stall port of decoder 
  
  rf_rs <= d_S; --connect source1 from decode to RS of REGFILE
  rf_rt <= d_T; --connect source2 from decode to RT of REGFILE
  
  dx_pc_d <= fd_pc_q; --connect F/D pc latch to D/X pc latch
  dx_a_d <= rf_a; --connect output1 of regfile to D/X latch
  dx_b_d <= rf_b; --connect output2 of regfile to D/X latch  
  dx_op_d <= d_OP; --connect the OP output from decoder to D/X latch
  dx_fn_d <= d_FN; --connect the FN output from decoder to D/X latch
  dx_sh_d <= d_SH; --connect the SH output from decoder to D/X latch
  dx_rd_d <= d_D; --connect the Destination REG addr from decoder to DX latch
  dx_immd_d <= d_IMMD; --connect the IMMD output from decoder to D/X latch
  dx_tar_d <= d_TAR; --connect the TAR output from decoder to D/X latch
  dx_alu_mux_d <= d_alu_mux; --connect the alu_mux output from decoder to D/X latch
  dx_rf_we_d <= d_rf_we; --connect rf_we output from decoder to DX latch
  dx_mem_we_d <= d_mem_we; --connect mem_we output from decoder to DX latch
  dx_wb_mux_d <= d_wb_mux; --conecct wb_mux output from decoder to DX latch
  dx_jp_d <= d_jp; --connect jump control signal from output of decoder to DX latch
  dx_jr_mux_d <= d_jr_mux; --
  
  x_a <= dx_a_q; --connect input A of ALU from output of DX latch
  x_op <= dx_op_q; --connect input OP of ALU from output of DX latch
  x_fn <= dx_fn_q; --connect input FN of ALU from output of DX latch
  x_sh <= dx_sh_q; --connect input SH of ALU from output of DX latch
  x_pc <= dx_pc_q; --connect output of dx_pc latch to input of ALU
  
  xm_b_d <= dx_b_q; --connect second operand from dx latch to xm latch (used for store insn)
  xm_c_d <= x_c; --connect output of ALU operation to input of xm latch
  xm_rd_d <= dx_rd_q; --connect the destination reg addr from dx latch to xm latch
  xm_rf_we_d <= dx_rf_we_q; --forward the control for reg file we from dx latch to xm latch
  xm_mem_we_d <= dx_mem_we_q; --forward the control for mem WE from dx latch to xm latch
  xm_wb_mux_d <= dx_wb_mux_q; --forward the wb mux control bit from dx latch to xm latch
  
  mw_c_d <= xm_c_q; --connect ouput of ALU operation to MW latch
  mw_do_d <= dm_do; --connect ouput of data mem to MW latch
  mw_rd_d <= xm_rd_q; --forward Dest. Reg Addr from XM latch to MW latch
  mw_rf_we_d <= xm_rf_we_q; --foward Reg File WE from XM latch to MW latch
  mw_wb_mux_d <= xm_wb_mux_q; --forward WB mux control signal from XM to MW latch
  
  stl_dx_rd <= dx_rd_q;
  stl_xm_rd <= xm_rd_q;
  stl_mw_rd <= mw_rd_q;
  stl_young_insn <= fd_ir_q;
  stl_branch <= x_br;
  stl_jump <= x_jp;
    

-------------------------------------------------------
-------     Control wires connected      --------------
-------------------------------------------------------

  --mux the input of insn&data mem for addr and we (because parser needs to first load the mem)
  im_we <= '1' when p_we='1' else f_rw when p_we='0';
  im_addr <= p_addr when p_we='1' else f_addr when p_we='0';
  dm_we <= '1' when p_we='1' else xm_mem_we_q(0) when p_we='0';
  dm_addr <= p_addr when p_we='1' else xm_c_q when p_we='0';
  dm_di <= p_data when p_we='1' else xm_b_q when p_we='0';  
  
  --enable pc_latch we only when we're not stalling but all other latches can propogate values forward
  pc_latch_we <= '1' when stl_stall="00" else '0';
  
  --Sign extend the Immd value
  x_sx_immd <= std_logic_vector(resize(signed(dx_immd_q),x_sx_immd'length));
  
  --mux the 2nd input of ALU
  x_b <= dx_b_q when dx_alu_mux_q="00" else x_sx_immd when dx_alu_mux_q="01";
  
  --control for branch and jump
  f_pc_4 <= std_logic_vector(unsigned(f_pc) + x"00000004");
  x_pc_br <= to_stdlogicvector(to_bitvector(x_sx_immd) sll 2);
  x_pc_add <= std_logic_vector( signed(dx_pc_q) + signed(x_pc_br) );
  x_pc_mux <= f_pc_4 when x_br='0' else x_pc_add when x_br='1';
  x_pc_targ(31 downto 28) <= f_pc_4(31 downto 28);
  x_pc_targ(27 downto 2) <= dx_tar_q;
  x_pc_targ(1 downto 0) <= b"00";
  x_pc_jump <= x_pc_targ when dx_jr_mux_q(0)='0' else dx_a_q when dx_jr_mux_q(0)='1';
  x_pc_nxt <=x_pc_mux when x_jp='0' else x_pc_jump when x_jp='1';
  x_jp <= dx_jp_q(0);
   
  --control for WB stage
  wb_data <= mw_c_q when mw_wb_mux_q=b"00" else mw_do_q when mw_wb_mux_q=b"01";
  rf_c <= wb_data;
  rf_we <= mw_rf_we_q(0);
  rf_rd <= mw_rd_q;
    
  
 fd_ir_d <= x"00000000" when stl_stall="10" else im_do when stl_stall="00" else fd_ir_q when stl_stall="01";  
  
-------------------------------------------------------
---------          clock processes       --------------
-------------------------------------------------------
  parser_clk: process
  begin
    p_clk <= '0';
    wait for 10ns;
    p_clk <= '1';
    wait for 10ns;
  end process;

  mem_clk: process
  begin
    im_clk <= '1';
    dm_clk <= '1';
    wait for 10ns;
    im_clk <= '0';
    dm_clk <= '0';
    wait for 10ns;
  end process;
  
  pipeline_clk: process
  begin
    wait until falling_edge(p_we);
    --wait for 5ns;
    loop
      wait for 10ns;
      f_clk <= not f_clk;
      latch_clk <= not latch_clk;    
    end loop;
	end process;
	
	REGF_clk: process
  begin
    wait until falling_edge(p_we);
    wait for 5ns;
    loop
      wait for 10ns;
      rf_clk <= not rf_clk;      
    end loop;
	end process;     
	    
    
end architecture;