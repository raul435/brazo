module rom #(parameter DATA_WIDTH = 10, ADDRESS_WIDTH = 8)(
    input wire ce, read_en,
    input wire [ADDRESS_WIDTH-1:0] addr,
    output reg [DATA_WIDTH-1:0] data_x, data_y, data_z
);

reg [DATA_WIDTH-1:0] mem_x [0:(2**(ADDRESS_WIDTH))-1];
reg [DATA_WIDTH-1:0] mem_y [0:(2**(ADDRESS_WIDTH))-1];
reg [DATA_WIDTH-1:0] mem_z [0:(2**(ADDRESS_WIDTH))-1];

initial begin
   $readmemh("servo1.hex", mem_x);
	$readmemh("servo2.hex", mem_y);
	$readmemh("servo3.hex", mem_z);

end

always @(*) begin
    if (ce && read_en) begin
        data_x = mem_x[addr];
        data_y = mem_y[addr];
        data_z = mem_z[addr];
    end else begin
        data_x = 0;
        data_y = 0;
        data_z = 0;
    end
end

endmodule