# run.tcl

Certainly, let's go into more detail about the various sections and commands in the script:

1. **Conditional File Inclusion:**
   - The script begins with comments and license information.
   - It checks the value of the environment variable `$::env(BOARD)` to determine the target FPGA board. The supported boards are "genesys2," "kc705," and "vc707."
   - Depending on the selected board, it includes a specific Xilinx Constraints (XDC) file for that board. These files likely contain pin and timing constraints tailored to the chosen FPGA board.

2. **Reading IP:**
   - The `read_ip` command is used to read an Intellectual Property (IP) block from a specific Xilinx Memory Interface Generator (MIG) configuration file (`xlnx_mig_7_ddr3.xci`). This IP block is likely related to DDR3 memory interfacing, and it will be integrated into the FPGA design.

3. **Adding Sources:**
   - It sources an external TCL script named `add_sources.tcl`. This script is responsible for adding design sources to the project. The actual content of `add_sources.tcl` is not included in the snippet.

4. **Setting Properties:**
   - The script sets various properties using the `set_property` command:
     - It sets the top-level design entity name based on the project name.
     - It sets synthesis and implementation strategies:
       - `Flow_PerfOptimized_high` for synthesis.
       - `Performance_ExtraTimingOpt` for implementation.

5. **Synthesis:**
   - It initiates synthesis using the `synth_design` command with the `-rtl` and `-name rtl_1` options, indicating that this is a register-transfer level (RTL) synthesis. The result is stored in a stage called `rtl_1`.

6. **Retiming:**
   - The script enables retiming during synthesis using the `set_property` command.

7. **Launching and Waiting for Synthesis:**
   - It launches the synthesis process using the `launch_runs` command with the argument `synth_1`.
   - It waits for the synthesis run to complete using the `wait_on_run` command.
   - After completion, it opens the synthesis run using the `open_run` command.

8. **Timing Analysis and Reporting:**
   - The script creates a directory named `reports` if it doesn't exist and removes any existing content from it.
   - It checks timing constraints and generates various timing and utilization reports, CDC reports, and clock interaction reports using commands like `check_timing`, `report_timing`, `report_utilization`, `report_cdc`, and `report_clock_interaction`.

9. **Implementation:**
   - It launches the implementation process using the `launch_runs` command with the argument `impl_1`.
   - It waits for the implementation run to complete.
   - It launches the implementation run to the step of writing the bitstream using `launch_runs` and `wait_on_run`.

10. **Checking Timing Constraints (Optional):**
    - It checks if timing constraints are met based on the timing report. If constraints are not met, it generates an error message.

11. **Output Generation:**
    - The script generates Verilog netlist files and SDF (Standard Delay Format) files for timing simulation using the `write_verilog` and `write_sdf` commands.

12. **Final Reports:**
    - It generates various reports, including timing, utilization, and CDC reports, and places them in the `reports` directory.

Please note that this script is just a part of a larger FPGA development process. It configures the project, runs synthesis and implementation, checks for timing violations, and generates reports. The specifics of the FPGA design and the contents of the included scripts (e.g., `add_sources.tcl`) would determine the complete workflow and the behavior of this script within that context.

## Details

This script appears to be a Tcl script used for working with Xilinx Vivado, a tool for designing and implementing FPGA (Field-Programmable Gate Array) circuits. It is a high-level overview of the script's functionality and provides a brief explanation of each line:

```tcl
# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>
```

- These lines provide copyright information, licensing information, and authorship details for the script.

```tcl
# hard-coded to Genesys 2 for the moment
```

- This comment suggests that the script is currently hard-coded to work with the Genesys 2 FPGA board.

```tcl
if {$::env(BOARD) eq "genesys2"} {
    add_files -fileset constrs_1 -norecurse constraints/genesys2.xdc
} elseif {$::env(BOARD) eq "kc705"} {
    add_files -fileset constrs_1 -norecurse constraints/kc705.xdc
} elseif {$::env(BOARD) eq "vc707"} {
    add_files -fileset constrs_1 -norecurse constraints/vc707.xdc
}
```

- This block of code checks the value of the `BOARD` environment variable and adds constraint files based on the board specified. For example, if the board is "genesys2," it adds the constraint file "genesys2.xdc" to the "constrs_1" fileset.

