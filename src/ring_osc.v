/*
 * Copyright (c) 2025 Remington Holder, Sherry Yu, Rohin Kumar, Julia Ke, Jeda Williams, Crystal Jiang
   Build upon Oscillator work by Anton Maurovic
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none (* keep_hierarchy *)

module amm_inverter (
    input   wire a,
    output  wire y
);

    assign #1 y = ~a;

endmodule

// A chain of inverters.
module inv_chain #(
    parameter N = 10 // SHOULD BE EVEN.
) (
    input a,
    output y
);

    wire [N-1:0] ins;
    wire [N-1:0] outs;
    assign ins[0] = a;
    assign ins[N-1:1] = outs[N-2:0];
    assign y = outs[N-1];
    (* keep_hierarchy *) amm_inverter inv_array [N-1:0] ( .a(ins), .y(outs) );

endmodule

module tapped_ring (
    input [2:0] tap,
    output y
);
    wire b0, b1, b1001, b1501, b1601, b1701, b1801, b1901, b2001, b2101;
    (* keep_hierarchy *) amm_inverter        start ( .a(   b0), .y(          b1) );
    (* keep_hierarchy *) inv_chain #(.N(1000))  c0 ( .a(   b1), .y(       b1001) );
    (* keep_hierarchy *) inv_chain #(.N(500))   c1 ( .a(b1001), .y(       b1501) );
    (* keep_hierarchy *) inv_chain #(.N(100))   c2 ( .a(b1501), .y(       b1601) );
    (* keep_hierarchy *) inv_chain #(.N(100))   c3 ( .a(b1601), .y(       b1701) );
    (* keep_hierarchy *) inv_chain #(.N(100))   c4 ( .a(b1701), .y(       b1801) );
    (* keep_hierarchy *) inv_chain #(.N(100))   c5 ( .a(b1801), .y(       b1901) );
    (* keep_hierarchy *) inv_chain #(.N(100))   c6 ( .a(b1901), .y(       b2001) );
    (* keep_hierarchy *) inv_chain #(.N(100))   c7 ( .a(b2001), .y(       b2101) );
    assign y =  tap == 0 ?   b1001:
                tap == 1 ?   b1501:
                tap == 2 ?   b1601:
                tap == 3 ?   b1701:
                tap == 4 ?   b1801:
                tap == 5 ?   b1901:
                tap == 6 ?   b2001:
                /*tap==7*/   b2101;
    assign b0 = y;
endmodule
