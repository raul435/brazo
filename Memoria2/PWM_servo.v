module PWM_servo (
    input  wire clk,          // Reloj principal
    input  wire rst,          // Reset
    input  wire enable,       // Habilita la generación de PWM

    // Botón para modo ROM (leer las memorias)
    input  wire pb_rom,

    // Salidas PWM para cada servo
    output reg pwm_out_x,     
    output reg pwm_out_y,     
    output reg pwm_out_z      
);

    // Parámetros para la señal PWM
    parameter frecuencia   = 1_000_000;  // Número de ciclos para un período PWM (ej. 20 ms a 50 MHz)
    parameter pulso_min    = 25_000;      // Pulso mínimo (en ciclos)
    parameter pulso_max    = 125_000;     // Pulso máximo (en ciclos)

    //--------------------------------------------------------------------------
    // Debounce para el botón pb_rom y generación de un reloj lento (por ejemplo, 1 Hz)
    //--------------------------------------------------------------------------
    wire debounced_pb_rom;
    wire slow_clk;

    debouncer2 d_rom (
        .clk(clk),
        .rst(rst),
        .pb_1(pb_rom),
        .pb_out(debounced_pb_rom)
    );

    clkdiv clock_divider_inst (
        .clk(clk),
        .rst(rst),
        .clk_div(slow_clk)
    );

    //--------------------------------------------------------------------------
    // ROMs para cada servo (cada una carga un archivo .hex distinto)
    //--------------------------------------------------------------------------
    // Registro para la dirección de lectura en la ROM
    reg [7:0] rom_address = 0;
    // Registro para detectar el flanco de bajada en pb_rom
    reg pb_rom_last = 1;

    wire [7:0] rom_data_x;
    wire [7:0] rom_data_y;
    wire [7:0] rom_data_z;
    
    ROM #(.DATA_WIDTH(8), .ADDRESS_WIDTH(8), .HEX_FILE("servo1.hex")) rom_x (
        .ce(1'b1),
        .read_en(1'b1),
        .address(rom_address),
        .data(rom_data_x)
    );
    ROM #(.DATA_WIDTH(8), .ADDRESS_WIDTH(8), .HEX_FILE("servo2.hex")) rom_y (
        .ce(1'b1),
        .read_en(1'b1),
        .address(rom_address),
        .data(rom_data_y)
    );
    ROM #(.DATA_WIDTH(8), .ADDRESS_WIDTH(8), .HEX_FILE("servo3.hex")) rom_z (
        .ce(1'b1),
        .read_en(1'b1),
        .address(rom_address),
        .data(rom_data_z)
    );

    //--------------------------------------------------------------------------
    // Registros para almacenar el Duty Cycle (DC) de cada servo.
    // Los valores se actualizan desde la ROM (deben estar en el rango 25 a 125)
    //--------------------------------------------------------------------------
    reg [10:0] DC_x = 25;
    reg [10:0] DC_y = 25;
    reg [10:0] DC_z = 25;

    // Registros para almacenar el ancho de pulso (en ciclos)
    reg [19:0] pulse_width_x = pulso_min;
    reg [19:0] pulse_width_y = pulso_min;
    reg [19:0] pulse_width_z = pulso_min;

    // Contador común para generar el período PWM
    reg [19:0] counter = 0;

    //--------------------------------------------------------------------------
    // Actualización del Duty Cycle (DC) mediante slow_clk y modo ROM
    //--------------------------------------------------------------------------
    always @(posedge slow_clk) begin
        if (enable) begin
            // Si se presiona el botón ROM (detectado en bajo)
            if (!debounced_pb_rom) begin
                // Detecta flanco de bajada para incrementar la dirección de la ROM
                if (pb_rom_last == 1)
                    rom_address <= rom_address + 1;
                // Actualiza los DC con los valores leídos de la ROM
                DC_x <= rom_data_x;
                DC_y <= rom_data_y;
                DC_z <= rom_data_z;
            end
        end
        pb_rom_last <= debounced_pb_rom;
    end

    //--------------------------------------------------------------------------
    // Generación de la señal PWM para cada servo
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!enable) begin
            pwm_out_x <= 0;
            pwm_out_y <= 0;
            pwm_out_z <= 0;
            counter   <= 0;
        end else begin
            pulse_width_x <= pulso_min + ((pulso_max - pulso_min) * (DC_x - 25)) / 100;
            pulse_width_y <= pulso_min + ((pulso_max - pulso_min) * (DC_y - 25)) / 100;
            pulse_width_z <= pulso_min + ((pulso_max - pulso_min) * (DC_z - 25)) / 100;

            pwm_out_x <= (counter < pulse_width_x) ? 1'b1 : 1'b0;
            pwm_out_y <= (counter < pulse_width_y) ? 1'b1 : 1'b0;
            pwm_out_z <= (counter < pulse_width_z) ? 1'b1 : 1'b0;

            if (counter >= frecuencia - 1)
                counter <= 0;
            else
                counter <= counter + 1;
        end
    end

endmodule
