`timescale 1ns / 1ps

/*
This module computes the normal cumulative distribution function (Φ(x)) using:

Q4.12 fixed-point format

ROM lookup table

Linear interpolation for accuracy
*/

module norm_cdf(
    // x_in — fixed-point Q4.12 input representing a value between roughly −8 to +7.999 
    // n_out — Φ(x), also Q4.12
    input logic signed [15:0] x_in,
    output logic signed [15:0] n_out
    );

    // The normal CDF saturates:
    // Φ(< −5) ≈ 0
    // Φ(> +5) ≈ 1
    // Outside this range, storing ROM values is wasteful.
    // Clamped input within [-5.0, 5.0] (Q4.12)
    logic signed [15:0] x_clamped;
    always_comb begin
        if (x_in < -16'sd20480)
            x_clamped = (-5 <<< 12);
        else if (x_in > (5 <<< 12))
            x_clamped = (5 <<< 12);
        else
            x_clamped = x_in;
    end
    
    // Offset to shift [-5.0, 5.0] → [0, 10.0]
    // This makes ROM addressing easy. 
    logic signed [16:0] x_offset;
    always_comb begin
        x_offset = x_clamped + (5 <<< 12); // 5.0 * 4096
    end
    
    // Imagine the range 0 to 10 is cut into small boxes, Each box is 0.02 wide.
    // In Q4.12 format, 0.02 ≈ 80 units. 
    // Compute ROM address and fractional offset
    logic [9:0] addr;
    logic [5:0] frac;
    always_comb begin
        // which 0.02-sized box x is inside
        addr = x_offset / 80;
        // how far is x from the start of that box
        frac = x_offset % 80;
    end
    
    // Interpolation needs:
    // val1 = CDF at the lower table point
    // val2 = CDF at the next table point
    // ROM output
    logic [15:0] val1, val2;
    norm_rom lut (
        .addr(addr),
        .val1(val1),
        .val2(val2)
    ); 
    
    // Linear interpolation: val1 + ((val2 - val1) * frac) >> 6
    logic signed [15:0] delta;
    logic signed [21:0] interp_mult;
    logic signed [15:0] interp;

    always_comb begin
        delta        = val2 - val1;
        interp_mult  = delta * frac;          // Q4.12 * Q0.6 = Q4.18
        interp       = interp_mult[17:6];     // Shift back to Q4.12
        n_out        = val1 + interp;         // Final interpolated output
    end

endmodule
