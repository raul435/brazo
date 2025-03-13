module PWM_servos (
    input  wire clk,          // Reloj principal
    input  wire rst,          // Reset
    input  wire enable,       // Habilita la generación de PWM

    // Botones para servo X
    input  wire pb_inc_x,     
    input  wire pb_dec_x,     

    // Botones para servo Y
    input  wire pb_inc_y,     
    input  wire pb_dec_y,     

    // Botones para servo Z
    input  wire pb_inc_z,     
    input  wire pb_dec_z,     

    // Salidas PWM para cada servo
    output reg pwm_out_x,     
    output reg pwm_out_y,     
    output reg pwm_out_z      
);

    // Parámetros para la señal PWM
    // frecuencia: número de ciclos para un período PWM (por ejemplo, 1_000_000 ciclos = 20 ms a 50 MHz)
    parameter frecuencia    = 1_000_000;  
    parameter pulso_min     = 25_000;      // Pulso mínimo (en ciclos)
    parameter pulso_max     = 125_000;     // Pulso máximo (en ciclos)
    parameter pulso_manual  = 5;           // Incremento/decremento en valor de DC

    // -------------------------------------------------------------------------
    // Debounce y divisor de reloj (se asume que tienes módulos debouncer2 y clkdiv)
    // -------------------------------------------------------------------------
    wire debounced_pb_inc_x, debounced_pb_dec_x;
    wire debounced_pb_inc_y, debounced_pb_dec_y;
    wire debounced_pb_inc_z, debounced_pb_dec_z;
    wire slow_clk;  // Reloj lento para actualizar el DC (por ejemplo, 1 Hz o lo que configures en clkdiv)

    // Instanciación de debouncers para cada botón
    debouncer2 d_inc_x (
        .clk    (clk),
        .rst    (rst),
        .pb_1   (pb_inc_x),
        .pb_out (debounced_pb_inc_x)
    );

    debouncer2 d_dec_x (
        .clk    (clk),
        .rst    (rst),
        .pb_1   (pb_dec_x),
        .pb_out (debounced_pb_dec_x)
    );

    debouncer2 d_inc_y (
        .clk    (clk),
        .rst    (rst),
        .pb_1   (pb_inc_y),
        .pb_out (debounced_pb_inc_y)
    );

    debouncer2 d_dec_y (
        .clk    (clk),
        .rst    (rst),
        .pb_1   (pb_dec_y),
        .pb_out (debounced_pb_dec_y)
    );

    debouncer2 d_inc_z (
        .clk    (clk),
        .rst    (rst),
        .pb_1   (pb_inc_z),
        .pb_out (debounced_pb_inc_z)
    );

    debouncer2 d_dec_z (
        .clk    (clk),
        .rst    (rst),
        .pb_1   (pb_dec_z),
        .pb_out (debounced_pb_dec_z)
    );

    // Instanciación del divisor de reloj para generar slow_clk
    clkdiv clock_divider_inst (
        .clk     (clk),
        .rst     (rst),
        .clk_div (slow_clk)
    );

    // -------------------------------------------------------------------------
    // Registros para almacenar el Duty Cycle (DC) de cada servo.
    // Se usa un valor entre 25 y 125, similar a tu ejemplo.
    // -------------------------------------------------------------------------
    reg [10:0] DC_x = 25;
    reg [10:0] DC_y = 25;
    reg [10:0] DC_z = 25;

    // Registros para almacenar el ancho de pulso (en ciclos) de cada servo
    reg [19:0] pulse_width_x = pulso_min;
    reg [19:0] pulse_width_y = pulso_min;
    reg [19:0] pulse_width_z = pulso_min;

    // Contador común para generar el período PWM
    reg [19:0] counter = 0;

    // Registros para detectar flancos de bajada en los botones (para cada servo)
    reg btn_up_last_x   = 1;
    reg btn_down_last_x = 1;
    reg btn_up_last_y   = 1;
    reg btn_down_last_y = 1;
    reg btn_up_last_z   = 1;
    reg btn_down_last_z = 1;

    // -------------------------------------------------------------------------
    // Actualización del Duty Cycle de cada servo usando el slow_clk y
    // la detección de flancos en los botones de incremento/decremento.
    // -------------------------------------------------------------------------
    always @(posedge slow_clk) begin
        if (enable) begin
            // Servo X
            if (!debounced_pb_inc_x && btn_up_last_x) begin
                if (DC_x < 125)
                    DC_x <= DC_x + pulso_manual;
            end
            if (!debounced_pb_dec_x && btn_down_last_x) begin
                if (DC_x > 25)
                    DC_x <= DC_x - pulso_manual;
            end

            // Servo Y
            if (!debounced_pb_inc_y && btn_up_last_y) begin
                if (DC_y < 125)
                    DC_y <= DC_y + pulso_manual;
            end
            if (!debounced_pb_dec_y && btn_down_last_y) begin
                if (DC_y > 25)
                    DC_y <= DC_y - pulso_manual;
            end

            // Servo Z
            if (!debounced_pb_inc_z && btn_up_last_z) begin
                if (DC_z < 125)
                    DC_z <= DC_z + pulso_manual;
            end
            if (!debounced_pb_dec_z && btn_down_last_z) begin
                if (DC_z > 25)
                    DC_z <= DC_z - pulso_manual;
            end
        end

        // Actualización de los estados anteriores de los botones
        btn_up_last_x   <= debounced_pb_inc_x;
        btn_down_last_x <= debounced_pb_dec_x;
        btn_up_last_y   <= debounced_pb_inc_y;
        btn_down_last_y <= debounced_pb_dec_y;
        btn_up_last_z   <= debounced_pb_inc_z;
        btn_down_last_z <= debounced_pb_dec_z;
    end

    // -------------------------------------------------------------------------
    // Generación de la señal PWM para cada servo
    // Se usa un contador común para el período y se calculan los anchos de pulso
    // en función del DC de cada servo.
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!enable) begin
            // Si no está habilitado, las salidas se mantienen en 0 y se reinicia el contador
            pwm_out_x <= 0;
            pwm_out_y <= 0;
            pwm_out_z <= 0;
            counter   <= 0;
        end else begin
            // Cálculo del ancho de pulso para cada servo
            pulse_width_x <= pulso_min + ((pulso_max - pulso_min) * (DC_x - 25)) / 100;
            pulse_width_y <= pulso_min + ((pulso_max - pulso_min) * (DC_y - 25)) / 100;
            pulse_width_z <= pulso_min + ((pulso_max - pulso_min) * (DC_z - 25)) / 100;

            // Generación de la señal PWM para cada servo
            pwm_out_x <= (counter < pulse_width_x) ? 1'b1 : 1'b0;
            pwm_out_y <= (counter < pulse_width_y) ? 1'b1 : 1'b0;
            pwm_out_z <= (counter < pulse_width_z) ? 1'b1 : 1'b0;

            // Actualización del contador para el período PWM
            if (counter >= frecuencia - 1)
                counter <= 0;
            else
                counter <= counter + 1;
        end
    end

endmodule
