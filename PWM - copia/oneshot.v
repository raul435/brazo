module oneshot(
	input clk, button,
	output reg oneShot
);

//auxiliares
reg delay;

always @(posedge clk)
begin
delay <= button;
	if((delay != button) && button ==1)
		oneShot <= 1;
	else
		oneShot <= 0;
end

endmodule