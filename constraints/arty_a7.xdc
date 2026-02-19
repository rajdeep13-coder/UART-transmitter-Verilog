## Arty A7 UART pin constraints template
## Update PACKAGE_PIN and IOSTANDARD as required for your board setup.

## set_property PACKAGE_PIN <PIN_RX> [get_ports rx_serial]
## set_property IOSTANDARD LVCMOS33 [get_ports rx_serial]

## set_property PACKAGE_PIN <PIN_TX> [get_ports tx_serial]
## set_property IOSTANDARD LVCMOS33 [get_ports tx_serial]

## set_property PACKAGE_PIN <PIN_CLK> [get_ports clk]
## create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
