`timescale 1ns / 1ps

/*
This module computes a square root using a lookup table (ROM) instead of doing expensive arithmetic.
Because doing an actual sqrt in hardware is costly, sqrt values are precomputed and stored them in a ROM.

The input/output use Q6.10 fixed-point format, meaning:

6 integer bits

10 fractional bits

Value = integer_representation / 1024

Example:

1.0 → 1024

16.0 → 16384
*/

module sqrt(
    // x_in — 16-bit signed input in Q6.10 format
    // sqrt_out — sqrt(x_in), also in Q6.10 format
    input logic signed [15:0] x_in,
    output logic signed [15:0] sqrt_out
    );
    
    // Clamp input to [0.0, 16.0] → [0, 16384] in Q6.10
    logic signed [15:0] x_clamped;
    always_comb begin
        if (x_in < 16'sd0)
            x_clamped = 16'sd0;
        else if (x_in > 16'sd16384)
            x_clamped = 16'sd16384;
        else
            x_clamped = x_in;
    end
    
    // Every sqrt value for every possible Q6.10 value (0–16384) 
    // That would require 16,385 entries in the ROM — too big
    // Compute ROM address: 0.03125 step size = 32 units in Q6.10
    logic [15:0] index;
    logic [9:0] addr;

    always_comb begin
        index = x_clamped;
        addr  = index / 32;
    end

    // ROM lookup
    sqrt_rom rom_inst (
        .addr(addr),
        .out(sqrt_out)
    );
    
endmodule
