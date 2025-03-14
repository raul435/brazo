module memoria#(parameter DATA_WIDTH = 8, ADDRESS_WIDTH = 32)(
    input clk, ce, read_enable,
    input [7:0] address,
    output reg [7:0] data_out
);

// divisor de reloj a 1Hz
wire clk_1Hz;
clk_div clk_div_1Hz(
    .clk(clk),
    .rst(rst),
    .clk_out(clk_1Hz)
);

// one_shot ce
reg ce_one_shot;
one_shot ce_one_shot(.clk(clk_1Hz), .button(ce), .one_shot_button(ce_one_shot));

ROM #(DATA_WIDTH, ADDRESS_WIDTH) rom(
    .ce(ce_one_shot),
    .read_enable(read_enable),
    .address(address),
    .data(data_out)
);
endmodule