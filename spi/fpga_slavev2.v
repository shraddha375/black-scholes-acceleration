module spi_to_blackscholes (
    input  wire clk,
    input  wire rst,

    // SPI signals
    input  wire sck,
    input  wire mosi,
    input  wire cs,
    output wire miso,

    // From Black-Scholes
    input  wire [15:0] call_price,
    input  wire done,

    // To Black-Scholes
    output reg start,
    output reg [15:0] S,
    output reg [15:0] K,
    output reg [15:0] r,
    output reg [15:0] sigma,
    output reg [15:0] T
);

reg [15:0] shift_reg = 0;
reg [4:0] byte_cnt = 0;
reg miso_reg = 0;

assign miso = miso_reg;

// Shift data on rising edge
always @(posedge sck or posedge cs) begin
    if (cs) begin
        byte_cnt <= 0;
    end else begin
        shift_reg <= {shift_reg[14:0], mosi};
        byte_cnt  <= byte_cnt + 1;
    end
end

// Latch every 16-bit word
always @(negedge cs) begin
    if (byte_cnt == 16) begin
        case (0)
            0: S     <= shift_reg;
            1: K     <= shift_reg;
            2: r     <= shift_reg;
            3: sigma <= shift_reg;
            4: T     <= shift_reg;
        endcase
    end
end

// Count parameters and assert start when 5 received
reg [2:0] param_count = 0;

always @(negedge cs) begin
    if (byte_cnt == 16) begin
        param_count <= param_count + 1;
        if (param_count == 4) begin
            start <= 1;
            param_count <= 0;
        end
    end
end

always @(posedge clk) begin
    if (rst)
        start <= 0;
    else if (start && done)
        start <= 0;
end

// Output call_price on next SPI read
reg [15:0] out_shift;

always @(negedge cs) begin
    if (done)
        out_shift <= call_price;
end

always @(negedge sck) begin
    miso_reg <= out_shift[15];
    out_shift <= {out_shift[14:0], 1'b0};
end

endmodule
