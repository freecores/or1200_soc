// --------------------------------------------------------------------
//
// --------------------------------------------------------------------


`include "timescale.v"
`include "or1200_defines.v"
`include "soc_defines.v"


module soc_top
(
  ////////////////////////////  UART  ////////////////////////////
  output          uart_txd_0,       //  UART Transmitter
  input           uart_rxd_0,       //  UART Receiver
  ///////////////////////   SDRAM Interface ////////////////////////
//   inout [15:0]    DRAM_DQ,        //  SDRAM Data bus 16 Bits
//   output  [11:0]  DRAM_ADDR,      //  SDRAM Address bus 12 Bits
//   output          DRAM_LDQM,      //  SDRAM Low-byte Data Mask
//   output          DRAM_UDQM,      //  SDRAM High-byte Data Mask
//   output          DRAM_WE_N,      //  SDRAM Write Enable
//   output          DRAM_CAS_N,     //  SDRAM Column Address Strobe
//   output          DRAM_RAS_N,     //  SDRAM Row Address Strobe
//   output          DRAM_CS_N,      //  SDRAM Chip Select
//   output          DRAM_BA_0,      //  SDRAM Bank Address 0
//   output          DRAM_BA_1,      //  SDRAM Bank Address 0
//   output          DRAM_CLK,       //  SDRAM Clock
//   output          DRAM_CKE,       //  SDRAM Clock Enable
  ////////////////////////  Flash Interface ////////////////////////
  inout [7:0]     fl_dq,          //  flash data bus 8 bits
  output  [21:0]  fl_addr,        //  flash address bus 22 bits
  output          fl_we_n,        //  flash write enable
  output          fl_rst_n,       //  flash reset
  output          fl_oe_n,        //  flash output enable
  output          fl_ce_n,        //  flash chip enable
  ////////////////////////  sram interface  ////////////////////////
  inout [15:0]    sram_dq,        //  sram data bus 16 bits
  output  [17:0]  sram_addr,      //  sram address bus 18 bits
  output          sram_ub_n,      //  sram high-byte data mask
  output          sram_lb_n,      //  sram low-byte data mask
  output          sram_we_n,      //  sram write enable
  output          sram_ce_n,      //  sram chip enable
  output          sram_oe_n,      //  sram output enable
  
  input   [31:0]  gpio_a_aux_i,		
  input   [31:0]  gpio_a_ext_pad_i,	
  output  [31:0]  gpio_a_ext_pad_o,	
  output  [31:0]  gpio_a_ext_padoe_o,	

  input   [31:0]  gpio_b_aux_i,		
  input   [31:0]  gpio_b_ext_pad_i,	
  output  [31:0]  gpio_b_ext_pad_o,	
  output  [31:0]  gpio_b_ext_padoe_o,	

  input   [31:0]  gpio_c_aux_i,		
  input   [31:0]  gpio_c_ext_pad_i,	
  output  [31:0]  gpio_c_ext_pad_o,	
  output  [31:0]  gpio_c_ext_padoe_o,	

  input   [31:0]  gpio_d_aux_i,		
  input   [31:0]  gpio_d_ext_pad_i,	
  output  [31:0]  gpio_d_ext_pad_o,	
  output  [31:0]  gpio_d_ext_padoe_o,	

  input   [31:0]  gpio_e_aux_i,		
  input   [31:0]  gpio_e_ext_pad_i,	
  output  [31:0]  gpio_e_ext_pad_o,	
  output  [31:0]  gpio_e_ext_padoe_o,	

  input   [31:0]  gpio_f_aux_i,		
  input   [31:0]  gpio_f_ext_pad_i,	
  output  [31:0]  gpio_f_ext_pad_o,	
  output  [31:0]  gpio_f_ext_padoe_o,	

  input   [31:0]  gpio_g_aux_i,		
  input   [31:0]  gpio_g_ext_pad_i,	
  output  [31:0]  gpio_g_ext_pad_o,	
  output  [31:0]  gpio_g_ext_padoe_o,	

  input [3:0]     boot_strap,
  
`ifdef USE_DEBUG_0  
  output [255:0]  debug_0,
