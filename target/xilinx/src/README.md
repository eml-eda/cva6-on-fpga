# Cheshire Top Xilinx

Certainly, let's provide a detailed line-by-line explanation of the code:

```systemverilog
// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
```

- These comments provide copyright information and specify the licensing terms for the code. It mentions the copyright holders and provides SPDX-License-Identifier information, indicating the specific version of the Solderpad Hardware License.

```systemverilog
`include "cheshire/typedef.svh"
```

- This line includes an external SystemVerilog package file named "cheshire/typedef.svh." This package is likely used to define various types, constants, or macros that are used throughout the code.

```systemverilog
module cheshire_top_xilinx
  import cheshire_pkg::*;
(
  input logic         sysclk_p,
  input logic         sysclk_n,
  input logic         cpu_resetn,
  input logic         test_mode_i,
  input logic [1:0]   boot_mode_i,
  output logic        uart_tx_o,
  input logic         uart_rx_i,
  input logic         jtag_tck_i,
  input logic         jtag_trst_ni,
  input logic         jtag_tms_i,
  input logic         jtag_tdi_i,
  output logic        jtag_tdo_o,
  inout wire          i2c_scl_io,
  inout wire          i2c_sda_io,
  input logic         sd_cd_i,
  output logic        sd_cmd_o,
  inout wire  [3:0]   sd_d_io,
  output logic        sd_reset_o,
  output logic        sd_sclk_o,
  input logic [3:0]   fan_sw,
  output logic        fan_pwm,
  // DDR3 DRAM interface
  output wire [14:0]  ddr3_addr,
  output wire [2:0]   ddr3_ba,
  output wire         ddr3_cas_n,
  output wire [0:0]   ddr3_ck_n,
  output wire [0:0]   ddr3_ck_p,
  output wire [0:0]   ddr3_cke,
  output wire [0:0]   ddr3_cs_n,
  output wire [3:0]   ddr3_dm,
  inout wire  [31:0]  ddr3_dq,
  inout wire  [3:0]   ddr3_dqs_n,
  inout wire  [3:0]   ddr3_dqs_p,
  output wire [0:0]   ddr3_odt,
  output wire         ddr3_ras_n,
  output wire         ddr3_reset_n,
  output wire         ddr3_we_n,
  // VGA Colour signals
  output logic [4:0]  vga_b,
  output logic [5:0]  vga_g,
  output logic [4:0]  vga_r,
  // VGA Sync signals
  output logic        vga_hs,
  output logic        vga_vs
);
```

- This section declares the SystemVerilog module `cheshire_top_xilinx`, which serves as the top-level module for the hardware design.
- It defines a list of input and output ports for the module, each with specific data types.
- Input ports include clock signals (`sysclk_p`, `sysclk_n`), reset signal (`cpu_resetn`), test mode input (`test_mode_i`), boot mode input (`boot_mode_i`), UART input (`uart_rx_i`), JTAG inputs (`jtag_tck_i`, `jtag_trst_ni`, `jtag_tms_i`, `jtag_tdi_i`), I2C lines (`i2c_scl_io` and `i2c_sda_io`), SD card presence input (`sd_cd_i`), fan switch inputs (`fan_sw`), and DDR3 memory interface signals (`ddr3_*`).
- Output ports include UART transmission (`uart_tx_o`), JTAG output (`jtag_tdo_o`), various SD card signals (`sd_cmd_o`, `sd_d_io`, `sd_reset_o`, `sd_sclk_o`), fan PWM output (`fan_pwm`), DDR3 memory interface outputs (`ddr3_*`), and VGA signals (`vga_*`).

```systemverilog
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
    DbgAmoPost

Cut     : 1
  };
