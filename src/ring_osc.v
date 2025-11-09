`default_nettype none

//NOTE: I determined this definition as follows:
// - Searched for "sky130_fd_sc_hd__" combined with "inv", e.g.
//      find $PDK_ROOT/$PDK -iname "*sky130_fd_sc_hd__*inv*"
// - Found various versions, checked to find ones which are NOT bad by
//      making sure they do NOT appear in:
//      https://github.com/RTimothyEdwards/open_pdks/blob/master/sky130/openlane/sky130_fd_sc_hd/no_synth.cells
// - Chose sky130_fd_sc_hd__inv_2
// - Had a look at it in:
//      - https://foss-eda-tools.googlesource.com/skywater-pdk/libs/sky130_fd_sc_hd/+/refs/heads/new-spice/cells/inv/sky130_fd_sc_hd__inv_2.v
//      - https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_sc_hd/cells/inv/README.html
// - I was informed by my own former project:
//      https://repositories.efabless.com/amm_efabless/ci2409_counter_and_vga3/blob/main/f/verilog/rtl/antenna_breaker.v
//NOTE: Also need to make sure OpenLane RSZ_DONT_TOUCH_RX covers this?
// (* blackbox *) module sky130_fd_sc_hd__inv_2(
//     input A,
//     output Y // Inverted output.
// );
// endmodule

module amm_inverter (
    input   wire a,
    output  wire y
);

    (* keep_hierarchy *) sky130_fd_sc_hd__inv_2   sky_inverter (
        .A  (a),
        .Y  (y)
    );

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
    wire b0, b1, b1001, b1501, b1801, b1901, b2001, b2101, b2201, b2301;
    (* keep_hierarchy *) amm_inverter        start ( .a(   b0), .y(          b1) );
    (* keep_hierarchy *) inv_chain #(.N(1000))  c0 ( .a(   b1), .y(       b1001) );
    (* keep_hierarchy *) inv_chain #(.N(500))   c1 ( .a(b1001), .y(       b1501) );
    (* keep_hierarchy *) inv_chain #(.N(300))   c2 ( .a(b1501), .y(       b1801) );
    (* keep_hierarchy *) inv_chain #(.N(100))   c3 ( .a(b1801), .y(       b1901) );
    (* keep_hierarchy *) inv_chain #(.N(100))   c4 ( .a(b1901), .y(       b2001) );
    (* keep_hierarchy *) inv_chain #(.N(100))   c5 ( .a(b2001), .y(       b2101) );
    (* keep_hierarchy *) inv_chain #(.N(100))   c6 ( .a(b2101), .y(       b2201) );
    (* keep_hierarchy *) inv_chain #(.N(100))   c7 ( .a(b2201), .y(       b2301) );
    assign y =  tap == 0 ?   b1001:
                tap == 1 ?   b1501:
                tap == 2 ?   b1801:
                tap == 3 ?   b1901:
                tap == 4 ?   b2001:
                tap == 5 ?   b2101:
                tap == 6 ?   b2201:
                /*tap==7*/   b2301;
    assign b0 = y;
endmodule
