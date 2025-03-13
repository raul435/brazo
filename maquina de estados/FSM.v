module FSM (

	input clk, rst, enable
	input btn_mem,
	output reg state
	

);

localparam IDLE = 0;
localparam ACCEL = 1;
localparam MEM = 2;

reg next_state;

always @(posedge clk, or negedge rst)begin	
	if (~rst)
		state <= IDLE;
	else
		state <= next_state;
end

always @(state, enable)begin
	case (state)
		IDLE:begin
			if (btn_mem == 0 && enable ==1) 
				next_state <= ACCEL;
			else if (btn_mem == 1 && enable ==1) 
				next_state <= MEM;
			else
				next_state <= IDLE;
		end
	endcase
end

always @(state, enable)begin



end
