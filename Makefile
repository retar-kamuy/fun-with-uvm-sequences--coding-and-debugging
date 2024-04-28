###############################################################################
# User Settings
###############################################################################
SRCS	 = src/c_code_add.c

OBJS	 = $(addprefix xsim.dir/work/xsc/,$(notdir $(SRCS:.c=.lnx64.o)))

V_SRCS	 = ./verif/tb/top.sv

V_OBJS	 = $(addprefix xsim.dir/work/,$(notdir $(SRCS:.sv=.sdb)))

INCDIR	 = 

TOP		 = top

TARGET	 = xsim.dir/work.$(TOP)

COVDIR = xsim.covdb
REPORT_DIR = xsim.out


###############################################################################
# Vivado Simulator Settings
###############################################################################
XVLOG_FLAGS		 = -sv
XVLOG_FLAGS		+= -L uvm
# XVLOG_FLAGS	+= $(addprefix --include ,$(INCDIR))

XELAB_FLAGS		 = -L uvm
XELAB_FLAGS		+= -timescale 1ns/1ps
XELAB_FLAGS		+= -sv_lib dpi
XELAB_FLAGS		+= -cc_type sbct
XELAB_FLAGS		+= --debug all

# XSIM_FLAGS		 = --runall
XSIM_FLAGS		 = -testplusarg \"UVM_TESTNAME=test\"
XSIM_FLAGS		+= -testplusarg \"UVM_VERBOSITY=UVM_MEDIUM\"
XSIM_FLAGS		+= --tclbatch dump_all.tcl --wdb all.wdb

XCRG_FLAGS		 = -dir $(COVDIR)
XCRG_FLAGS		+= -report_dir $(REPORT_DIR)/xcrg_func_cov_report
XCRG_FLAGS		+= -cc_report $(REPORT_DIR)/xcrg_code_cov_report
XCRG_FLAGS		+= -report_format html

###############################################################################
# Rules
###############################################################################
all: clean test cover

build: xsim.dir/work.$(TOP)

$(OBJS): $(SRCS)
	xsc $^

$(V_OBJS): $(V_SRCS)
	xvlog $(XVLOG_FLAGS) $^

$(TARGET): $(OBJS) $(V_OBJS)
	xelab $(notdir $@) $(XELAB_FLAGS)

test: $(TARGET)
	xsim $(notdir $<) $(XSIM_FLAGS)

gui:
	xsim all.wdb --gui

cover: $(TARGET)
	rm -rf $(REPORT_DIR)
	mkdir -p $(REPORT_DIR)
	xcrg -cc_db $(notdir $<) $(XCRG_FLAGS)

clean:
	rm -rf xsim.dir
	rm -rf xsim.codeCov xsim.covdb xsim.dir xsim.out xvlog.pb xelab.pb
	rm -rf xsim_*.backup.* xsim.jou *.wdb
	rm -rf *.log *.vcd
