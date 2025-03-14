module FSM (

	input clk, rst, enable
	input btn_mem,
	input [7:0] data_mem_x, data_mem_y, data_mem_z,
	input [7:0] data_accel_x, data_accel_y, data_accel_z,
	output reg [7:0] data_out_x, data_out_y, data_out_z,
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

	case (state)
		IDLE:begin
			data_out_x <= 50;
			data_out_y <= 50;
			data_out_z <= 50;
		end

		ACCEL:begin
			data_out_x <= data_accel_x;
			data_out_y <= data_accel_y;
			data_out_z <= data_accel_z;
		end

		MEM:begin
			data_out_x <= data_mem_x;
			data_out_y <= data_mem_y;
			data_out_z <= data_mem_z;
		end
	endcase


end


endmodule