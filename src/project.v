/*
 * Copyright (c) 2025 Remington Holder, Sherry Yu, Rohin Kumar, Julia Ke, Jeda Williams, Crystal Jiang
   Build upon Oscillator work by Anton Maurovic
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module and_gate(
    input wire a,
    input wire b,
    output wire y
);

  assign y = a & b;
 
endmodule

module tt_um_ring_osc3 #(parameter SIM_BYPASS=0)(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  assign uio_oe = 8'b1111_1111;

  wire osc, gated_osc;

  generate
    if (SIM_BYPASS) begin : g_bypass
      // synthesis translate_off
      reg osc_r = 1'b0;
      always #70 osc_r = ~osc_r;     // 70 ns half-period ≈ 7 MHz, safe for sim
      assign osc = osc_r;
      // synthesis translate_on
    end else begin : g_real
      `ifdef SIM
        // synthesis translate_off
        reg osc_r = 1'b0;
        always #70 osc_r = ~osc_r;   // for plain RTL sim
        assign osc = osc_r;
        // synthesis translate_on
      `else
        tapped_ring u_ring (.tap(ui_in[3:1]), .y(osc));  // real ring for hardware
      `endif
    end
  endgenerate

  // `ifdef SIM     // <--- define SIM in your iverilog/cocotb build
  //   // behavioral osc for simulation
  //   reg osc_r = 1'b0;
  //   // 80 Picoseconds times 1001 for the number of gates we have - ~ 80ns
  //   always #70.007ns osc_r = ~osc_r;  // 100 MHz toggles
  //   assign osc = osc_r;
  // `else
  //   tapped_ring tapped_ring ( .tap(ui_in[3:1]), .y(osc) );
  // `endif

  and_gate output_gate ( .a(  osc), .b(ui_in[0]), .y(gated_osc));
  assign uo_out[0] = gated_osc;

  wire enable = ui_in[0];

  reg en_d;                 // delay flop to detect rising edge
  always @(posedge osc) en_d <= enable;
  wire en_rise = enable & ~en_d;

  reg [14:0] count = 15'b0;

  always @(posedge osc) begin
      if (en_rise)           count <= 15'b0;          // clear once on rising edge
      else if (enable)       count <= count + 1'b1;  // count while enabled
      else                   count <= count;         // hold when disabled
  end

  // Show the count whenever enable is low (your requirement)
  assign uo_out[7:1] = (~enable) ? count[6:0] : 7'b0;
  assign uio_out[7:0] = (~enable) ? count[14:7] : 8'b0;

  // List all unused inputs to prevent warnings
  wire dummy = &{ui_in, uio_in, ena, rst_n};
  wire _unused = &{clk, 1'b0};

endmodule