```

- This section configures various parameters for the Cheshire FPGA design using a local parameter `FPGACfg`.
- The configuration parameters are provided in a structured format. Here are some of the key configurations:
  - CVA6 parameters: Defines parameters related to the CVA6 core, such as RAS depth, BTB (Branch Target Buffer) entries, BHT (Branch History Table) entries, and others.
  - Harts: Specifies the number of cores in the system, maximum transactions per core, and maximum transactions per ID.
  - Interrupts: Indicates the number of external interrupt synchronizers.
  - Interconnect: Defines parameters related to the interconnect, such as address width, data width, user width, and more.
  - RTC: Sets the RTC (Real-Time Clock) frequency.
  - Features: Enables or disables various system features like Bootrom, UART, I2C, SPI, GPIO, DMA, VGA, and more.
  - Debug: Configures parameters related to debugging, such as the maximum number of requests, read transactions, write transactions, and more.

```systemverilog
);
  localparam int CheshireIdCode = 32'h5a440000;
```

- These lines define another local parameter, `CheshireIdCode`, which is set to a specific hexadecimal value.

```systemverilog
  wire clk_i;
  wire rst_n;
  wire rst;
  wire [0:0] reset_done;
```

- Wires are declared for the internal clock (`clk_i`), a reset signal (`rst_n`), an inverted reset signal (`rst`), and a one-bit signal to indicate when reset is done (`reset_done`).

```systemverilog
  // clk_int_div
  clk_int_div
    #(
      .DIVIDER_FRACTIONAL(0),  // No fractional divider
      .ENABLE_SYNC_PHASE(0)    // Don't enable sync phase adjustment
    )
  clk_div_inst (
    .clk_int (sysclk_p),
    .clk_frac (sysclk_n),
    .clk_int_dcm (clk_i)
  );
```

- An instance of the `clk_int_div` module is instantiated. This module appears to be used for clock division.
- Various parameters are configured, such as `DIVIDER_FRACTIONAL` and `ENABLE_SYNC_PHASE`.
- The `clk_i` signal is generated as the divided clock.

```systemverilog
  // rstgen
  rstgen
    #(
      .CAPTURE_THRESHOLD(3),    // Capture must occur 4 cycles
      .CAPTURE_CLOCKS_BETWEEN(8)  // Capture must not occur twice within 9 cycles
    )
  rstgen_inst (
    .clk_i (clk_i),
    .rstgen_rst_n (rst_n),
    .rstgen_rst (rst)
  );
```

- An instance of the `rstgen` module is instantiated, likely for generating a reset signal.
- Parameters like `CAPTURE_THRESHOLD` and `CAPTURE_CLOCKS_BETWEEN` are set.
- The `clk_i` signal is used as the clock input, and the `rst_n` and `rst` signals are generated.

```systemverilog
  // axi_cdc
  axi_cdc
    #(
      .S_AXI_ASYNC_EN(0),
      .M_AXI_ASYNC_EN(0),
      .M_AXI_DATA_WIDTH(64)
    )
  axi_cdc_inst (
    .clk_i (clk_i),
    .rst_n (rst_n),
    .axi_aresetn_i (cpu_resetn),
    .axi_aclk_i (clk_i),
    .axi_aresetn_o (reset_done),
    .axi_aresetn_sync (0)
  );
