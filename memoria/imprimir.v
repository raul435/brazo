module imprimir #(parameter DATA_WIDTH = 8, ADDRESS_WIDTH)(
    input clk, ce, enable
    input [DATA_WIDTH - 1:0] data,
    input [ADDRESS_WIDTH - 1:0] address,
    output reg [DATA_WIDTH - 1:0] led,
    output reg [0:6] seg1, seg2
);



endmodule
