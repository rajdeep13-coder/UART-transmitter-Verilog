# GTKWave setup script
# Load common UART signals for uart_tb

gtkwave::addSignalsFromList {
    uart_tb.clk
    uart_tb.rst_n
    uart_tb.tx_start
    uart_tb.tx_data[7:0]
    uart_tb.tx_serial
    uart_tb.rx_data[7:0]
    uart_tb.rx_valid
    uart_tb.parity_error
    uart_tb.framing_error
}