```

- An instance of the `axi_cdc` module is created. This module likely handles clock domain crossing for AXI interfaces.
- Parameters, such as `S_AXI_ASYNC_EN`, `M_AXI_ASYNC_EN`, and `M_AXI_DATA_WIDTH`, are configured.
- Signals like `clk_i`, `rst_n`, and various AXI-related signals are connected.

```systemverilog
  // axi_cut
  axi_cut
    #(
      .CHECK_CDC(1)
    )
  axi_cut_inst (
    .clk_i (clk_i),
    .rst_n (rst_n),
    .m_axi_in_ready_sync (1),
    .m_axi_in_write (1),
    .m_axi_in_write_sync (1),
    .m_axi_in_rid_sync (1),
    .m_axi_in_rack_sync (1),
    .m_axi_in_bvalid_sync (1),
    .m_axi_in_bresp_sync (1),
    .m_axi_in_buser_sync (1),
    .m_axi_in_arid_sync (1),
    .m_axi_in_arlen_sync (1),
    .m_axi_in_arsize_sync (1),
    .m_axi_in_arburst_sync (1),
    .m_axi_in_arlock_sync (1),
    .m_axi_in_arcache_sync (1),
    .m_axi_in_arprot_sync (1),
    .m_axi_in_arqos_sync (1),
    .m_axi_in_arregion_sync (1),
    .m_axi_in_aruser_sync (1),
    .m_axi_in_araddr_sync (1),
    .m_axi_in_wid_sync (1),
    .m_axi_in_wlast_sync (1),
    .m_axi_in_wstrb_sync (1),
    .m_axi_in_wdata_sync (1),
    .m_axi_in_wuser_sync (1),
    .m_axi_in_rid_sync (1),
    .m_axi_in_rvalid_sync (1),
    .m_axi_in_rresp_sync (1),
    .m_axi_in_rlast_sync (1),
    .m_axi_in_rdata_sync (1),
    .m_axi_in_ruser_sync (1),
    .m_axi_out_ready_sync (1),
    .m_axi_out_rid_sync (1),
    .m_axi_out_rack_sync (1),
    .m_axi_out_rvalid_sync (1),
    .m_axi_out_rresp_sync (1),
    .m_axi_out_rlast_sync (1),
    .m_axi_out_rdata_sync (1),
    .m_axi_out_ruser_sync (1)
  );
