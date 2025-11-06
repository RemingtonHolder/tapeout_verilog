/*
 * Copyright (c) 2024 Anton Maurovic
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module and_gate(
    input wire a,
    input wire b,
    output wire y
);
  (* keep_hierarchy *) sky130_fd_sc_hd__and2_1 sky_and (
    .A (a),
    .B (b),
    .X (y)
  );
 
endmodule

module tt_um_ring_osc3 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire osc, gated_osc;
  tapped_ring tapped_ring ( .tap(ui_in[3:1]), .y(osc));
  and_gate output_gate ( .a(  osc), .b(ui_in[0]), .y(gated_osc));
  assign uo_out[0] = gated_osc;
  // reg [6:0] count;

  // // Sync counter to osc, with async reset on enable rising edge
  // always @(posedge osc or posedge ui_in[0]) begin
  //     if (ui_in[0]) begin
  //         count <= 7'd0;                 // Clear when enable rises
  //     end else begin
  //         count <= count + 1'b1;         // Increment on osc edges while enabled
  //     end
  // end

  // // Output logic:
  // // - When enable is LOW, show the count value
  // // - When enable is HIGH, output 0 (or you could hold previous, your choice)
  // assign uo_out[7:1] = (~ui_in[0]) ? count : 7'b0;

  wire enable = ui_in[0];

  reg en_d;                 // delay flop to detect rising edge
  always @(posedge osc) en_d <= enable;
  wire en_rise = enable & ~en_d;

  reg [6:0] count;
  count <= 7'd0;

  always @(posedge osc) begin
      if (en_rise)           count <= 7'd0;          // clear once on rising edge
      else if (enable)       count <= count + 1'b1;  // count while enabled
      else                   count <= count;         // hold when disabled
  end

  // Show the count whenever enable is low (your requirement)
  assign uo_out[7:1] = (~enable) ? count : 7'b0;

  // List all unused inputs to prevent warnings
  wire dummy = &{ui_in, uio_in, ena, rst_n};
  assign uio_out[0] = dummy;
  wire _unused = &{clk, 1'b0};

  assign uio_oe = 8'b0000_0001;
  assign uio_out[7:1] = 7'b0000000;

endmodule