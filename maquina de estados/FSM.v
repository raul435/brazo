module FSM (

	input clk, rst, enable,
	input btn_mem,
	input [7:0] rom_data_x, rom_data_y, rom_data_z,
	input [7:0] data_accel_x, data_accel_y, data_accel_z,
	output reg [7:0] data_out_x, data_out_y, data_out_z
);

localparam IDLE = 0;
localparam ACCEL = 1;
localparam MEM = 2;

reg [1:0] state, next_state;

always @(posedge clk or negedge rst)begin	
	if (~rst)
		state <= IDLE;
	else
		state <= next_state;
end

always @(*)begin
	case (state)
		IDLE:begin
			if (btn_mem == 0 && enable ==1) 
				next_state <= ACCEL;
			else if (btn_mem == 1 && enable ==1) 
				next_state <= MEM;
			else
				next_state <= IDLE;
			end
				
		ACCEL:begin
			if (btn_mem == 0 && enable ==1) 
				next_state <= ACCEL;
			else if (btn_mem == 1 && enable ==1) 
				next_state <= MEM;
			else
				next_state <= IDLE;
			end
			
		MEM:begin
			if (btn_mem == 0 && enable ==1) 
				next_state <= ACCEL;
			else if (btn_mem == 1 && enable ==1) 
				next_state <= MEM;
			else
				next_state <= IDLE;
		
		
		
		end
	endcase
end

always @(*)begin

	case (state)
		IDLE:begin
			data_out_x <= 10;
			data_out_y <= 10;
			data_out_z <= 10;
		end

		ACCEL:begin
			data_out_x <= data_accel_x;
			data_out_y <= data_accel_y;
			data_out_z <= data_accel_z;
		end

		MEM:begin
			data_out_x <= rom_data_x;
			data_out_y <= rom_data_y;
			data_out_z <= rom_data_z;
		end
	endcase


end


endmodule