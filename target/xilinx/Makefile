# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>

PROJECT      ?= cheshire
# Board in {genesys2, zcu104}
BOARD          = zcu104
XILINX_PORT  ?= 3332
XILINX_HOST  ?= bordcomputer

# # ZCU102
# BOARD          = zcu102
# XILINX_PART    = xczu9eg-ffvb1156-2-e
# XILINX_BOARD   = xilinx.com:zcu102:part0:3.4
# ips-names      := xlnx_mig_ddr4 xlnx_clk_wiz xlnx_vio

ifeq ($(BOARD),genesys2)
	XILINX_PART  ?= xc7k325tffg900-2
	XILINX_BOARD ?= digilentinc.com:genesys2:part0:1.1
	ips-names    := xlnx_mig_7_ddr3 xlnx_clk_wiz xlnx_vio
	FPGA_PATH    ?= xilinx_tcf/Digilent/200300A8C60DB
endif
ifeq ($(BOARD),zcu104)
	XILINX_PART  = xczu7ev-ffvc1156-2-e
	XILINX_BOARD = xilinx.com:zcu104:part0:1.1
	# ips-names      := xlnx_mig_ddr4 xlnx_clk_wiz xlnx_vio
	ips := xlnx_mig_ddr4.xci
endif

# Location of ip outputs
# ips := $(addprefix $(CAR_XIL_DIR)/,$(addsuffix .xci ,$(basename $(ips-names))))

out := out
bit := $(out)/$(PROJECT)_top_xilinx.bit
mcs := $(out)/$(PROJECT)_top_xilinx.mcs
BIT ?= $(bit)

VIVADOENV ?=  PROJECT=$(PROJECT)            \
              BOARD=$(BOARD)                \
              XILINX_PART=$(XILINX_PART)    \
              XILINX_BOARD=$(XILINX_BOARD)  \
              PORT=$(XILINX_PORT)           \
              HOST=$(XILINX_HOST)           \
              FPGA_PATH=$(FPGA_PATH)        \
              BIT=$(BIT)

# select IIS-internal tool commands if we run on IIS machines
ifneq (,$(wildcard /etc/iis.version))
	VIVADO ?= vitis-2022.1 vivado
else
	VIVADO ?= vivado
endif

VIVADOFLAGS ?= -nojournal -mode batch

ip-dir  := xilinx

all: $(mcs)

# Generate mcs from bitstream
$(mcs): $(bit)
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/write_cfgmem.tcl -tclargs $@ $^

$(bit): $(ips)
	@mkdir -p $(out)
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/prologue.tcl -source scripts/run.tcl
	cp $(PROJECT).runs/impl_1/$(PROJECT)* ./$(out)

$(ips):
	@echo "Generating IP $(basename $@)"
	# cd $(ip-dir)/$(basename $@) && $(MAKE) clean && $(VIVADOENV) VIVADO="$(VIVADO)" $(MAKE)
	cp $(ip-dir)/$(basename $@)/$(basename $@).srcs/sources_1/ip/$(basename $@)/$@ $@


gui:
	@echo "Starting $(VIVADO) GUI"
	@$(VIVADOENV) $(VIVADO) -nojournal -mode gui $(PROJECT).xpr &

program:
	@echo "Programming board $(BOARD) ($(XILINX_PART))"
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/program.tcl

clean:
	rm -rf *.log *.jou *.str *.mif *.xci *.xpr .Xil/ $(out) $(PROJECT).cache $(PROJECT).hw $(PROJECT).ioplanning $(PROJECT).ip_user_files $(PROJECT).runs $(PROJECT).sim

.PHONY: clean