```

- An instance of the `axi_cut` module is instantiated. This module might be involved in managing AXI interfaces and data transfer.
- It includes parameters like `CHECK_CDC`, which is set to 1, indicating that clock domain crossing checks are enabled.
- Various AXI signals are connected to this module.

```systemverilog
  // ddr3 memory controller
  xlnx_mig_7_ddr3
    ddr3_inst (
      .sys_clk_p (sysclk_p),
      .sys_clk_n (sysclk_n),
      .pll_ref_clk (sysclk_p),
      .device_temp_tdone (1'b0),
      .aresetn (rst

_n),
      .phy_resetn (1'b1),
      .ddr3_ui_clk (clk_i),
      .ddr3_dq (ddr3_dq),
      .ddr3_dm (ddr3_dm),
      .ddr3_dqs_n (ddr3_dqs_n),
      .ddr3_dqs_p (ddr3_dqs_p),
      .ddr3_dqs_b (1'b0),
      .ddr3_dqs_in (4'hf),
      .ddr3_addr (ddr3_addr),
      .ddr3_ba (ddr3_ba),
      .ddr3_ras_n (ddr3_ras_n),
      .ddr3_cas_n (ddr3_cas_n),
      .ddr3_cs_n (ddr3_cs_n),
      .ddr3_ck_n (ddr3_ck_n),
      .ddr3_ck_p (ddr3_ck_p),
      .ddr3_cke (ddr3_cke),
      .ddr3_odt (ddr3_odt),
      .ddr3_reset_n (ddr3_reset_n),
      .ddr3_we_n (ddr3_we_n)
    );
```

- An instance of the `xlnx_mig_7_ddr3` module is created, which appears to be a DDR3 memory controller for Xilinx devices.
- This module is connected to various clock, reset, and data signals related to DDR3 memory.

```systemverilog
  // I2C controller
  i2c_master
    #(
      .CAPTURED_CLOCKS(16),
      .GENERATE_STOP(1)
    )
  i2c_master_inst (
    .rst_n (rst_n),
    .scl_i (i2c_scl_io),
    .sda_i (i2c_sda_io),
    .sda_o (i2c_sda_io),
    .scl_o (i2c_scl_io)
  );
```

- An instance of the `i2c_master` module is instantiated, likely for controlling I2C communication.
- Parameters like `CAPTURED_CLOCKS` and `GENERATE_STOP` are configured.
- The module is connected to I2C clock and data signals.

```systemverilog
  // UART controller
  uart
    #(
      .DATA_BITS(8),
      .PARITY(0),
      .STOP_BITS(1)
    )
  uart_inst (
    .clk_i (clk_i),
    .rst_n (rst_n),
    .rx_i (uart_rx_i),
    .tx_o (uart_tx_o)
  );
```

- An instance of the `uart` module is created, presumably for UART communication.
- Parameters for data bits, parity, and stop bits are set.
- The module is connected to clock, reset, UART receive (`rx_i`), and UART transmit (`tx_o`) signals.

```systemverilog
  // ARIANE core
  ariane
    #(
      .ArianeCfg (FPGACfg),
      .IdCode (CheshireIdCode)
    )
  ariane_inst (
    .clk_i (clk_i),
    .rst_n (rst_n),
    .rst_n (cpu_resetn),
    .core_intr_0 (0),
    .core_intr_1 (0),
    .core_intr_2 (0),
    .core_intr_3 (0),
    .core_intr_4 (0),
    .core_intr_5 (0),
    .core_intr_6 (0),
    .core_intr_7 (0),
    .core_intr_8 (0),
    .core_intr_9 (0),
    .core_intr_10 (0),
    .core_intr_11 (0),
    .core_intr_12 (0),
    .core_intr_13 (0),
    .core_intr_14 (0),
    .core_intr_15 (0)
  );
```

- An instance of the `ariane` module is created, which appears to be the main core of the system.
- It is configured with parameters like `ArianeCfg` and `IdCode`.
- The module is connected to various clock, reset, and interrupt signals.

```systemverilog
  // CPU bus interface
  ariane_cpu_bus
    #(
      .ArianeCfg (FPGACfg),
      .CPU_IMPLEMENTATION ("RV64I"),
      .HAS_LSU (1),
      .HAS_EXT_DEBUG (1),
      .AS_MASTER (1),
      .ENABLE_ATOMIC_HANDLER (0),
      .ENABLE_AMO_HANDLER (0),
      .ENABLE_IRQMP (0),
      .ENABLE_DP (0),
      .ENABLE_PERF (0),
      .ENABLE_MMU (0),
      .ENABLE_PMP (0),
      .ENABLE_COUNTERS (0),
      .MAX_COUNTERS (0),
      .ENABLE_CYCLE_COUNTER (0),
      .ENABLE_TIME (0),
      .TIMER_INTERRUPT (0),
      .SYNTHESIS (0),
      .DATA_ADDR_BITS (3),
      .DATA_BEHAVIOR (1),
      .DATA_DO_UPDATE (0),
      .DATA_STALL_FPU_LOAD (1),
      .DATA_ENABLE_FPU_LOAD (0),
      .DATA_STALL_CSR_LOAD (1),
      .DATA_ENABLE_CSR_LOAD (0),
      .DATA_DISABLE_BHT (0),
      .DATA_L0_ICACHE_SIZE (16),
      .DATA_L1_ICACHE_SIZE (16),
      .DATA_L2_ICACHE_SIZE (128),
      .DATA_L0_DCACHE_SIZE (16),
      .DATA_L1_DCACHE_SIZE (16),
      .DATA_L2_DCACHE_SIZE (128),
      .DATA_L2_DCACHE_SIZE0 (128),
      .DATA_L2_DCACHE_SIZE1 (128),
      .DATA_L2_DCACHE_SIZE2 (128),
      .DATA_L2_DCACHE_SIZE3 (128),
      .DATA_L2_DCACHE_SIZE4 (128),
      .DATA_L2_DCACHE_SIZE5 (128),
      .DATA_L2_DCACHE_SIZE6 (128),
      .DATA_L2_DCACHE_SIZE7 (128),
      .DATA_L2_DCACHE_SIZE8 (128),
      .DATA_L2_DCACHE_SIZE9 (128),
      .DATA_L2_DCACHE_SIZE10 (128),
      .DATA_L2_DCACHE_SIZE11 (128),
      .DATA_L2_DCACHE_SIZE12 (128),
      .DATA_L2_DCACHE_SIZE13 (128),
      .DATA_L2_DCACHE_SIZE14 (128),
      .DATA_L2_DCACHE_SIZE15 (128),
      .DATA_L2_DCACHE_SIZE16 (128),
      .DATA_L2_DCACHE_SIZE17 (128),
      .DATA_L2_DCACHE_SIZE18 (128),
      .DATA_L2_DCACHE_SIZE19 (128),
      .DATA_L2_DCACHE_SIZE20 (128),
      .DATA_L2_DCACHE_SIZE21 (128),
      .DATA_L2_DCACHE_SIZE22 (128),
      .DATA_L2_DCACHE_SIZE23 (128),
      .DATA_L2_DCACHE_SIZE24 (128),
      .DATA_L2_DCACHE_SIZE25 (128),
      .DATA_L2_DCACHE

_SIZE26 (128),
      .DATA_L2_DCACHE_SIZE27 (128),
      .DATA_L2_DCACHE_SIZE28 (128),
      .DATA_L2_DCACHE_SIZE29 (128),
      .DATA_L2_DCACHE_SIZE30 (128),
      .DATA_L2_DCACHE_SIZE31 (128)
    )
  ariane_cpu_bus_inst (
    .clk_i (clk_i),
    .rst_n (rst_n),
    .core_i (ariane_inst),
    .instr_req_o (),
    .instr_gnt_i (),
    .data_req_o (),
    .data_gnt_i (),
    .data_rw_o (),
    .data_be_o (),
    .data_wstrb_o (),
    .data_addr_o (),
    .data_in_o (),
    .data_out_i (),
    .data_oe_o (),
    .data_cyc_o (),
    .data_stall_o (),
    .data_err_o (),
    .data_we_o (),
    .data_rsp_i ()
  );
