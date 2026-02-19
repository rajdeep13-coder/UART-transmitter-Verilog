SIM=uart_tb
IVERILOG=iverilog
VVP=vvp

SRC=../src/uart_tx.v ../src/uart_rx.v ../src/uart_top.v
TB_MAIN=../test/uart_tb.v
TB_RX=../test/uart_rx_only_tb.v

all: run

help:
	@echo "Targets:"
	@echo "  run      - compile and run loopback testbench"
	@echo "  run-rx   - compile and run RX-only testbench"
	@echo "  wave     - run loopback testbench and open GTKWave"
	@echo "  clean    - remove generated simulation artifacts"

compile-main:
	$(IVERILOG) -g2012 -o $(SIM).vvp $(SRC) $(TB_MAIN)

compile-rx:
	$(IVERILOG) -g2012 -o uart_rx_only_tb.vvp ../src/uart_rx.v $(TB_RX)

run: compile-main
	$(VVP) $(SIM).vvp

run-rx: compile-rx
	$(VVP) uart_rx_only_tb.vvp

wave: run
	gtkwave uart_tb.vcd -S gtkwave.tcl

clean:
	$(RM) *.vvp *.vcd

.PHONY: all help compile-main compile-rx run run-rx wave clean
