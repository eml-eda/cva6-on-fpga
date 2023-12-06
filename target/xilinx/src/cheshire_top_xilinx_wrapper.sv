module cheshire_top_xilinx_wrapper (
    input logic         sysclk_p,
    input logic         sysclk_n,
    input logic         cpu_reset,
    input logic [1:0]   boot_mode_i,
    input logic         jtag_tck_i,
    input logic         jtag_tms_i,
    input logic         jtag_tdi_i,
    output logic        jtag_tdo_o,
    inout wire          i2c_scl_io,
    inout wire          i2c_sda_io
  );
  
  cheshire_top_xilinx cheshire_top_xilinx_instance (
    .sysclk_p(sysclk_p),
    .sysclk_n(sysclk_n),
    .cpu_resetn(~cpu_reset),
    .test_mode_i(),
    .boot_mode_i(boot_mode_i),
    .uart_tx_o(),
    .uart_rx_i(),
    .jtag_tck_i(jtag_tck_i),
    .jtag_trst_ni(0'b1),
    .jtag_tms_i(jtag_tms_i),
    .jtag_tdi_i(jtag_tdi_i),
    .jtag_tdo_o(jtag_tdo_o),
    .i2c_scl_io(i2c_scl_io),
    .i2c_sda_io(i2c_sda_io),
    .sd_cd_i(),
    .sd_cmd_o(),
    .sd_d_io(),
    .sd_reset_o(),
    .sd_sclk_o(),
    .fan_sw(),
    .fan_pwm(),
    .vga_b(),
    .vga_g(),
    .vga_r(),
    .vga_hs(),
    .vga_vs()
);

endmodule