```tcl
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
        set ips { "xilinx/xlnx_mig_ddr4/xlnx_mig_ddr4.srcs/sources_1/ip/xlnx_mig_ddr4/xlnx_mig_ddr4.xci" \
            "xilinx/xlnx_clk_wiz/xlnx_clk_wiz.srcs/sources_1/ip/xlnx_clk_wiz/xlnx_clk_wiz.xci" \
            "xilinx/xlnx_vio/xlnx_vio.srcs/sources_1/ip/xlnx_vio/xlnx_vio.xci" }
    }
    "zcu104" {
        set ips {
            "xilinx/xlnx_mig_ddr4/xlnx_mig_ddr4.srcs/sources_1/ip/xlnx_mig_ddr4/xlnx_mig_ddr4.xci"
        }
    }
    default {
        set ips {}
    }
}
```

- This code block sets the `ips` variable based on the value of the `BOARD` environment variable. It selects a list of IP (Intellectual Property) cores to be used in the design based on the specified board.

```tcl
read_ip $ips
```

- This line reads the IP cores specified in the `ips` variable into the Vivado project.

```tcl
source scripts/add_sources.tcl
```

- This line sources an external Tcl script named "add_sources.tcl."

```tcl
set_property top ${project}_top_xilinx [current_fileset]
```

- This sets the top module of the project to `${project}_top_xilinx` in the current fileset.

```tcl
update_compile_order -fileset sources_1
```

- This updates the compile order for the "sources_1" fileset.

```tcl
# add_files -fileset constrs_1 -norecurse constraints/$project.xdc
```

- This line appears to be commented out and may not be in use. It suggests adding constraint files based on a project, but it's currently disabled.

```tcl
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
```

- This sets the synthesis strategy to "Flow_PerfOptimized_high" for the "synth_1" run.

```tcl
set_property strategy Performance_ExtraTimingOpt [get_runs impl_1]
```

- This sets the implementation strategy to "Performance_ExtraTimingOpt" for the "impl_1" run.

```tcl
set_property XPM_LIBRARIES XPM_MEMORY [current_project]
```

- This sets properties related to Xilinx Platform Memory (XPM) libraries for the current project.

```tcl
synth_design -rtl -name rtl_1
```

- This command initiates the synthesis of the design with specific options.

```tcl
set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]
```

- This enables retiming during synthesis for the "synth_1" run.

```tcl
launch_runs synth_1
wait_on_run synth_1
open_run synth_1
```

- These lines launch, wait for, and open the synthesis run named "synth_1."

```tcl
exec mkdir -p reports/
exec rm -rf reports/*
```

- These lines create a directory for reports and remove any existing files in that directory.

```tcl
check_timing -verbose -file reports/$project.check_timing.rpt
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack -file reports/$project.timing_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group -file reports/$project.timing.rpt
report_utilization -hierarchical -file reports/$project.utilization.rpt
report_cdc -file reports/$project.cdc.rpt
report_clock_interaction -file reports/$project.clock_interaction.rpt
```

- These lines generate various reports related to timing, utilization, clock domain crossing (CDC), and clock interaction, and save them in the "reports" directory.

```tcl
launch_runs impl_1
wait_on_run impl_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
```

- These lines launch, wait for, and open the implementation

 run named "impl_1." The last two lines are related to generating a bitstream.

```tcl
#Check timing constraints
open_run impl_1
set timingrep [report_timing_summary -no_header -no_detailed_paths -return_string]
if {[info exists ::env(CHECK_TIMING)] && $::env(CHECK_TIMING)==1} {
  if {! [string match -nocase {*timing constraints are met*} $timingrep]} {
    send_msg_id {USER 1-1} ERROR {Timing constraints were not met.}
    return -code error
  }
}
```

- This code block checks whether timing constraints were met and provides an error message if they were not met.

```tcl
write_verilog -force -mode funcsim out/${project}_funcsim.v
write_verilog -force -mode timesim out/${project}_timesim.v
write_sdf -force out/${project}_timesim.sdf
```

- These lines generate Verilog netlist files and a Standard Delay Format (SDF) file for timing simulation.

```tcl
# reports
exec mkdir -p reports/
exec rm -rf reports/*
```

- These lines recreate the "reports" directory and remove any existing files.

```tcl
check_timing -file reports/${project}.check_timing.rpt
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack -file reports/${project}.timing_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group -file reports/${project}.timing.rpt
report_utilization -hierarchical -file reports/${project}.utilization.rpt
```

- These lines generate additional timing, utilization, and constraint-related reports in the "reports" directory.

# prologue.tcl

The code you provided appears to be a Tcl script written for Xilinx Vivado, a tool used for FPGA (Field-Programmable Gate Array) development. This script seems to configure various settings and parameters for a specific Vivado project. Here's a brief explanation of what the script does:

1. It specifies the copyright and licensing information for the script.

2. It defines the `$project` variable using the value from the environment variable `PROJECT`.

