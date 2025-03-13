//Flip Flop D
module d_ff(
	input slow_clk, D,
	output reg Q
);

always @(posedge slow_clk)
begin
	Q <= D;
end
endmodule