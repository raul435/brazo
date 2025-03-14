module PWM (
    input wire clk,
    input wire en,
    input wire [15:0] data,
    output reg pwm_out
);

    parameter PERIOD_CYCLES = 1_000_000;
    parameter MIN_PULSE = 25_000;
    parameter MAX_PULSE = 125_000;

    reg [7:0] duty_cycle = 25;  // Usamos 8 bits para duty_cycle
    reg [19:0] pulse_duration = MIN_PULSE;
    reg [19:0] cycle_counter = 0;

    // Actualización de duty_cycle
    always @(posedge clk) begin
        if (en) begin
            duty_cycle <= data*3;  // Asignamos directamente data, ya que está en el rango 0-100
        end else begin
            duty_cycle <= 25;  // Valor por defecto cuando 'en' está deshabilitado
        end
    end

    always @(posedge clk) begin
        if (!en) begin
            pwm_out <= 0;
            cycle_counter <= 0;
        end else begin
            // Ajuste del pulse_duration en base a duty_cycle
            pulse_duration <= MIN_PULSE + ((MAX_PULSE - MIN_PULSE) * duty_cycle) / 100;
            pwm_out <= (cycle_counter < pulse_duration) ? 1 : 0;
            cycle_counter <= (cycle_counter >= PERIOD_CYCLES - 1) ? 0 : cycle_counter + 1;
        end
    end

endmodule

