module VGADemo(
    input         MAX10_CLK1_50,
    input  [15:0] data_x,  // Valor escalado del acelerómetro para X
    input  [15:0] data_y,  // Valor escalado del acelerómetro para Y
    input  [15:0] data_z,  // Valor escalado del acelerómetro para Z
    output reg [3:0] VGA_R, VGA_G, VGA_B,
    output        VGA_HS,
    output        VGA_VS
);

    //====================================================
    // Generación del reloj de píxel (25 MHz) y sincronismo VGA
    //====================================================
    wire clk_pix; 
    clock_divider #(.FREQ(25000000)) clkmedio(
        .clk(MAX10_CLK1_50),
        .rst(1'b0),
        .clk_div(clk_pix)
    );
 
    wire inDisplayArea;
    wire [9:0] CounterX;
    wire [9:0] CounterY;
    
    hvsync_gen hvsync(
        .clk(clk_pix),
        .vga_h_sync(VGA_HS),
        .vga_v_sync(VGA_VS),
        .CounterX(CounterX),
        .CounterY(CounterY),
        .inDisplayArea(inDisplayArea)
    );

    //====================================================
    // Parámetros para el layout (tamaño y posición de caracteres)
    //====================================================
    localparam LETTER_WIDTH  = 60;  // Área para cada letra/dígito
    localparam LETTER_HEIGHT = 100; // Área para cada letra/dígito
    localparam DIGIT_GAP     = 10;  // Espacio de 10 píxeles entre dígitos

    // Posición base para la cadena de cada línea
    localparam BASE_X_START = 50;
    localparam LINE1_Y      = 50;   // Línea para "X: <num>"
    localparam LINE2_Y      = 170;  // Línea para "Y: <num>"
    localparam LINE3_Y      = 290;  // Línea para "Z: <num>"

    //====================================================
    // Cálculo de centenas, decenas y unidades para cada valor de acelerómetro
    //====================================================
    // Se asume que los valores son menores a 1000 para poder mostrarlos con tres dígitos
    reg [3:0] X_hund, X_tens, X_ones;
    reg [3:0] Y_hund, Y_tens, Y_ones;
    reg [3:0] Z_hund, Z_tens, Z_ones;

    always @(*) begin
        // Para data_x
        X_hund = data_x / 100;
        X_tens = (data_x % 100) / 10;
        X_ones = data_x % 10;

        // Para data_y
        Y_hund = data_y / 100;
        Y_tens = (data_y % 100) / 10;
        Y_ones = data_y % 10;

        // Para data_z
        Z_hund = data_z / 100;
        Z_tens = (data_z % 100) / 10;
        Z_ones = data_z % 10;
    end

    //====================================================
    // Instanciación de módulos letter_gene para letras y carácter ":" 
    //====================================================
    // Línea X
    wire pixel_X;
    wire pixel_colon_X;
    
    letter_gene letter_X(
        .letter_code(8'h58),  // 'X'
        .x(CounterX),
        .y(CounterY),
        .base_x(BASE_X_START),
        .base_y(LINE1_Y),
        .pixel(pixel_X)
    );
    letter_gene letter_colon_X(
        .letter_code(8'h3A),  // ':'
        .x(CounterX),
        .y(CounterY),
        .base_x(BASE_X_START + LETTER_WIDTH),
        .base_y(LINE1_Y),
        .pixel(pixel_colon_X)
    );
    
    // Línea Y
    wire pixel_Y;
    wire pixel_colon_Y;
    
    letter_gene letter_Y(
        .letter_code(8'h59),  // 'Y'
        .x(CounterX),
        .y(CounterY),
        .base_x(BASE_X_START),
        .base_y(LINE2_Y),
        .pixel(pixel_Y)
    );
    letter_gene letter_colon_Y(
        .letter_code(8'h3A),  // ':'
        .x(CounterX),
        .y(CounterY),
        .base_x(BASE_X_START + LETTER_WIDTH),
        .base_y(LINE2_Y),
        .pixel(pixel_colon_Y)
    );
    
    // Línea Z
    wire pixel_Z;
    wire pixel_colon_Z;
    
    letter_gene letter_Z(
        .letter_code(8'h5A),  // 'Z'
        .x(CounterX),
        .y(CounterY),
        .base_x(BASE_X_START),
        .base_y(LINE3_Y),
        .pixel(pixel_Z)
    );
    letter_gene letter_colon_Z(
        .letter_code(8'h3A),  // ':'
        .x(CounterX),
        .y(CounterY),
        .base_x(BASE_X_START + LETTER_WIDTH),
        .base_y(LINE3_Y),
        .pixel(pixel_colon_Z)
    );

    //====================================================
    // Instanciación de módulos num_gen para los 3 dígitos de cada línea
    // Se agrega un espacio (DIGIT_GAP) entre cada dígito.
    //====================================================
    // Línea X
    wire pixel_X_hund, pixel_X_tens, pixel_X_ones;
    num_gen num_X_hund(
        .number_code(X_hund),
        .x(CounterX),
        .y(CounterY),
        .base_x(BASE_X_START + LETTER_WIDTH + DIGIT_GAP), // Primer dígito (centenas)
        .base_y(LINE1_Y),
        .pixel(pixel_X_hund)
    );
    num_gen num_X_tens(
        .number_code(X_tens),
        .x(CounterX),
        .y(CounterY),
        .base_x(BASE_X_START + LETTER_WIDTH + DIGIT_GAP + LETTER_WIDTH + DIGIT_GAP), // Segundo dígito (decenas)
        .base_y(LINE1_Y),
        .pixel(pixel_X_tens)
    );
    num_gen num_X_ones(
        .number_code(X_ones),
        .x(CounterX),
        .y(CounterY),
        .base_x(BASE_X_START + LETTER_WIDTH + DIGIT_GAP + 2*(LETTER_WIDTH + DIGIT_GAP)), // Tercer dígito (unidades)
        .base_y(LINE1_Y),
        .pixel(pixel_X_ones)
    );

    // Línea Y
    wire pixel_Y_hund, pixel_Y_tens, pixel_Y_ones;
    num_gen num_Y_hund(
        .number_code(Y_hund),
        .x(CounterX),
        .y(CounterY),
        .base_x(BASE_X_START + LETTER_WIDTH + DIGIT_GAP),
        .base_y(LINE2_Y),
        .pixel(pixel_Y_hund)
    );
    num_gen num_Y_tens(
        .number_code(Y_tens),
        .x(CounterX),
        .y(CounterY),
        .base_x(BASE_X_START + LETTER_WIDTH + DIGIT_GAP + LETTER_WIDTH + DIGIT_GAP),
        .base_y(LINE2_Y),
        .pixel(pixel_Y_tens)
    );
    num_gen num_Y_ones(
        .number_code(Y_ones),
        .x(CounterX),
        .y(CounterY),
        .base_x(BASE_X_START + LETTER_WIDTH + DIGIT_GAP + 2*(LETTER_WIDTH + DIGIT_GAP)),
        .base_y(LINE2_Y),
        .pixel(pixel_Y_ones)
    );

    // Línea Z
    wire pixel_Z_hund, pixel_Z_tens, pixel_Z_ones;
    num_gen num_Z_hund(
        .number_code(Z_hund),
        .x(CounterX),
        .y(CounterY),
        .base_x(BASE_X_START + LETTER_WIDTH + DIGIT_GAP),
        .base_y(LINE3_Y),
        .pixel(pixel_Z_hund)
    );
    num_gen num_Z_tens(
        .number_code(Z_tens),
        .x(CounterX),
        .y(CounterY),
        .base_x(BASE_X_START + LETTER_WIDTH + DIGIT_GAP + LETTER_WIDTH + DIGIT_GAP),
        .base_y(LINE3_Y),
        .pixel(pixel_Z_tens)
    );
    num_gen num_Z_ones(
        .number_code(Z_ones),
        .x(CounterX),
        .y(CounterY),
        .base_x(BASE_X_START + LETTER_WIDTH + DIGIT_GAP + 2*(LETTER_WIDTH + DIGIT_GAP)),
        .base_y(LINE3_Y),
        .pixel(pixel_Z_ones)
    );

    //====================================================
    // Lógica de dibujo: se pinta en negro donde alguno de los módulos devuelve 1 y el fondo queda en blanco
    //====================================================
    wire draw_pixel;
    assign draw_pixel = pixel_X   || pixel_colon_X || pixel_X_hund || pixel_X_tens || pixel_X_ones ||
                        pixel_Y   || pixel_colon_Y || pixel_Y_hund || pixel_Y_tens || pixel_Y_ones ||
                        pixel_Z   || pixel_colon_Z || pixel_Z_hund || pixel_Z_tens || pixel_Z_ones;

    always @(posedge clk_pix) begin
        if (inDisplayArea) begin
            if (draw_pixel) begin
                VGA_R <= 4'b0000;
                VGA_G <= 4'b0000;
                VGA_B <= 4'b0000;
            end else begin
                VGA_R <= 4'b1111;
                VGA_G <= 4'b1111;
                VGA_B <= 4'b1111;
            end
        end else begin
            VGA_R <= 4'b0000;
            VGA_G <= 4'b0000;
            VGA_B <= 4'b0000;
        end
    end

endmodule
