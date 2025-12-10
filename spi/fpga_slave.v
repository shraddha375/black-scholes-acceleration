module spi_slave (
    input wire sck,        // SPI clock
    input wire mosi,       // ESP32 -> FPGA
    input wire cs,         // Chip select (active low)
    output reg miso,       // FPGA -> ESP32 (not used now)
    output reg [7:0] data, // Latched data
    output reg data_ready
);

reg [7:0] shift_reg = 0;
reg [2:0] bit_cnt = 0;

always @(posedge sck) begin
    if (!cs) begin
        shift_reg <= {shift_reg[6:0], mosi};
        bit_cnt <= bit_cnt + 1;

        if (bit_cnt == 7) begin
            data <= {shift_reg[6:0], mosi};
            data_ready <= 1'b1;
        end else begin
            data_ready <= 1'b0;
        end
    end
end

always @(negedge cs) begin
    bit_cnt <= 0;
end

endmodule