```

- An instance of the `ariane_cpu_bus` module is created, which appears to be related to the CPU bus interface.
- Numerous parameters are configured to specify the CPU implementation, cache sizes, data behavior, and more.
- The module is connected to various signals related to the CPU and data bus.

```systemverilog
  // Bus masters and interconnect
  ariane_bus
    #(
      .ArianeCfg (FPGACfg),
      .CacheSizes (FPGACfg.CacheSizes)
    )
  ariane_bus_inst (
    .clk_i (clk_i),
    .rst_n (rst_n),
    .core_i (ariane_inst),
    .sys_reset_n (cpu_resetn),
    .axi_in_read_req_o (),
    .axi_in_read_gnt_i (),
    .axi_in_read_rsp_i (),
    .axi_in_read_data_o (),
    .axi_in_read_resp_o (),
    .axi_in_write_req_o (),
    .axi_in_write_gnt_i (),
    .axi_in_write_rsp_i (),
    .axi_in_write_data_o (),
    .axi_in_write_resp_o (),
    .axi_out_read_req_i (),
    .axi_out_read_gnt_o (),
    .axi_out_read_rsp_o (),
    .axi_out_read_data_i (),
    .axi_out_read_resp_i (),
    .axi_out_write_req_i (),
    .axi_out_write_gnt_o (),
    .axi_out_write_rsp_o (),
    .axi_out_write_data_i (),
    .axi_out_write_resp_i ()
  );
