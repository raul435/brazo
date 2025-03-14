module PWM (
    input wire clk,
    input wire en,
    input wire [15:0] data,
    output reg pwm_out
);

    parameter PERIOD_CYCLES = 1_000_000;
    parameter MIN_PULSE = 25_000;
    parameter MAX_PULSE = 125_000;

    reg [7:0] duty_cycle = 50;  // Inicializamos en el 50% de ciclo de trabajo (posicion media)
    reg [19:0] pulse_duration = (MIN_PULSE + MAX_PULSE) / 2;  // Valor medio de pulse_duration
    reg [19:0] cycle_counter = 0;

    // Actualización de duty_cycle
    always @(posedge clk) begin
        if (en) begin
            duty_cycle <= data;  // Asignamos directamente data (debe estar en el rango 0-100)
        end else begin
            duty_cycle <= 25;  // Valor por defecto cuando 'en' está deshabilitado (posición media)
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


