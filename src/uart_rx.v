module uart_rx #(
    parameter integer OVERSAMPLE = 16
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tick_16x,
    input  wire       rx_serial,
    input  wire       parity_en,
    input  wire       parity_odd,
    output reg  [7:0] rx_data,
    output reg        rx_valid,
    output reg        rx_busy,
    output reg        parity_error,
    output reg        framing_error
);

    localparam [2:0] ST_IDLE   = 3'd0;
    localparam [2:0] ST_START  = 3'd1;
    localparam [2:0] ST_DATA   = 3'd2;
    localparam [2:0] ST_PARITY = 3'd3;
    localparam [2:0] ST_STOP   = 3'd4;

    reg [2:0] state;
    reg [3:0] bit_index;
    reg [4:0] sample_count;
    reg [7:0] rx_shift;
    reg       parity_sample;

    reg rx_meta;
    reg rx_sync;

    wire parity_expected;
    assign parity_expected = parity_odd ? ~(^rx_shift) : (^rx_shift);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end else begin
            rx_meta <= rx_serial;
            rx_sync <= rx_meta;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= ST_IDLE;
            bit_index     <= 4'd0;
            sample_count  <= 5'd0;
            rx_shift      <= 8'h00;
            parity_sample <= 1'b0;
            rx_data       <= 8'h00;
            rx_valid      <= 1'b0;
            rx_busy       <= 1'b0;
            parity_error  <= 1'b0;
            framing_error <= 1'b0;
        end else begin
            rx_valid <= 1'b0;

            case (state)
                ST_IDLE: begin
                    rx_busy       <= 1'b0;
                    bit_index     <= 4'd0;
                    sample_count  <= 5'd0;
                    parity_error  <= 1'b0;
                    framing_error <= 1'b0;

                    if (!rx_sync) begin
                        rx_busy <= 1'b1;
                        state   <= ST_START;
                    end
                end

                ST_START: begin
                    if (tick_16x) begin
                        if (sample_count == ((OVERSAMPLE / 2) - 1)) begin
                            if (!rx_sync) begin
                                sample_count <= 5'd0;
                                state        <= ST_DATA;
                            end else begin
                                state <= ST_IDLE;
                            end
                        end else begin
                            sample_count <= sample_count + 5'd1;
                        end
                    end
                end

                ST_DATA: begin
                    if (tick_16x) begin
                        if (sample_count == (OVERSAMPLE - 1)) begin
                            sample_count         <= 5'd0;
                            rx_shift[bit_index]  <= rx_sync;

                            if (bit_index == 4'd7) begin
                                bit_index <= 4'd0;
                                state     <= parity_en ? ST_PARITY : ST_STOP;
                            end else begin
                                bit_index <= bit_index + 4'd1;
                            end
                        end else begin
                            sample_count <= sample_count + 5'd1;
                        end
                    end
                end

                ST_PARITY: begin
                    if (tick_16x) begin
                        if (sample_count == (OVERSAMPLE - 1)) begin
                            sample_count  <= 5'd0;
                            parity_sample <= rx_sync;
                            parity_error  <= (rx_sync != parity_expected);
                            state         <= ST_STOP;
                        end else begin
                            sample_count <= sample_count + 5'd1;
                        end
                    end
                end

                ST_STOP: begin
                    if (tick_16x) begin
                        if (sample_count == (OVERSAMPLE - 1)) begin
                            sample_count  <= 5'd0;
                            rx_data       <= rx_shift;
                            rx_valid      <= 1'b1;
                            framing_error <= !rx_sync;
                            rx_busy       <= 1'b0;
                            state         <= ST_IDLE;
                        end else begin
                            sample_count <= sample_count + 5'd1;
                        end
                    end
                end

                default: begin
                    state <= ST_IDLE;
                end
            endcase
        end
    end

endmodule