```

- An instance of the `ariane_bus` module is created, likely for managing bus masters and interconnect within the system.
- It is configured with parameters like `ArianeCfg` and `CacheSizes`.
- The module is connected to various AXI read and write request, grant, response, and data signals.

```systemverilog
  // Serial link
  cheshire_serial_link
    #(
      .IDCODE (CheshireIdCode),
      .NUM_RX_CHAN (0),
      .NUM_TX_CHAN (0),
      .HAS_IRQMP (0),
      .HAS_PMP (0),
      .HAS_MMU (0),
      .HAS_ICACHE (0),
      .HAS_DCACHE (0),
      .HAS_COUNTERS (0),
      .HAS_TIMESRV (0),
      .HAS_IPI (0),
      .HAS_ETH (0),
      .HAS_MTIME (0),
      .HAS_MCYCLE (0),
      .HAS_MINSTRET (0),
      .HAS_IRQ_CTRL (0),
      .HAS_SERIAL_LINK (0),
      .ENABLE_TIME (0),
      .MAX_AXI_TRANS (0),
      .NUM_EXT_INTR (0),
      .AXI_DATA_WIDTH (64),
      .MAX_COUNTERS (0)
    )
  cheshire_serial_link_inst (
    .clk_i (clk_i),
    .rst_n (rst_n),
    .rst (rst),
    .serial_tx_o (),
    .serial_rx_i (),
    .serial_irq_i ()
  );
```

- An instance of the `cheshire_serial_link` module is created, which seems to be related to serial communication.
- Numerous parameters are configured, including the number of RX and TX channels, presence of various components like MMU, I-cache, D-cache, and more.
- The module is connected to clock, reset, and serial communication signals.

```systemverilog
  // Fan control
  cheshire_fan
    #(
      .NUM_PWM_CHANNELS (1)
    )
  cheshire_fan_inst (
    .clk_i (clk_i),
    .rst_n (rst_n),
    .swi_i (fan_sw),
    .pwm_o (fan_pwm)
  );
```

- An instance of the `cheshire_fan` module is created, which appears to be related to fan control.
- The number of PWM channels is specified as 1.
- The module is connected to clock, reset, fan switch input, and PWM output signals.

```systemverilog
  // VGA controller
  vga
    #(
      .DATA_WIDTH (12),
      .H_SYNC_POLARITY (1'b0),
      .V_SYNC_POLARITY (1'b0)
    )
  vga_inst (
    .clk_i (clk_i),
    .rst_n (rst_n),
    .hs_o (vga_hs),
    .vs_o (vga_vs),
    .r_o (vga_r),
    .g_o (vga_g),
    .b_o (vga_b)
  );
```

- An instance of the `vga` module is created, which appears to be related to VGA signal generation.
- Parameters for data width and sync polarities are configured.
- The module is connected to clock, reset, and VGA color and sync signals.

```systemverilog
  // LEDs
  cheshire_led
    #(
      .HAS_GREEN_LED (1),
      .HAS_RED_LED (1)
    )
  cheshire_led_inst (
    .clk_i (clk_i),
    .rst_n (rst_n),
    .green_led_o (),
    .red_led_o ()
  );
```

- An instance of the `cheshire_led` module is created, which seems to be related to controlling LEDs.
- The presence of green and red LEDs is indicated through parameters.
- The module is connected to clock, reset, and LED control signals.

```systemverilog
  // Serial link debug
  serial_link_debug
    #(
      .IDCODE (CheshireIdCode),
      .NUM_RX_CHAN (0),
      .NUM_TX_CHAN (0),
      .HAS_IRQMP (0),
      .HAS_PMP (0),
      .HAS_MMU (0),
      .HAS_ICACHE (0),
      .HAS_DCACHE (0),
      .HAS_COUNTERS (0),
      .HAS_TIMESRV (0),
      .HAS_IPI (0),
      .HAS_ETH (0),
      .HAS_MTIME (0),
      .HAS_MCYCLE (0),
      .HAS_MINSTRET (0),
      .HAS_IRQ_CTRL (0),
      .HAS_SERIAL_LINK (0),
      .ENABLE_TIME (0),
      .MAX_AXI_TRANS (0),
     

 .NUM_EXT_INTR (0),
      .AXI_DATA_WIDTH (64),
      .MAX_COUNTERS (0)
    )
  serial_link_debug_inst (
    .clk_i (clk_i),
    .rst_n (rst_n),
    .rst (rst),
    .serial_tx_o (),
    .serial_rx_i (),
    .serial_irq_i (),
    .serial_link_debug_tx_o (),
    .serial_link_debug_rx_i (),
    .serial_link_debug_irq_i ()
  );
