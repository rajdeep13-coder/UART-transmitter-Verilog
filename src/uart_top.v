module uart_top #(
    parameter integer CLK_FREQ_HZ = 50000000,
    parameter integer BAUD_RATE   = 115200,
    parameter integer OVERSAMPLE  = 16
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx_serial,
    output wire       tx_serial,

    input  wire       tx_start,
    input  wire [7:0] tx_data,
    input  wire       parity_en,
    input  wire       parity_odd,

    output wire       tx_busy,
    output wire       tx_done,

    output wire [7:0] rx_data,
    output wire       rx_valid,
    output wire       rx_busy,
    output wire       parity_error,
    output wire       framing_error,

    output wire       baud_tick_16x
);

    localparam integer DIVISOR = CLK_FREQ_HZ / (BAUD_RATE * OVERSAMPLE);

    reg [31:0] div_count;
    reg        tick_16x;

    assign baud_tick_16x = tick_16x;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div_count <= 32'd0;
            tick_16x  <= 1'b0;
        end else begin
            if (div_count == (DIVISOR - 1)) begin
                div_count <= 32'd0;
                tick_16x  <= 1'b1;
            end else begin
                div_count <= div_count + 32'd1;
                tick_16x  <= 1'b0;
            end
        end
    end

    uart_tx #(
        .OVERSAMPLE(OVERSAMPLE)
    ) u_tx (
        .clk(clk),
        .rst_n(rst_n),
        .tick_16x(tick_16x),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .parity_en(parity_en),
        .parity_odd(parity_odd),
        .tx_serial(tx_serial),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );

    uart_rx #(
        .OVERSAMPLE(OVERSAMPLE)
    ) u_rx (
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

endmodule
