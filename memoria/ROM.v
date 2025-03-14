
module ROM #(parameter DATA_WIDTH = 8, ADDRESS_WIDTH = 8)(

	input ce, read_enable, 
	input [ADDRESS_WIDTH - 1:0] address,
	output [DATA_WIDTH - 1:0] data

);

reg [DATA_WIDTH - 1:0] mem [0:2**ADDRESS_WIDTH - 1];

initial begin
	$readmemh("pocisiones.dec", mem);
end

assign data = (ce && read_enable) ? mem[address] : 0;

endmodule