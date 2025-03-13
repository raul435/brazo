module debouncer2(
	input pb_1, clk, rst,
	output pb_out
);

wire Q0, Q1, Q2, Q2_bar;
wire slow_clk;

//reducir el reloj
clkdiv #(.FREQ(40)) u1(clk, rst, slow_clk);

//flip flops
d_ff d0(slow_clk, pb_1, Q0);
d_ff d1(slow_clk, Q0, Q1);
d_ff d2(slow_clk, Q1, Q2);

assign Q2_bar = ~ Q2;
assign pb_out = Q1 & Q2_bar;

endmodule