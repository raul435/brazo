module debouncer #(parameter N_MAX = 5000)(
	input clk,
			rst_a_p,	//reset asincrono, flanco positivo
			debouncer_in,
	output reg debouncer_out
);
// registro auxiliar

wire [ceillog2(N_MAX)-1:0] counter_out;
wire counter_match;

counter_debouncer #(.N_MAX(N_MAX)) CONTADOR_PARA_RATE(
.clk(clk),
.rst_a_p(rst_a_p),
.counter_out(counter_out),
.counter_match(counter_match)
);

always @(posedge clk or posedge rst_a_p)
begin
	if(rst_a_p)
		debouncer_out <= 0;
	else
		if(counter_match)
			debouncer_out <= debouncer_in;
		else
			debouncer_out <= debouncer_out;
end

function integer ceillog2;
	input integer data;
	integer i, result;
	begin
		for(i=0;2**i < data; i=i+1)
			result = i+1;
		ceillog2 = result;
	end
endfunction

endmodule