module PWM (
    input wire clk,
    input wire en,
    input wire [15:0] data,
    output reg pwm_out
);

    parameter PERIOD_CYCLES = 1_000_000;
    parameter MIN_PULSE = 25_000;
    parameter MAX_PULSE = 125_000;
    parameter STEP_SIZE = 5;

    wire clk_slow;

    reg [10:0] duty_cycle = 25;
    reg [19:0] pulse_duration = MIN_PULSE;
    reg [19:0] cycle_counter = 0;

    ClockDivider clock_divider_inst ( .clk(clk), .rst(0), .clk_div(clk_slow) );

    always @(posedge clk_slow) begin
        if (en) begin
				duty_cycle <= duty_cycle * data;
        end
    end

    always @(posedge clk) begin
        if (!en) begin
            pwm_out <= 0;
            cycle_counter <= 0;
        end else begin
            pulse_duration <= MIN_PULSE + ((MAX_PULSE - MIN_PULSE) * (duty_cycle - 25)) / 100;
            pwm_out <= (cycle_counter < pulse_duration) ? 1 : 0;
            cycle_counter <= (cycle_counter >= PERIOD_CYCLES - 1) ? 0 : cycle_counter + 1;
        end
    end

endmodule


