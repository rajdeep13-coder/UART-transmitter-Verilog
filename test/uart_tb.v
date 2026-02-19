`timescale 1ns/1ps

module uart_tb;

    localparam integer CLK_FREQ_HZ = 16000000;
    localparam integer BAUD_RATE   = 1000000;
    localparam integer OVERSAMPLE  = 16;

    reg clk;
    reg rst_n;
    reg tx_start;
    reg [7:0] tx_data;
    reg parity_en;
    reg parity_odd;

    wire tx_serial;
    wire tx_busy;
    wire tx_done;
    wire [7:0] rx_data;
    wire rx_valid;
    wire rx_busy;
    wire parity_error;
    wire framing_error;
    wire baud_tick_16x;

    wire loopback_line;
    assign loopback_line = tx_serial;

    uart_top #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLE(OVERSAMPLE)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .rx_serial(loopback_line),
        .tx_serial(tx_serial),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .parity_en(parity_en),
        .parity_odd(parity_odd),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_busy(rx_busy),
        .parity_error(parity_error),
        .framing_error(framing_error),
        .baud_tick_16x(baud_tick_16x)
    );

    always #5 clk = ~clk;

    task send_byte(input [7:0] data_in);
        begin
            @(posedge clk);
            while (tx_busy) @(posedge clk);
            tx_data  <= data_in;
            tx_start <= 1'b1;
            @(posedge clk);
            tx_start <= 1'b0;
        end
    endtask

    initial begin
        clk       = 1'b0;
        rst_n     = 1'b0;
        tx_start  = 1'b0;
        tx_data   = 8'h00;
        parity_en = 1'b1;
        parity_odd = 1'b0;

        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);

        repeat (5) @(posedge clk);
        rst_n = 1'b1;

        send_byte(8'h55);
        send_byte(8'hA3);
        send_byte(8'h0F);

        repeat (3000) @(posedge clk);
        $display("[TB] Completed loopback simulation.");
        $finish;
    end

    always @(posedge clk) begin
        if (rx_valid) begin
            $display("[TB] RX byte = 0x%02h | parity_error=%0d framing_error=%0d", rx_data, parity_error, framing_error);
        end
    end

endmodule