```

- An instance of the `serial_link_debug` module is created, which appears to be related to debugging over a serial link.
- Various parameters and signal connections are provided.

```systemverilog
  // Reset generation
  always_ff @(posedge clk_i or negedge rst_n) begin
    if (!rst_n) begin
      // Reset values here
      cpu_resetn <= 0;
    end else begin
      // Reset conditions here
      cpu_resetn <= reset_done;
    end
  end

  always_ff @(posedge clk_i or negedge rst_n) begin
    if (!rst_n) begin
      // Reset values here
      sd_reset_o <= 1;
    end else begin
      // Reset conditions here
      if (reset_done == 0) begin
        sd_reset_o <= 1;
      end else begin
        sd_reset_o <= 0;
      end
    end
  end
```

- These sections of code describe the generation of reset signals.
- They use the `always_ff` construct to describe synchronous logic based on the rising edge of the clock (`clk_i`) and the negation of the reset signal (`rst_n`).
- The first block sets the `cpu_resetn` signal to 0 when the reset is active (`rst_n` is low) and releases it when reset is done.
- The second block generates a reset signal `sd_reset_o`, which is initially high during reset and transitions to low when the reset is done.

```systemverilog
  always_ff @(posedge clk_i or negedge rst_n) begin
    if (!rst_n) begin
      // Reset values here
      uart_tx_o <= 0;
    end else begin
      // Reset conditions here
      uart_tx_o <= 1;
    end
  end

  always_ff @(posedge clk_i or negedge rst_n) begin
    if (!rst_n) begin
      // Reset values here
      jtag_tdo_o <= 0;
    end else begin
      // Reset conditions here
      jtag_tdo_o <= 1;
    end
  end
```

- These code blocks describe the behavior of the `uart_tx_o` and `jtag_tdo_o` output signals during reset and normal operation.
- Similar to the previous code, they use the `always_ff` construct to handle reset conditions.

```systemverilog
  always_ff @(posedge clk_i or negedge rst_n) begin
    if (!rst_n) begin
      // Reset values here
      i2c_scl_io <= 1;
      i2c_sda_io <= 1;
    end else begin
      // Reset conditions here
      i2c_scl_io <= 1;
      i2c_sda_io <= 1;
    end
  end
```

- This code block handles the behavior of the I2C signals `i2c_scl_io` and `i2c_sda_io` during reset and normal operation.
- It sets these signals to 1 when in reset state and maintains them at 1 when the reset is released.

```systemverilog
  always_ff @(posedge clk_i or negedge rst_n) begin
    if (!rst_n) begin
      // Reset values here
      sd_cmd_o <= 0;
      sd_d_io <= 4'b0;
      sd_sclk_o <= 0;
    end else begin
      // Reset conditions here
      sd_cmd_o <= 0;
      sd_d_io <= 4'b0;
      sd_sclk_o <= 0;
    end
  end
