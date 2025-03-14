module ROM #(
   parameter DATA_WIDTH = 8,
   parameter ADDRESS_WIDTH = 8,
   parameter HEX_FILE = "ROM.hex"
)(
   input ce, read_en,
   input [ADDRESS_WIDTH-1:0] address,
   output [DATA_WIDTH-1:0] data
);

reg [DATA_WIDTH-1:0] mem [0:(2**(ADDRESS_WIDTH))-1];

initial begin
   $readmemH(HEX_FILE, mem);
end

assign data = (ce && read_en) ? mem[address] : {DATA_WIDTH{1'b0}};

endmodule
