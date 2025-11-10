/*
 * Copyright (c) 2025 Remington Holder, Sherry Yu, Rohin Kumar, Julia Ke, Jeda Williams, Crystal Jiang
   Build upon Oscillator work by Anton Maurovic
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

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

  wire test_mode = ui_in[4];

  wire osc;

  wire count_clk = test_mode ? clk : osc;

  wire enable = ui_in[0];

  generate
    if (SIM_BYPASS) begin : g_bypass
      // synthesis translate_off
      reg osc_r = 1'b0;
      always #70 osc_r = ~osc_r;
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
        tapped_ring u_ring (.tap(ui_in[3:1]), .enable(enable), .y(osc));  // real ring for hardware
      `endif
    end
  endgenerate

  // Async reset to flops so GLS never starts at X ---
  reg en_d;
  always @(posedge count_clk or negedge rst_n) begin
    if (!rst_n) en_d <= 1'b0;
    else        en_d <= enable;
  end
  wire en_rise = enable & ~en_d;

  reg [14:0] count = 15'b0;

  always @(posedge count_clk or negedge rst_n) begin
    if (!rst_n)        count <= 15'd0;
    else if (enable)   count <= count + 15'd1;
  end

  
  assign uo_out[0]   = (test_mode ? 1'b0 : (enable & osc));  // quiet the RO pin in test mode
  assign uo_out[7:1] = (~enable) ? count[6:0] : 7'b0;
  assign uio_out[7:0] = (~enable) ? count[14:7] : 8'b0;

  // List all unused inputs to prevent warnings
  wire dummy = &{ui_in, uio_in, ena};
  wire _unused = &{clk, 1'b0};

endmodule