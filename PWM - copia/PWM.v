module PWM(
	input pb_inc,
	input pb_dec,
	input enable,
	input clk,
	output reg pwm_out
);

wire slow_clk;
wire debounced_pb_inc, debounced_pb_dec;


reg [31:0] DC = 0;

parameter base_freq = 'd50_000_000;
parameter target_freq = 'd50;
parameter counts = base_freq/target_freq;

// Parámetros para la señal PWM para servo
parameter PERIOD = 1_000_000;     // 20 ms (50 MHz)
parameter PULSE_MIN = 25_000;     // Pulso mínimo (por ejemplo, 0.5 ms)
parameter PULSE_MAX = 125_000;    // Pulso máximo (por ejemplo, 2.5 ms)
parameter STEP_PERCENT = 10;      // Incremento/decremento en duty cycle por clic

//reducir el reloj
clkdiv u1(clk, rst, slow_clk);


//debouncers
debouncer2 d0(slow_clk, rst, pb_inc, debounced_pb_inc);
debouncer2 d1(slow_clk, rst, pb_dec, debounced_pb_dec);


//generador duty cycle
 // Registro que controla el duty cycle. Se mapea de 25 (mínimo) a 125 (máximo).
    reg [10:0] duty_percent = 25;  // Valor inicial en el mínimo
    reg [19:0] pulse_width = PULSE_MIN;
    reg [19:0] counter = 0;

    // Registros para detectar flanco de bajada en los botones
    reg btn_up_last = 1;
    reg btn_down_last = 1;

    // Control del duty cycle con slow_clk
    // Se actualiza solo cuando enable está activo
    always @(posedge slow_clk) begin
        if (enable) begin
            // Incrementa duty_percent si se detecta flanco de bajada en btn_up
            if (!debounced_pb_inc && btn_up_last) begin
                if (duty_percent < 125)
                    duty_percent <= duty_percent + STEP_PERCENT;
            end

            // Decrementa duty_percent si se detecta flanco de bajada en btn_down
            if (!debounced_pb_dec && btn_down_last) begin
                if (duty_percent > 25)
                    duty_percent <= duty_percent - STEP_PERCENT;
            end
        end
        // Actualiza el estado anterior de los botones (siempre)
        btn_up_last <= debounced_pb_inc;
        btn_down_last <= debounced_pb_dec;
    end

    // Generación del PWM para el servo usando el reloj base (50 MHz)
    always @(posedge clk) begin
        if (!enable) begin
            pwm_out <= 0;
            counter <= 0;
        end else begin
            // Calcula el ancho de pulso en función del duty_percent.
            // Cuando duty_percent es 25 → pulse_width = PULSE_MIN,
            // y cuando es 125 → pulse_width = PULSE_MAX.
            pulse_width <= PULSE_MIN + ((PULSE_MAX - PULSE_MIN) * (duty_percent - 25)) / 100;
            
            // Genera la señal PWM
            if (counter < pulse_width)
                pwm_out <= 1;
            else
                pwm_out <= 0;

            // Reinicia el contador al final del periodo
            if (counter >= PERIOD - 1)
                counter <= 0;
            else
                counter <= counter + 1;
        end
    end

endmodule