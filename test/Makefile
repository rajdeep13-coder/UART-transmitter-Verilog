# Makefile for Cocotb simulation

# Default simulator
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Source files
PWD=$(shell pwd)
VERILOG_SOURCES += $(PWD)/../src/uart_tx.v
VERILOG_SOURCES += $(PWD)/../src/uart_rx.v
VERILOG_SOURCES += $(PWD)/../src/uart_top.v

# Top-level module name
TOPLEVEL = uart_top

# Python test module name
MODULE = test_uart

# Include cocotb's make rules
include $(shell cocotb-config --makefiles)/Makefile.sim