```

- This code block handles the behavior of the SD card-related signals (`sd_cmd_o`, `sd_d_io`, and `sd_sclk_o`) during reset and normal operation.
- These signals are set to their initial values during reset and remain unchanged when the reset is released.

The code you provided initializes various signals and modules within the `cheshire_top_xilinx` module. It configures clock domains, reset generation, and the behavior of various interfaces and peripherals such as UART, JTAG, I2C, SD card, fan control, VGA, LEDs, and more. The reset logic ensures that signals are appropriately initialized when the system is reset and transition to their operational states when the reset is released. The code appears to be part of a larger FPGA design targeting a Xilinx device and integrates the Ariane core as its central processing unit.


## Fan Controller

Alright! Let's break down the provided code line by line and explain its operation.

### Module Declaration

```verilog
module fan_ctrl (
    input  logic       clk_i,
    input  logic       rst_ni,
    input  logic [3:0] pwm_setting_i,
    output logic       fan_pwm_o
);
```

This portion of the code defines a module named `fan_ctrl` which has 4 ports:

1. `clk_i`: The input clock signal.
2. `rst_ni`: The negative (active-low) reset input signal.
3. `pwm_setting_i`: A 4-bit input representing the desired Pulse Width Modulation (PWM) setting.
4. `fan_pwm_o`: The output PWM signal for the fan.

### Internal Signals

```verilog
logic [3:0]  ms_clock_d, ms_clock_q;
logic [11:0] cycle_counter_d, cycle_counter_q;
```

1. `ms_clock_d` and `ms_clock_q`: These are 4-bit registers used to generate the PWM signal's base frequency.
2. `cycle_counter_d` and `cycle_counter_q`: These 12-bit registers are used for dividing the main clock frequency.

### Clock Divider

```verilog
// clock divider
always_comb begin
```

This block is a combinational circuit responsible for generating the PWM signal's frequency by dividing the main clock (`clk_i`).

```verilog
    cycle_counter_d = cycle_counter_q + 1;
    ms_clock_d = ms_clock_q;
```

Every clock cycle, the `cycle_counter_d` increments by 1 and the value of `ms_clock_d` is simply updated to the current value of `ms_clock_q`.

```verilog
    if (cycle_counter_q == 49) begin
        cycle_counter_d = 0;
        ms_clock_d = ms_clock_q + 1;
    end
```

When `cycle_counter_q` reaches 49 (i.e., after 50 clock cycles considering 0-based indexing), it resets `cycle_counter_d` to 0 and increments `ms_clock_d` by 1. This effectively divides the 50 MHz clock by 50 to get a 1 MHz signal.

```verilog
    if (ms_clock_q == 15) begin
        ms_clock_d = 0;
    end
```

This resets `ms_clock_d` when `ms_clock_q` reaches 15, effectively dividing the 1 MHz signal by 16 to get a 62.5 kHz PWM base frequency.

### Duty Cycle Calculation

```verilog
// duty cycle
always_comb begin
```

This block is responsible for generating the PWM output based on the input `pwm_setting_i`.

```verilog
    if (ms_clock_q < pwm_setting_i) begin
        fan_pwm_o = 1'b1;
    end else begin
        fan_pwm_o = 1'b0;
    end
```

The output `fan_pwm_o` will be high (`1'b1`) for a number of clock cycles determined by `pwm_setting_i` out of the 16 clock cycles (0-15) of `ms_clock_q`. This determines the duty cycle of the PWM. For example, if `pwm_setting_i` is `4`, the PWM signal will be high for 4 out of 16 cycles (25% duty cycle).

### Sequential Logic

```verilog
always_ff @(posedge clk_i or negedge rst_ni) begin
```

This block is triggered on the rising edge of the input clock `clk_i` or the falling edge (active-low) of the reset signal `rst_ni`.

```verilog
    if (~rst_ni) begin
        ms_clock_q      <= '0;
        cycle_counter_q <= '0;
    end else begin
        ms_clock_q      <= ms_clock_d;
        cycle_counter_q <= cycle_counter_d;
    end
endmodule
```

If the reset signal is active (low), the registers `ms_clock_q` and `cycle_counter_q` are reset to 0. Otherwise, they are updated with the values from their corresponding `_d` signals on each rising edge of the clock.

In summary, the code implements a PWM controller for a fan. The PWM frequency is generated by dividing the input clock, and its duty cycle is determined by the `pwm_setting_i` input. The resulting PWM signal can control the speed of a fan: the higher the duty cycle, the faster the fan will spin.