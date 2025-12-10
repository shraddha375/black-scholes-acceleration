module top (
    input wire clk,
    input wire rst,

    input wire spi_sck,
    input wire spi_mosi,
    input wire spi_cs,
    output wire spi_miso
);

wire start, done;
wire [15:0] S, K, r, sigma, T;
wire [15:0] call_price;

black_scholes BS (
    .clk(clk),
    .rst(rst),
    .start(start),
    .S(S),
    .K(K),
    .r(r),
    .sigma(sigma),
    .T(T),
    .done(done),
    .call_price(call_price)
);

spi_to_blackscholes SPI (
    .clk(clk),
    .rst(rst),
    .sck(spi_sck),
    .mosi(spi_mosi),
    .cs(spi_cs),
    .miso(spi_miso),

    .start(start),
    .S(S),
    .K(K),
    .r(r),
    .sigma(sigma),
    .T(T),

    .call_price(call_price),
    .done(done)
);

endmodule