`endif
  
  input           sys_clk,
  input           sys_rst
);


  //  All inout port turn to tri-state
  assign  DRAM_DQ   = 16'hzzzz;
  assign  FL_DQ   = 8'hzz;


  //---------------------------------------------------
  // or1200_top
  //---------------------------------------------------
  parameter dw = `OR1200_OPERAND_WIDTH;
  parameter aw = `OR1200_OPERAND_WIDTH;


  // System
  wire      clk_i = sys_clk;
  wire      rst_i = sys_rst;

  //---------------------------------------------------
  // Instruction WISHBONE interface
  wire            iwb_clk_i = sys_clk;
  wire            iwb_rst_i = sys_rst;
  wire            iwb_ack_i;
  wire            iwb_err_i;
  wire            iwb_rty_i;
  wire  [dw-1:0]  iwb_dat_i;
  wire            iwb_cyc_o;
  wire  [aw-1:0]  iwb_adr_o;
  wire            iwb_stb_o;
  wire            iwb_we_o;
  wire  [3:0]     iwb_sel_o;
  wire  [dw-1:0]  iwb_dat_o;
  wire            iwb_cab_o;

  //---------------------------------------------------
  // Data WISHBONE interface
  wire            dwb_clk_i = sys_clk;
  wire            dwb_rst_i = sys_rst;
  wire            dwb_ack_i;
  wire            dwb_err_i;
  wire            dwb_rty_i;
  wire  [dw-1:0]  dwb_dat_i;
  wire            dwb_cyc_o;
  wire  [aw-1:0]  dwb_adr_o;
  wire            dwb_stb_o;
  wire            dwb_we_o;
  wire  [3:0]     dwb_sel_o;
  wire  [dw-1:0]  dwb_dat_o;
  wire            dwb_cab_o;

  or1200_top i_or1200_top(
                          //---------------------------------------------------
                          // Instruction WISHBONE interface
                          .iwb_clk_i(iwb_clk_i),  // clock input
                          .iwb_rst_i(iwb_rst_i),  // reset input
                          .iwb_ack_i(iwb_ack_i),  // normal termination
                          .iwb_err_i(iwb_err_i),  // termination w/ error
                          .iwb_rty_i(iwb_rty_i),  // termination w/ retry
                          .iwb_dat_i(iwb_dat_i),  // input data bus
                          .iwb_cyc_o(iwb_cyc_o),  // cycle valid output
                          .iwb_adr_o(iwb_adr_o),  // address bus outputs
                          .iwb_stb_o(iwb_stb_o),  // strobe output
                          .iwb_we_o(iwb_we_o),  // indicates write transfer
                          .iwb_sel_o(iwb_sel_o),  // byte select outputs
                          .iwb_dat_o(iwb_dat_o),  // output data bus
  `ifdef OR1200_WB_CAB
                          .iwb_cab_o(iwb_cab_o),  // indicates consecutive address burst
  `endif
  `ifdef OR1200_WB_B3
                          .iwb_cti_o(iwb_cti_o),  // cycle type identifier
                          .iwb_bte_o(iwb_bte_o),  // burst type extension
  `endif

                          //---------------------------------------------------
                          // Data WISHBONE interface
                          .dwb_clk_i(dwb_clk_i),  // clock input
                          .dwb_rst_i(dwb_rst_i),  // reset input
                          .dwb_ack_i(dwb_ack_i),  // normal termination
                          .dwb_err_i(dwb_err_i),  // termination w/ error
                          .dwb_rty_i(dwb_rty_i),  // termination w/ retry
                          .dwb_dat_i(dwb_dat_i),  // input data bus
                          .dwb_cyc_o(dwb_cyc_o),  // cycle valid output
                          .dwb_adr_o(dwb_adr_o),  // address bus outputs
                          .dwb_stb_o(dwb_stb_o),  // strobe output
                          .dwb_we_o(dwb_we_o),  // indicates write transfer
                          .dwb_sel_o(dwb_sel_o),  // byte select outputs
                          .dwb_dat_o(dwb_dat_o),  // output data bus
  `ifdef OR1200_WB_CAB
                          .dwb_cab_o(dwb_cab_o),  // indicates consecutive address burst
  `endif
  `ifdef OR1200_WB_B3
                          .dwb_cti_o(dwb_cti_o),  // cycle type identifier
                          .dwb_bte_o(dwb_bte_o),  // burst type extension
  `endif

                          //---------------------------------------------------
                          // External Debug Interface
                          .dbg_stall_i(1'b0), // External Stall Input
//                           .dbg_ewt_i(dbg_ewt_i), // External Watchpoint Trigger Input
//                           .dbg_lss_o(dbg_lss_o), // External Load/Store Unit Status
//                           .dbg_is_o(dbg_is_o), // External Insn Fetch Status
//                           .dbg_wp_o(dbg_wp_o), // Watchpoints Outputs
//                           .dbg_bp_o(dbg_bp_o), // Breakpoint Output
//                           .dbg_stb_i(dbg_stb_i),      // External Address/Data Strobe
//                           .dbg_we_i(dbg_we_i),       // External Write Enable
//                           .dbg_adr_i(dbg_adr_i), // External Address Input
//                           .dbg_dat_i(dbg_dat_i), // External Data Input
//                           .dbg_dat_o(dbg_dat_o), // External Data Output
//                           .dbg_ack_o(dbg_ack_o), // External Data Acknowledge (not WB compatible)


                          //---------------------------------------------------
                          // RAM BIST
  `ifdef OR1200_BIST
                          .mbist_si_i(mbist_si_i),
                          .mbist_ctrl_i(mbist_ctrl_i),
                          .mbist_so_o(mbist_so_o),
  `endif

                        //---------------------------------------------------
                        // Power Management
//                         .pm_cpustall_i(pm_cpustall_i),
//                         .pm_clksd_o(pm_clksd_o),
//                         .pm_dc_gate_o(pm_dc_gate_o),
//                         .pm_ic_gate_o(pm_ic_gate_o),
//                         .pm_dmmu_gate_o(pm_dmmu_gate_o),
//                         .pm_immu_gate_o(pm_immu_gate_o),
//                         .pm_tt_gate_o(pm_tt_gate_o),
//                         .pm_cpu_gate_o(pm_cpu_gate_o),
//                         .pm_wakeup_o(pm_wakeup_o),
//                         .pm_lvolt_o(pm_lvolt_o),
//
                        //---------------------------------------------------
                        // System
//                         .clmode_i(clmode_i), // 00 WB=RISC, 01 WB=RISC/2, 10 N/A, 11 WB=RISC/4
//                         .pic_ints_i(pic_ints_i),
                          .clk_i(clk_i),
                          .rst_i(rst_i)
                        );


  //---------------------------------------------------
  // wb_conmax_top

  // Slave 0 Interface
  parameter   sw = dw / 8;  // Number of Select Lines

  wire  [dw-1:0]  s0_data_i;
  wire  [dw-1:0]  s0_data_o;
  wire  [aw-1:0]  s0_addr_o;
  wire  [sw-1:0]  s0_sel_o;
  wire            s0_we_o;
  wire            s0_cyc_o;
  wire            s0_stb_o;
  wire            s0_ack_i;
  wire            s0_err_i;
  wire            s0_rty_i;

  wire  [dw-1:0]  s1_data_i;
  wire  [dw-1:0]  s1_data_o;
  wire  [aw-1:0]  s1_addr_o;
  wire  [sw-1:0]  s1_sel_o;
  wire            s1_we_o;
  wire            s1_cyc_o;
  wire            s1_stb_o;
  wire            s1_ack_i;
  wire            s1_err_i;
  wire            s1_rty_i;

  wire  [dw-1:0]  s2_data_i;
  wire  [dw-1:0]  s2_data_o;
  wire  [aw-1:0]  s2_addr_o;
  wire  [sw-1:0]  s2_sel_o;
  wire            s2_we_o;
  wire            s2_cyc_o;
  wire            s2_stb_o;
  wire            s2_ack_i;
  wire            s2_err_i;
  wire            s2_rty_i;

  wire  [dw-1:0]  s3_data_i;
  wire  [dw-1:0]  s3_data_o;
  wire  [aw-1:0]  s3_addr_o;
  wire  [sw-1:0]  s3_sel_o;
  wire            s3_we_o;
  wire            s3_cyc_o;
  wire            s3_stb_o;
  wire            s3_ack_i;
  wire            s3_err_i;
  wire            s3_rty_i;

  wire  [dw-1:0]  s4_data_i;
  wire  [dw-1:0]  s4_data_o;
  wire  [aw-1:0]  s4_addr_o;
  wire  [sw-1:0]  s4_sel_o;
  wire            s4_we_o;
  wire            s4_cyc_o;
  wire            s4_stb_o;
  wire            s4_ack_i;
  wire            s4_err_i;
  wire            s4_rty_i;

  wire  [dw-1:0]  s5_data_i;
  wire  [dw-1:0]  s5_data_o;
  wire  [aw-1:0]  s5_addr_o;
  wire  [sw-1:0]  s5_sel_o;
  wire            s5_we_o;
  wire            s5_cyc_o;
  wire            s5_stb_o;
  wire            s5_ack_i;
  wire            s5_err_i;
  wire            s5_rty_i;

  wire  [dw-1:0]  s6_data_i;
  wire  [dw-1:0]  s6_data_o;
  wire  [aw-1:0]  s6_addr_o;
  wire  [sw-1:0]  s6_sel_o;
  wire            s6_we_o;
  wire            s6_cyc_o;
  wire            s6_stb_o;
  wire            s6_ack_i;
  wire            s6_err_i;
  wire            s6_rty_i;
      
  wire  [1:0]     boot_remap;
  wire  [aw-1:0]  iwb_remap_adr;
  wire  [aw-1:0]  dwb_remap_adr;

  wb_conmax_top
    i_wb_conmax_top(
                      // Master 0 Interface
                      .m0_data_i(iwb_dat_o),
                      .m0_data_o(iwb_dat_i),
                      .m0_addr_i(iwb_adr_o),
                      .m0_sel_i(iwb_sel_o),
                      .m0_we_i(iwb_we_o),
                      .m0_cyc_i(iwb_cyc_o),
                      .m0_stb_i(iwb_stb_o),
                      .m0_ack_o(iwb_ack_i),
                      .m0_err_o(iwb_err_i),
                      .m0_rty_o(iwb_rty_i),
                      // Master 1 Interface
                      .m1_data_i(dwb_dat_o),
                      .m1_data_o(dwb_dat_i),
                      .m1_addr_i(dwb_adr_o),
                      .m1_sel_i(dwb_sel_o),
                      .m1_we_i(dwb_we_o),
                      .m1_cyc_i(dwb_cyc_o),
                      .m1_stb_i(dwb_stb_o),
                      .m1_ack_o(dwb_ack_i),
                      .m1_err_o(dwb_err_i),
                      .m1_rty_o(dwb_rty_i),
                      // Master 2 Interface
                      .m2_data_i(32'h0000_0000),
                      .m2_addr_i(32'h0000_0000),
                      .m2_sel_i(4'h0),
                      .m2_we_i(1'b0),
                      .m2_cyc_i(1'b0),
                      .m2_stb_i(1'b0),
                      // Master 3 Interface
                      .m3_data_i(32'h0000_0000),
                      .m3_addr_i(32'h0000_0000),
                      .m3_sel_i(4'h0),
                      .m3_we_i(1'b0),
                      .m3_cyc_i(1'b0),
                      .m3_stb_i(1'b0),
                      // Master 4 Interface
                      .m4_data_i(32'h0000_0000),
                      .m4_addr_i(32'h0000_0000),
                      .m4_sel_i(4'h0),
                      .m4_we_i(1'b0),
                      .m4_cyc_i(1'b0),
                      .m4_stb_i(1'b0),
                      // Master 5 Interface
                      .m5_data_i(32'h0000_0000),
                      .m5_addr_i(32'h0000_0000),
                      .m5_sel_i(4'h0),
                      .m5_we_i(1'b0),
                      .m5_cyc_i(1'b0),
                      .m5_stb_i(1'b0),
                      // Master 6 Interface
                      .m6_data_i(32'h0000_0000),
                      .m6_addr_i(32'h0000_0000),
                      .m6_sel_i(4'h0),
                      .m6_we_i(1'b0),
                      .m6_cyc_i(1'b0),
                      .m6_stb_i(1'b0),
                      // Master 7 Interface
                      .m7_data_i(32'h0000_0000),
                      .m7_addr_i(32'h0000_0000),
                      .m7_sel_i(4'h0),
                      .m7_we_i(1'b0),
                      .m7_cyc_i(1'b0),
                      .m7_stb_i(1'b0),

                      // Slave 0 Interface
                      .s0_data_i(s0_data_i),
                      .s0_data_o(s0_data_o),
                      .s0_addr_o(s0_addr_o),
                      .s0_sel_o(s0_sel_o),
                      .s0_we_o(s0_we_o),
                      .s0_cyc_o(s0_cyc_o),
                      .s0_stb_o(s0_stb_o),
                      .s0_ack_i(s0_ack_i),
                      .s0_err_i(s0_err_i),
                      .s0_rty_i(s0_rty_i),
                      // Slave 1 Interface
                      .s1_data_i(s1_data_i),
                      .s1_data_o(s1_data_o),
                      .s1_addr_o(s1_addr_o),
                      .s1_sel_o(s1_sel_o),
                      .s1_we_o(s1_we_o),
                      .s1_cyc_o(s1_cyc_o),
                      .s1_stb_o(s1_stb_o),
                      .s1_ack_i(s1_ack_i),
                      .s1_err_i(s1_err_i),
                      .s1_rty_i(s1_rty_i),
                      // Slave 2 Interface
                      .s2_data_i(s2_data_i),
                      .s2_data_o(s2_data_o),
                      .s2_addr_o(s2_addr_o),
                      .s2_sel_o(s2_sel_o),
                      .s2_we_o(s2_we_o),
                      .s2_cyc_o(s2_cyc_o),
                      .s2_stb_o(s2_stb_o),
                      .s2_ack_i(s2_ack_i),
                      .s2_err_i(s2_err_i),
                      .s2_rty_i(s2_rty_i),
                      // Slave 3 Interface
                      .s3_data_i(s3_data_i),
                      .s3_data_o(s3_data_o),
                      .s3_addr_o(s3_addr_o),
                      .s3_sel_o(s3_sel_o),
                      .s3_we_o(s3_we_o),
                      .s3_cyc_o(s3_cyc_o),
                      .s3_stb_o(s3_stb_o),
                      .s3_ack_i(s3_ack_i),
                      .s3_err_i(s3_err_i),
                      .s3_rty_i(s3_rty_i),
                      // Slave 4 Interface
                      .s4_data_i(s4_data_i),
                      .s4_data_o(s4_data_o),
                      .s4_addr_o(s4_addr_o),
                      .s4_sel_o(s4_sel_o),
                      .s4_we_o(s4_we_o),
                      .s4_cyc_o(s4_cyc_o),
                      .s4_stb_o(s4_stb_o),
                      .s4_ack_i(s4_ack_i),
                      .s4_err_i(s4_err_i),
                      .s4_rty_i(s4_rty_i),
                      // Slave 5 Interface
                      .s5_data_i(s5_data_i),
                      .s5_data_o(s5_data_o),
                      .s5_addr_o(s5_addr_o),
                      .s5_sel_o(s5_sel_o),
                      .s5_we_o(s5_we_o),
                      .s5_cyc_o(s5_cyc_o),
                      .s5_stb_o(s5_stb_o),
                      .s5_ack_i(s5_ack_i),
                      .s5_err_i(s5_err_i),
                      .s5_rty_i(s5_rty_i),
                      // Slave 6 Interface
                      .s6_data_i(s6_data_i),
                      .s6_data_o(s6_data_o),
                      .s6_addr_o(s6_addr_o),
                      .s6_sel_o(s6_sel_o),
                      .s6_we_o(s6_we_o),
                      .s6_cyc_o(s6_cyc_o),
                      .s6_stb_o(s6_stb_o),
                      .s6_ack_i(s6_ack_i),
                      .s6_err_i(s6_err_i),
                      .s6_rty_i(s6_rty_i),
                      // Slave 7 Interface
                      .s7_data_i(32'h0000_0000),
                      .s7_ack_i(1'b0),
                      .s7_err_i(1'b0),
                      .s7_rty_i(1'b0),
                      // Slave 8 Interface
                      .s8_data_i(32'h0000_0000),
                      .s8_ack_i(1'b0),
                      .s8_err_i(1'b0),
                      .s8_rty_i(1'b0),
                      // Slave 9 Interface
                      .s9_data_i(32'h0000_0000),
                      .s9_ack_i(1'b0),
                      .s9_err_i(1'b0),
                      .s9_rty_i(1'b0),
                      // Slave 10 Interface
                      .s10_data_i(32'h0000_0000),
                      .s10_ack_i(1'b0),
                      .s10_err_i(1'b0),
                      .s10_rty_i(1'b0),
                      // Slave 11 Interface
                      .s11_data_i(32'h0000_0000),
                      .s11_ack_i(1'b0),
                      .s11_err_i(1'b0),
                      .s11_rty_i(1'b0),
                      // Slave 12 Interface
                      .s12_data_i(32'h0000_0000),
                      .s12_ack_i(1'b0),
                      .s12_err_i(1'b0),
                      .s12_rty_i(1'b0),
                      // Slave 13 Interface
                      .s13_data_i(32'h0000_0000),
                      .s13_ack_i(1'b0),
                      .s13_err_i(1'b0),
                      .s13_rty_i(1'b0),
                      // Slave 14 Interface
                      .s14_data_i(32'h0000_0000),
                      .s14_ack_i(1'b0),
                      .s14_err_i(1'b0),
                      .s14_rty_i(1'b0),
                      // Slave 15 Interface
                      .s15_data_i(32'h0000_0000),
                      .s15_ack_i(1'b0),
                      .s15_err_i(1'b0),
                      .s15_rty_i(1'b0),

                      .clk_i(clk_i),
                      .rst_i(rst_i)
                    );

  //---------------------------------------------------
  // soc_boot
  wire  [1:0] boot_select;

  soc_boot i_soc_boot(
                      .mem_data_i(s0_data_o),
                      .mem_data_o(s0_data_i),
                      .mem_addr_i(s0_addr_o),
                      .mem_sel_i(s0_sel_o),
                      .mem_we_i(s0_we_o),
                      .mem_cyc_i(s0_cyc_o),
                      .mem_stb_i(s0_stb_o),
                      .mem_ack_o(s0_ack_i),
                      .mem_err_o(s0_err_i),
                      .mem_rty_o(s0_rty_i),

                      .boot_select(boot_select),

                      .mem_clk_i(clk_i),
                      .mem_rst_i(rst_i)
                    );


  //---------------------------------------------------
  // soc_mem_bank_1
  soc_mem_bank_1
    i_soc_mem_bank_1(
                      .mem_data_i(s1_data_o),
                      .mem_data_o(s1_data_i),
                      .mem_addr_i(s1_addr_o),
                      .mem_sel_i(s1_sel_o),
                      .mem_we_i(s1_we_o),
                      .mem_cyc_i(s1_cyc_o),
                      .mem_stb_i(s1_stb_o),
                      .mem_ack_o(s1_ack_i),
                      .mem_err_o(s1_err_i),
                      .mem_rty_o(s1_rty_i),

                      .mem_clk_i(clk_i),
                      .mem_rst_i(rst_i)
                    );

  //---------------------------------------------------
  // soc_mem_bank_2
  soc_mem_bank_2
    i_soc_mem_bank_2(
                      .mem_data_i(s2_data_o),
                      .mem_data_o(s2_data_i),
                      .mem_addr_i(s2_addr_o),
                      .mem_sel_i(s2_sel_o),
                      .mem_we_i(s2_we_o),
                      .mem_cyc_i(s2_cyc_o),
                      .mem_stb_i(s2_stb_o),
                      .mem_ack_o(s2_ack_i),
                      .mem_err_o(s2_err_i),
                      .mem_rty_o(s2_rty_i),

                      .mem_clk_i(clk_i),
                      .mem_rst_i(rst_i)
                    );

  //---------------------------------------------------
  // soc_mem_bank_3
  soc_mem_bank_3
    i_soc_mem_bank_3(
                      .mem_data_i(s3_data_o),
                      .mem_data_o(s3_data_i),
                      .mem_addr_i(s3_addr_o),
                      .mem_sel_i(s3_sel_o),
                      .mem_we_i(s3_we_o),
                      .mem_cyc_i(s3_cyc_o),
                      .mem_stb_i(s3_stb_o),
                      .mem_ack_o(s3_ack_i),
                      .mem_err_o(s3_err_i),
                      .mem_rty_o(s3_rty_i),

                      .mem_clk_i(clk_i),
                      .mem_rst_i(rst_i)
                    );

  //---------------------------------------------------
  // soc_system
  soc_system
    i_soc_system(
                  .sys_data_i(s4_data_o),
                  .sys_data_o(s4_data_i),
                  .sys_addr_i(s4_addr_o),
                  .sys_sel_i(s4_sel_o),
                  .sys_we_i(s4_we_o),
                  .sys_cyc_i(s4_cyc_o),
                  .sys_stb_i(s4_stb_o),
                  .sys_ack_o(s4_ack_i),
                  .sys_err_o(s4_err_i),
                  .sys_rty_o(s4_rty_i),

                  .boot_strap(boot_strap),
                  .boot_select(boot_select),
                  .boot_remap(boot_remap),
                      
                  .sys_clk_i(clk_i),
                  .sys_rst_i(rst_i)
                );

  //---------------------------------------------------
  // peripherals
  soc_peripherals
    i_soc_peripherals(
                        .peri_data_i(s5_data_o),
                        .peri_data_o(s5_data_i),
                        .peri_addr_i(s5_addr_o),
                        .peri_sel_i(s5_sel_o),
                        .peri_we_i(s5_we_o),
                        .peri_cyc_i(s5_cyc_o),
                        .peri_stb_i(s5_stb_o),
                        .peri_ack_o(s5_ack_i),
                        .peri_err_o(s5_err_i),
                        .peri_rty_o(s5_rty_i),
      
                        .uart_txd_0(uart_txd_0),
                        .uart_rxd_0(uart_rxd_0),
                            
                        .peri_clk_i(clk_i),
                        .peri_rst_i(rst_i)
                      );

  //---------------------------------------------------
  // gpio
  soc_gpio
    i_soc_gpio(
                  .gpio_data_i(s6_data_o),
                  .gpio_data_o(s6_data_i),
                  .gpio_addr_i(s6_addr_o),
                  .gpio_sel_i(s6_sel_o),
                  .gpio_we_i(s6_we_o),
                  .gpio_cyc_i(s6_cyc_o),
                  .gpio_stb_i(s6_stb_o),
                  .gpio_ack_o(s6_ack_i),
                  .gpio_err_o(s6_err_i),
                  .gpio_rty_o(s6_rty_i),
                            
                  .gpio_a_aux_i(gpio_a_aux_i),		
                  .gpio_a_ext_pad_i(gpio_a_ext_pad_i),	
                  .gpio_a_ext_pad_o(gpio_a_ext_pad_o),	
                  .gpio_a_ext_padoe_o(gpio_a_ext_padoe_o),	
                  .gpio_a_inta_o(),
                    
                  .gpio_b_aux_i(gpio_b_aux_i),		
                  .gpio_b_ext_pad_i(gpio_b_ext_pad_i),	
                  .gpio_b_ext_pad_o(gpio_b_ext_pad_o),	
                  .gpio_b_ext_padoe_o(gpio_b_ext_padoe_o),	
                  .gpio_b_inta_o(),

                  .gpio_c_aux_i(gpio_c_aux_i),		
                  .gpio_c_ext_pad_i(gpio_c_ext_pad_i),	
                  .gpio_c_ext_pad_o(gpio_c_ext_pad_o),	
                  .gpio_c_ext_padoe_o(gpio_c_ext_padoe_o),	
                  .gpio_c_inta_o(),

                  .gpio_d_aux_i(gpio_d_aux_i),		
                  .gpio_d_ext_pad_i(gpio_d_ext_pad_i),	
                  .gpio_d_ext_pad_o(gpio_d_ext_pad_o),	
                  .gpio_d_ext_padoe_o(gpio_d_ext_padoe_o),	
                  .gpio_d_inta_o(),

                  .gpio_e_aux_i(gpio_e_aux_i),		
                  .gpio_e_ext_pad_i(gpio_e_ext_pad_i),	
                  .gpio_e_ext_pad_o(gpio_e_ext_pad_o),	
                  .gpio_e_ext_padoe_o(gpio_e_ext_padoe_o),	
                  .gpio_e_inta_o(),

                  .gpio_f_aux_i(gpio_f_aux_i),		
                  .gpio_f_ext_pad_i(gpio_f_ext_pad_i),	
                  .gpio_f_ext_pad_o(gpio_f_ext_pad_o),	
                  .gpio_f_ext_padoe_o(gpio_f_ext_padoe_o),	
                  .gpio_f_inta_o(),

                  .gpio_g_aux_i(gpio_g_aux_i),		
                  .gpio_g_ext_pad_i(gpio_g_ext_pad_i),	
                  .gpio_g_ext_pad_o(gpio_g_ext_pad_o),	
                  .gpio_g_ext_padoe_o(gpio_g_ext_padoe_o),	
                  .gpio_g_inta_o(),

                  .gpio_clk_i(clk_i),
                  .gpio_rst_i(rst_i)
                );
                                            
  //---------------------------------------------------
  // debug_0
`ifdef USE_DEBUG_0  
  assign debug_0 = {
                      iwb_clk_i,
                      iwb_rst_i,
                      iwb_ack_i,
                      iwb_err_i,
                      iwb_rty_i,
                      iwb_cyc_o,
                      iwb_stb_o,
                      iwb_we_o,
                      iwb_sel_o,
                      iwb_cab_o,
                      dwb_clk_i,
                      dwb_rst_i,
                      dwb_ack_i,
                      dwb_err_i,
                      dwb_rty_i,
                      dwb_cyc_o,
                      dwb_stb_o,
                      dwb_we_o,
                      dwb_sel_o,
                      dwb_cab_o,
                      iwb_adr_o,
                      iwb_dat_i,
                      iwb_dat_o,
                      dwb_adr_o,
                      dwb_dat_i,
                      dwb_dat_o
                    };
`endif

endmodule


