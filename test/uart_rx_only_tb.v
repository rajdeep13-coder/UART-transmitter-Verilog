`timescale 1ns/1ps

module uart_rx_only_tb;

    localparam integer OVERSAMPLE = 16;

    reg clk;
    reg rst_n;
    reg tick_16x;
    reg rx_serial;
    reg parity_en;
    reg parity_odd;

    wire [7:0] rx_data;
    wire rx_valid;
    wire rx_busy;
    wire parity_error;
    wire framing_error;

    uart_rx #(
        .OVERSAMPLE(OVERSAMPLE)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .tick_16x(tick_16x),
        .rx_serial(rx_serial),
        .parity_en(parity_en),
        .parity_odd(parity_odd),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_busy(rx_busy),
        .parity_error(parity_error),
        .framing_error(framing_error)
    );

    always #5 clk = ~clk;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tick_16x <= 1'b0;
        end else begin
            tick_16x <= ~tick_16x;
        end
    end

    task send_frame(
        input [7:0] data,
        input parity_bit,
        input stop_bit
    );
        integer i;
        begin
            rx_serial <= 1'b0;
            repeat (OVERSAMPLE) @(posedge tick_16x);

            for (i = 0; i < 8; i = i + 1) begin
                rx_serial <= data[i];
                repeat (OVERSAMPLE) @(posedge tick_16x);
            end

            rx_serial <= parity_bit;
            repeat (OVERSAMPLE) @(posedge tick_16x);

            rx_serial <= stop_bit;
            repeat (OVERSAMPLE) @(posedge tick_16x);

            rx_serial <= 1'b1;
            repeat (OVERSAMPLE) @(posedge tick_16x);
        end
    endtask

    initial begin
        clk        = 1'b0;
        rst_n      = 1'b0;
        tick_16x   = 1'b0;
        rx_serial  = 1'b1;
        parity_en  = 1'b1;
        parity_odd = 1'b0;

        $dumpfile("uart_rx_only_tb.vcd");
        $dumpvars(0, uart_rx_only_tb);

        repeat (4) @(posedge clk);
        rst_n = 1'b1;

        send_frame(8'h3C, ^8'h3C, 1'b1);
        send_frame(8'hA5, ~(^8'hA5), 1'b1);
        send_frame(8'hF0, ^8'hF0, 1'b0);

        repeat (200) @(posedge clk);
        $finish;
    end

    always @(posedge clk) begin
        if (rx_valid) begin
            $display("[RX_ONLY_TB] RX=0x%02h parity_error=%0d framing_error=%0d", rx_data, parity_error, framing_error);
        end
    end

endmodule
