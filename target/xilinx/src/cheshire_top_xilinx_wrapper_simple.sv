module cheshire_top_xilinx_wrapper_simple
import cheshire_pkg::*;
  (
    input logic         sysclk_p,
    input logic         sysclk_n,
    input logic         cpu_reset,
    input logic [1:0]   boot_mode_i,
    input logic         test_mode_i,
    input logic         jtag_tck_i,
    input logic         jtag_tms_i,
    input logic         jtag_tdi_i,
    output logic        jtag_tdo_o,
    input logic         jtag_trst_i,
    output logic        uart_tx_o,
    input logic         uart_rx_i,
    inout wire          i2c_scl_io,
    inout wire          i2c_sda_io
    // input logic         sd_cd_i,
    // output logic        sd_cmd_o,
    // inout wire  [3:0]   sd_d_io,
    // output logic        sd_reset_o,
    // output logic        sd_sclk_o
  );


  // Configure cheshire for FPGA mapping
  localparam cheshire_cfg_t FPGACfg = '{
               // CVA6 parameters
               Cva6RASDepth      : ariane_pkg::ArianeDefaultConfig.RASDepth,
               Cva6BTBEntries    : ariane_pkg::ArianeDefaultConfig.BTBEntries,
               Cva6BHTEntries    : ariane_pkg::ArianeDefaultConfig.BHTEntries,
               Cva6NrPMPEntries  : 0,
               Cva6ExtCieLength  : 'h2000_0000,
               // Harts
               NumCores          : 1,
               CoreMaxTxns       : 8,
               CoreMaxTxnsPerId  : 4,
               // Interrupts
               NumExtIntrSyncs   : 2,
               // Interconnect
               AddrWidth         : 48,
               AxiDataWidth      : 64,
               AxiUserWidth      : 2,  // Convention: bit 0 for core(s), bit 1 for serial link
               AxiMstIdWidth     : 2,
               AxiMaxMstTrans    : 8,
               AxiMaxSlvTrans    : 8,
               AxiUserAmoMsb     : 1,
               AxiUserAmoLsb     : 0,
               RegMaxReadTxns    : 8,
               RegMaxWriteTxns   : 8,
               RegAmoNumCuts     : 1,
               RegAmoPostCut     : 1,
               // RTC
               RtcFreq           : 1000000,
               // Features
               Bootrom           : 1,
               Uart              : 1,
               I2c               : 1,
               SpiHost           : 1,
               Gpio              : 1,
               Dma               : 1,
               SerialLink        : 0,
               Vga               : 1,
               // Debug
               DbgIdCode         : CheshireIdCode,
               DbgMaxReqs        : 4,
               DbgMaxReadTxns    : 4,
               DbgMaxWriteTxns   : 4,
               DbgAmoNumCuts     : 1,
               DbgAmoPostCut     : 1,
               // LLC: 128 KiB, up to 2 GiB DRAM
               LlcNotBypass      : 1,
               LlcSetAssoc       : 8,
               LlcNumLines       : 256,
               LlcNumBlocks      : 8,
               LlcMaxReadTxns    : 8,
               LlcMaxWriteTxns   : 8,
               LlcAmoNumCuts     : 1,
               LlcAmoPostCut     : 1,
               LlcOutConnect     : 1,
               LlcOutRegionStart : 'h8000_0000,
               LlcOutRegionEnd   : 'h1_0000_0000,
               // VGA: RGB332
               VgaRedWidth       : 5,
               VgaGreenWidth     : 6,
               VgaBlueWidth      : 5,
               VgaHCountWidth    : 24, // TODO: Default is 32; is this needed?
               VgaVCountWidth    : 24, // TODO: See above
               // Serial Link: map other chip's lower 32bit to 'h1_000_0000
               SlinkMaxTxnsPerId : 4,
               SlinkMaxUniqIds   : 4,
               SlinkMaxClkDiv    : 1024,
               SlinkRegionStart  : 'h1_0000_0000,
               SlinkRegionEnd    : 'h2_0000_0000,
               SlinkTxAddrMask   : 'hFFFF_FFFF,
               SlinkTxAddrDomain : 'h0000_0000,
               SlinkUserAmoBit   : 1,  // Upper atomics bit for serial link
               // DMA config
               DmaConfMaxReadTxns  : 4,
               DmaConfMaxWriteTxns : 4,
               DmaConfAmoNumCuts   : 1,
               DmaConfAmoPostCut   : 1,
               DmaConfEnableTwoD   : 1,
               DmaNumAxInFlight    : 16,
               DmaMemSysDepth      : 8,
               DmaJobFifoDepth     : 2,
               DmaRAWCouplingAvail : 1,
               // GPIOs
               GpioInputSyncs    : 1,
               // All non-set values should be zero
               default: '0
             };

  localparam cheshire_cfg_t CheshireFPGACfg = FPGACfg;
  `CHESHIRE_TYPEDEF_ALL(, CheshireFPGACfg)

  axi_llc_req_t axi_llc_mst_req, dram_req, dram_req_cdc;
  axi_llc_rsp_t axi_llc_mst_rsp, dram_resp, dram_resp_cdc;

  // Declare the clock signal
  wire clk_soc;

  ///////////////////
  // Clock Generator //
  ///////////////////
  
  // Convert the clock from differential to single-ended
  IBUFGDS #(
            .IOSTANDARD  ("LVDS" ),
            .DIFF_TERM   ("FALSE"),
            .IBUF_LOW_PWR("FALSE")
          ) i_sysclk_iobuf (
            .I (sysclk_p),
            .IB(sysclk_n),
            .O (clk_soc  )
          );

  // Declare the reset signal
  wire rst_n;

  // Assign the value to the reset signal
  assign rst_n = ~cpu_reset & jtag_trst_i;

  ///////////////////
  // Clock Divider //
  ///////////////////

  // clk_int_div #(
  //   .DIV_VALUE_WIDTH          ( 4             ),
  //   .DEFAULT_DIV_VALUE        ( 4'h4          ),
  //   .ENABLE_CLOCK_IN_RESET    ( 1'b0          )
  // ) i_sys_clk_div (
  //   .clk_i                ( dram_clock_out    ),
  //   .rst_ni               ( ~dram_sync_reset  ),
  //   .en_i                 ( 1'b1              ),
  //   .test_mode_en_i       ( testmode_i        ),
  //   .div_i                ( 4'h4              ),
  //   .div_valid_i          ( 1'b0              ),
  //   .div_ready_o          (                   ),
  //   .clk_o                ( soc_clk           ),
  //   .cycl_count_o         (                   )
  // );

    /////////////////////
  // Reset Generator //
  /////////////////////

  // rstgen i_rstgen_main (
  //   .clk_i        ( soc_clk                  ),
  //   .rst_ni       ( ~dram_sync_reset         ),
  //   .test_mode_i  ( test_en                  ),
  //   .rst_no       ( rst_n                    ),
  //   .init_no      (                          ) // keep open
  // );



    //////////////////
  // SPI Adaption //
  //////////////////

  // logic spi_sck_soc;
  // logic [1:0] spi_cs_soc;
  // logic [3:0] spi_sd_soc_out;
  // logic [3:0] spi_sd_soc_in;

  // logic spi_sck_en;
  // logic [1:0] spi_cs_en;
  // logic [3:0] spi_sd_en;

  // // Assert reset low => Apply power to the SD Card
  // // assign sd_reset_o       = 1'b0;

  // // SCK  - SD CLK signal
  // assign sd_sclk_o        = spi_sck_en    ? spi_sck_soc       : 1'b1;

  // // CS   - SD DAT3 signal
  // assign sd_d_io[3]       = spi_cs_en[0]  ? spi_cs_soc[0]     : 1'b1;

  // // MOSI - SD CMD signal
  // assign sd_cmd_o         = spi_sd_en[0]  ? spi_sd_soc_out[0] : 1'b1;

  // // MISO - SD DAT0 signal
  // assign spi_sd_soc_in[1] = sd_d_io[0];

  // // SD DAT1 and DAT2 signal tie-off - Not used for SPI mode
  // assign sd_d_io[2:1]     = 2'b11;

  // // Bind input side of SoC low for output signals
  // assign spi_sd_soc_in[0] = 1'b0;
  // assign spi_sd_soc_in[2] = 1'b0;
  // assign spi_sd_soc_in[3] = 1'b0;


  //////////////////
  // Cheshire SoC //
  //////////////////

  cheshire_soc #(
                 .Cfg                ( FPGACfg ),
                 .ExtHartinfo        ( '0 ),
                 .axi_ext_llc_req_t  ( axi_llc_req_t ),
                 .axi_ext_llc_rsp_t  ( axi_llc_rsp_t ),
                 .axi_ext_mst_req_t  ( axi_mst_req_t ),
                 .axi_ext_mst_rsp_t  ( axi_mst_rsp_t ),
                 .axi_ext_slv_req_t  ( axi_slv_req_t ),
                 .axi_ext_slv_rsp_t  ( axi_slv_rsp_t ),
                 .reg_ext_req_t      ( reg_req_t ),
                 .reg_ext_rsp_t      ( reg_req_t )
               ) i_cheshire_soc (
                 .clk_i              ( clk_soc ),
                 .rst_ni             ( rst_n   ),
                 .test_mode_i        ( test_mode_i),
                 .boot_mode_i,
                 .rtc_i              ( rtc_clk_q             ),
                 .axi_llc_mst_req_o  ( axi_llc_mst_req ),
                 .axi_llc_mst_rsp_i  ( axi_llc_mst_rsp ),
                 .axi_ext_mst_req_i  ( '0 ),
                 .axi_ext_mst_rsp_o  ( ),
                 .axi_ext_slv_req_o  ( ),
                 .axi_ext_slv_rsp_i  ( '0 ),
                 .reg_ext_slv_req_o  ( ),
                 .reg_ext_slv_rsp_i  ( '0 ),
                 .intr_ext_i         ( '0 ),
                 .intr_ext_o         ( ),
                 .xeip_ext_o         ( ),
                 .mtip_ext_o         ( ),
                 .msip_ext_o         ( ),
                 .dbg_active_o       ( ),
                 .dbg_ext_req_o      ( ),
                 .dbg_ext_unavail_i  ( '0 ),
                 .jtag_tck_i,
                 .jtag_trst_ni       ('1),
                 .jtag_tms_i,
                 .jtag_tdi_i,
                 .jtag_tdo_o,
                 .jtag_tdo_oe_o      ( ),
                 .uart_tx_o          ( ),
                 .uart_rx_i          ( ),
                 .uart_rts_no        ( ),
                 .uart_dtr_no        ( ),
                 .uart_cts_ni        ( 1'b0 ),
                 .uart_dsr_ni        ( 1'b0 ),
                 .uart_dcd_ni        ( 1'b0 ),
                 .uart_rin_ni        ( 1'b0 ),
                 .i2c_sda_o          ( i2c_sda_soc_out ),
                 .i2c_sda_i          ( i2c_sda_soc_in  ),
                 .i2c_sda_en_o       ( i2c_sda_en      ),
                 .i2c_scl_o          ( i2c_scl_soc_out ),
                 .i2c_scl_i          ( i2c_scl_soc_in  ),
                 .i2c_scl_en_o       ( i2c_scl_en      ),
                 .spih_sck_o         ( spi_sck_soc     ),
                 .spih_sck_en_o      ( spi_sck_en      ),
                 .spih_csb_o         ( spi_cs_soc      ),
                 .spih_csb_en_o      ( spi_cs_en       ),
                 .spih_sd_o          ( spi_sd_soc_out  ),
                 .spih_sd_en_o       ( spi_sd_en       ),
                 .spih_sd_i          ( spi_sd_soc_in   ),
                 .gpio_i             ( '0 ),
                 .gpio_o             ( ),
                 .gpio_en_o          ( ),
                 .slink_rcv_clk_i    ( '1 ),
                 .slink_rcv_clk_o    ( ),
                 .slink_i            ( '0 ),
                 .slink_o            ( ),
                 .vga_hsync_o        ( vga_hs          ),
                 .vga_vsync_o        ( vga_vs          ),
                 .vga_red_o          ( vga_r           ),
                 .vga_green_o        ( vga_g           ),
                 .vga_blue_o         ( vga_b           )
               );

endmodule
