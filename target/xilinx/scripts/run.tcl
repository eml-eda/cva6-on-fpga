# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>

# hard-coded to Genesys 2 for the moment

if {$::env(BOARD) eq "genesys2"} {
      add_files -fileset constrs_1 -norecurse constraints/genesys2.xdc
} elseif {$::env(BOARD) eq "kc705"} {
      add_files -fileset constrs_1 -norecurse constraints/kc705.xdc
} elseif {$::env(BOARD) eq "vc707"} {
      add_files -fileset constrs_1 -norecurse constraints/vc707.xdc
} elseif {$::env(BOARD) eq "zcu104"} {
      add_files -fileset constrs_1 -norecurse constraints/zcu104.xdc
} elseif {$::env(BOARD) eq "zcu102"} {
      add_files -fileset constrs_1 -norecurse constraints/zcu102.xdc
} elseif {$::env(BOARD) eq "pynq-z1"} {
      add_files -fileset constrs_1 -norecurse constraints/pynq-z1.xdc
}

# Ips selection
switch $::env(BOARD) {
      "genesys2" - "kc705" - "vc707" {
            set ips { "xilinx/xlnx_mig_7_ddr3/xlnx_mig_7_ddr3.srcs/sources_1/ip/xlnx_mig_7_ddr3/xlnx_mig_7_ddr3.xci" \
                  "xilinx/xlnx_clk_wiz/xlnx_clk_wiz.srcs/sources_1/ip/xlnx_clk_wiz/xlnx_clk_wiz.xci" \
                        "xilinx/xlnx_vio/xlnx_vio.srcs/sources_1/ip/xlnx_vio/xlnx_vio.xci" }
            }
      "vcu128" {
            set ips { "xilinx/xlnx_clk_wiz/xlnx_clk_wiz.srcs/sources_1/ip/xlnx_clk_wiz/xlnx_clk_wiz.xci" \
                  "xilinx/xlnx_vio/xlnx_vio.srcs/sources_1/ip/xlnx_vio/xlnx_vio.xci" }
            }
      "zcu102" {
            set ips { "xilinx/xlnx_mig_ddr4/xlnx_mig_ddr4.srcs/sources_1/ip/xlnx_mig_ddr4/xlnx_mig_ddr4.xci"
            }
      }
      "zcu104" - "pynq-z1" {
            set ips {
                  "xilinx/xlnx_mig_ddr4/xlnx_mig_ddr4.srcs/sources_1/ip/xlnx_mig_ddr4/xlnx_mig_ddr4.xci"
            }
      }
      default {
            set ips {}
      }
}

read_ip $ips

source scripts/add_sources.tcl

set_property top cheshire_top_xilinx_wrapper [current_fileset]

update_compile_order -fileset sources_1

add_files -fileset constrs_1 -norecurse constraints/$project.xdc

set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property strategy Performance_ExtraTimingOpt [get_runs impl_1]

set_property XPM_LIBRARIES XPM_MEMORY [current_project]

synth_design -rtl -name rtl_1

set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]

launch_runs synth_1
wait_on_run synth_1
open_run synth_1

exec mkdir -p reports/
exec rm -rf reports/*

check_timing -verbose                                                   -file reports/$project.check_timing.rpt
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack -file reports/$project.timing_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group                  -file reports/$project.timing.rpt
report_utilization -hierarchical                                        -file reports/$project.utilization.rpt
report_cdc                                                              -file reports/$project.cdc.rpt
report_clock_interaction                                                -file reports/$project.clock_interaction.rpt

launch_runs impl_1
wait_on_run impl_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

#Check timing constraints
open_run impl_1
set timingrep [report_timing_summary -no_header -no_detailed_paths -return_string]
if {[info exists ::env(CHECK_TIMING)] && $::env(CHECK_TIMING)==1} {
      if {! [string match -nocase {*timing constraints are met*} $timingrep]} {
            send_msg_id {USER 1-1} ERROR {Timing constraints were not met.}
            return -code error
      }
}

# output Verilog netlist + SDC for timing simulation
write_verilog -force -mode funcsim out/${project}_funcsim.v
write_verilog -force -mode timesim out/${project}_timesim.v
write_sdf     -force out/${project}_timesim.sdf

# reports
exec mkdir -p reports/
exec rm -rf reports/*
check_timing                                                              -file reports/${project}.check_timing.rpt
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack   -file reports/${project}.timing_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group                    -file reports/${project}.timing.rpt
report_utilization -hierarchical                                          -file reports/${project}.utilization.rpt