3. It creates a Vivado project with the name specified in the `$project` variable. The `-force` flag forces the creation of the project even if it already exists, and the `-part` flag sets the target Xilinx FPGA part using the value from the `XILINX_PART` environment variable.

4. It sets the property `board_part` for the current project using the value from the `XILINX_BOARD` environment variable.

5. It sets the maximum number of threads for the synthesis process to 8 using the `set_param` command.

6. There are two commented-out lines (lines starting with `#set_msg_config`) that appear to be related to message configuration, specifically regarding synthesis messages. These lines are currently disabled with `#` comments, but they might be used to modify message severity or limits for specific messages.

The script seems to be configuring a Vivado project for FPGA development, setting project-specific properties, and potentially adjusting message configurations for synthesis. If you have any specific questions or need further assistance with this script, please let me know.

# write_cfgmem.tcl

This is a Tcl (Tool Command Language) script that appears to be used for generating a memory configuration file from a bitstream file. It seems to be specifically tailored to FPGA development environments, as it mentions different FPGA boards like Genesys II, VC707, and KC705. Let me break down the script for you:

1. The script starts with some comments and licensing information.

2. It checks the number of command-line arguments passed to the script using `$argc`. If the number of arguments is less than 2 or more than 4, it displays an error message and usage instructions and then exits with an error code.

3. The `lassign` command is used to assign the command-line arguments to two variables: `mcsfile` and `bitfile`.

4. The script checks the value of the `BOARD` environment variable using `$::env(BOARD)` to determine which FPGA board is being used. Depending on the board, it calls the `write_cfgmem` command with specific parameters to generate the memory configuration file (`$mcsfile`) from the bitstream file (`$bitfile`).

   - If the board is "genesys2," it generates the memory configuration file with SPIx1 interface and a size of 256. The `write_cfgmem` command is used to specify the format as "mcs," load the bitstream file at address 0x0, and force the generation of the file.

   - If the board is "vc707," it generates the memory configuration file with the "bpix16" interface and a size of 128.

   - If the board is "kc705," it generates the memory configuration file with SPIx4 interface and a size of 128.

5. If none of the specified board conditions match, the script exits with an error code.

In summary, this script is used to automate the generation of memory configuration files for different FPGA boards based on the provided bitstream file and board type. It utilizes the `write_cfgmem` command, which is likely provided by the FPGA development environment, to perform this task. The script is specific to certain FPGA boards and their configurations.

## Details

This script appears to be a Tcl script designed to generate a memory configuration file from a bitstream file for specific FPGA boards (Genesys II, VC707, and KC705). Here's a line-by-line explanation:

```tcl
# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>
```

- These lines provide copyright information, licensing information, and authorship details for the script.

```tcl
# Description: Generate a memory configuration file from a bitstream (Genesys II only right now)
```

- This comment briefly describes the purpose of the script.

```tcl
if {$argc < 2 || $argc > 4} {
    puts $argc
    puts {Error: Invalid number of arguments}
    puts {Usage: write_cfgmem.tcl mcsfile bitfile [datafile]}
    exit 1
}
```

- This block checks the number of command-line arguments provided to the script (`$argc`). If the number of arguments is less than 2 or greater than 4, it displays an error message indicating the correct usage and exits the script with an error code.

```tcl
lassign $argv mcsfile bitfile
```

- This line assigns the first and second command-line arguments provided to the script (`$argv`) to the variables `mcsfile` and `bitfile`, respectively.

```tcl
if {$::env(BOARD) eq "genesys2"} {
    write_cfgmem -format mcs -interface SPIx1 -size 256  -loadbit "up 0x0 $bitfile" -file $mcsfile -force
} elseif {$::env(BOARD) eq "vc707"} {
    write_cfgmem -format mcs -interface bpix16 -size 128 -loadbit "up 0x0 $bitfile" -file $mcsfile -force
} elseif {$::env(BOARD) eq "kc705"} {
    write_cfgmem -format mcs -interface SPIx4 -size 128  -loadbit "up 0x0 $bitfile" -file $mcsfile -force
} else {
    exit 1
}
```

- This code block checks the value of the `BOARD` environment variable to determine which FPGA board is being used. Based on the board type, it calls the `write_cfgmem` command with appropriate parameters to generate a memory configuration file (MCS file) from the provided bitstream file (`$bitfile`). The options and interface types are set based on the board.

   - For "genesys2," it uses SPIx1 with a size of 256 and the `up 0x0` loadbit option.
   - For "vc707," it uses bpix16 with a size of 128 and the `up 0x0` loadbit option.
   - For "kc705," it uses SPIx4 with a size of 128 and the `up 0x0` loadbit option.

