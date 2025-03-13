module PWMtest(
    input pb_inc,
    input pb_dec,
    input clk,
    input rst,
    output pwm_out
);

wire neg_pb_inc = ~pb_inc;
wire neg_pb_dec = ~pb_dec;
wire slow_clk;
wire debounced_pb_inc, debounced_pb_dec;

    // Registro para el duty cycle
    reg [31:0] DC;

    // Parámetros del sistema
    parameter base_freq   = 50_000_000;   // Frecuencia de reloj base
    parameter target_freq = 50;           // Frecuencia deseada para refresco del servo (50 Hz)
    parameter counts      = base_freq / target_freq; // Contador total para 20 ms

    // Parámetros para el pulso del servo:
    // 1ms = 50,000 ciclos y 2ms = 100,000 ciclos (con un reloj de 50MHz)
    parameter MIN_DC = 50_000;    // Pulso mínimo (1ms)
    parameter MAX_DC = 100_000;   // Pulso máximo (2ms)
    parameter STEP   = 2780;      // Aproximadamente 10° de movimiento

    // Divisor de reloj para obtener slow_clk de 50 Hz (refresco del servo)
    clkdiv #(.FREQ(target_freq)) clkdiv_inst (
        .clk(clk),
        .rst(rst),
        .clk_div(slow_clk)
    );

    // Debouncers para los botones
    debouncer2 deb_inc(
        .pb_1(neg_pb_inc),
        .clk(slow_clk),
        .rst(rst),
        .pb_out(debounced_pb_inc)
    );
    debouncer2 deb_dec(
        .pb_1(neg_pb_dec),
        .clk(slow_clk),
        .rst(rst),
        .pb_out(debounced_pb_dec)
    );

    // Generador del duty cycle: ajusta el ancho del pulso en función de los botones
    always @(posedge slow_clk or negedge rst) begin
        if (!rst)
            DC <= (MIN_DC + MAX_DC) / 2; // Posición central (neutral)
        else begin
            if (debounced_pb_inc && (DC + STEP <= MAX_DC))
                DC <= DC + STEP;
            else if (debounced_pb_dec && (DC - STEP >= MIN_DC))
                DC <= DC - STEP;
            else
                DC <= DC;
        end
    end

    // Generador de la señal PWM:
    // Se utiliza el reloj base (50 MHz) para tener suficiente resolución en el pulso.
    reg [31:0] counter;
    always @(posedge clk or negedge rst) begin
        if (!rst)
            counter <= 0;
        else if (counter >= counts - 1)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    // pwm_out es alto mientras el contador esté por debajo del duty cycle (DC)
    assign pwm_out = (counter < DC) ? 1'b1 : 1'b0;

endmodule