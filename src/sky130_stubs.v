`ifndef SKY130_MODELS
module sky130_fd_sc_hd__inv_2(input A, output Y); assign #1 Y = ~A; endmodule
module sky130_fd_sc_hd__and2_1(input A, input B, output X); assign X = A & B; endmodule
module sky130_fd_sc_hd__mux2_1(input A0, input A1, input S, output X); assign X = S ? A1 : A0; endmodule
module sky130_fd_sc_hd__conb_1(output LO, output HI); assign LO = 1'b0; assign HI = 1'b1; endmodule
`endif