If the `BOARD` environment variable does not match any of the specified boards, the script exits with an error code.

This script essentially automates the process of generating memory configuration files for different FPGA boards based on the input bitstream and board type.

# program.tcl

This script appears to be a TCL script for programming FPGA devices using the Xilinx Vivado Design Suite. It looks like it's meant to be used to program different FPGA boards based on the value of the `BOARD` environment variable. Let me explain the script step by step:

1. It starts with some comments providing copyright information and licensing details.

2. It defines the author and a brief description of the script.

3. The script uses the `open_hw_manager` command to open the hardware manager, which is a part of the Vivado Design Suite used for FPGA development.

4. It connects to a hardware server using the `connect_hw_server` command, specifying the host and port based on the `HOST` and `PORT` environment variables.

5. Next, the script checks the value of the `BOARD` environment variable to determine which FPGA board is being used. It appears to support two boards: "genesys2" and "vc707."

6. If the `BOARD` is "genesys2," it opens the hardware target for the Genesys II board using `open_hw_target`, specifies the FPGA device as `xc7k325t_0`, sets the programming file using the `PROGRAM.FILE` property, and then programs the device using `program_hw_devices`.

7. If the `BOARD` is "vc707," it performs similar actions but for the VC707 board with the FPGA device `xc7vx485t_0`.

8. If the `BOARD` is neither "genesys2" nor "vc707," it exits the script with an error code.

Overall, this script is used to automate the process of programming FPGA devices on different boards based on the value of the `BOARD` environment variable, assuming that the necessary environment variables like `HOST`, `PORT`, and `BIT` have been set appropriately before running the script. It seems to be part of a larger FPGA development workflow using Xilinx Vivado.

## Details

This Tcl script is designed to program an FPGA board (Genesys II or VC707) using Xilinx Vivado's hardware manager. Below is a line-by-line explanation of the script:

```tcl
# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>
```

- These lines provide copyright information, licensing information, and authorship details for the script.

```tcl
# Description: Program Genesys II
```

- This comment briefly describes the purpose of the script, which is to program a Genesys II FPGA board.

```tcl
open_hw_manager
```

- This command opens the hardware manager in Xilinx Vivado.

```tcl
connect_hw_server -url $::env(HOST):$::env(PORT)
```

- This command connects to the hardware server using the URL and port specified in the `HOST` and `PORT` environment variables.

```tcl
if {$::env(BOARD) eq "genesys2"} {
  open_hw_target $::env(HOST):$::env(PORT)/$::env(FPGA_PATH)
```

- This conditional block checks if the `BOARD` environment variable is set to "genesys2." If true, it opens a hardware target based on the specified host, port, and FPGA path.

```tcl
  current_hw_device [get_hw_devices xc7k325t_0]
  set_property PROGRAM.FILE $::env(BIT) [get_hw_devices xc7k325t_0]
  program_hw_devices [get_hw_devices xc7k325t_0]
  refresh_hw_device [lindex [get_hw_devices xc7k325t_0] 0]
```

- Inside the "genesys2" block, it does the following:
   - Selects the current hardware device as "xc7k325t_0."
   - Sets the programming file (BIT file) to the path specified in the `BIT` environment variable.
   - Programs the hardware devices.
   - Refreshes the hardware device.

```tcl
} elseif {$::env(BOARD) eq "vc707"} {
  open_hw_target {$::env(HOST):$::env(PORT)/$::env(FPGA_PATH)}
```

- This conditional block checks if the `BOARD` environment variable is set to "vc707." If true, it opens a hardware target based on the specified host, port, and FPGA path.

```tcl
  current_hw_device [get_hw_devices xc7vx485t_0]
  set_property PROGRAM.FILE $::env(BIT) [get_hw_devices xc7vx485t_0]
  program_hw_devices [get_hw_devices xc7vx485t_0]
  refresh_hw_device [lindex [get_hw_devices xc7vx485t_0] 0]
```

- Inside the "vc707" block, it does the following:
   - Selects the current hardware device as "xc7vx485t_0."
   - Sets the programming file (BIT file) to the path specified in the `BIT` environment variable.
   - Programs the hardware devices.
   - Refreshes the hardware device.

```tcl
} else {
      exit 1
```

- If the `BOARD` environment variable does not match "genesys2" or "vc707," the script exits with an error code (1).

This script essentially opens the hardware manager, connects to the hardware server, selects the appropriate FPGA board based on the `BOARD` environment variable, and programs the FPGA with the specified bitstream file.