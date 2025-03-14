module letter_gene(
    input  [7:0] letter_code,   // Código ASCII de la letra a dibujar
    input  [9:0] x,             // Coordenada X actual del VGA
    input  [9:0] y,             // Coordenada Y actual del VGA
    input  [9:0] base_x,        // Posición X de inicio para esta letra
    input  [9:0] base_y,        // Posición Y de inicio para esta letra
    output       pixel          // Salida: 1 si (x,y) pertenece a la letra
);

    // Parámetros internos para el tamaño de la letra
    localparam LETTER_HEIGHT = 100;
    localparam LETTER_WIDTH  = 60;
    localparam LINE_WIDTH    = 10; // Se reduce para hacer las líneas homogéneas

    reg pix;
    
    always @(*) begin
        // Por defecto, no se dibuja nada
        pix = 1'b0;
        
        case(letter_code)
            // X (8'h58): Dos diagonales cruzadas con ancho uniforme.
            8'h58: begin
                if ((x >= base_x) && (x < base_x + LETTER_WIDTH) &&
                    (y >= base_y) && (y < base_y + LETTER_HEIGHT)) begin
                    if (((x - base_x) >= ((y - base_y) * LETTER_WIDTH) / LETTER_HEIGHT - LINE_WIDTH / 2 &&
                         (x - base_x) <= ((y - base_y) * LETTER_WIDTH) / LETTER_HEIGHT + LINE_WIDTH / 2) ||
                        ((base_x + LETTER_WIDTH - 1 - x) >= ((y - base_y) * LETTER_WIDTH) / LETTER_HEIGHT - LINE_WIDTH / 2 &&
                         (base_x + LETTER_WIDTH - 1 - x) <= ((y - base_y) * LETTER_WIDTH) / LETTER_HEIGHT + LINE_WIDTH / 2))
                        pix = 1'b1;
                end
            end

            // Y (8'h59): Parte superior en "V" y barra vertical con ancho uniforme.
            8'h59: begin
                // Parte superior en "V"
                if ((((x - base_x) >= ((y - base_y) * (LETTER_WIDTH / 2)) / (LETTER_HEIGHT / 2) - LINE_WIDTH / 2) &&
                     ((x - base_x) <= ((y - base_y) * (LETTER_WIDTH / 2)) / (LETTER_HEIGHT / 2) + LINE_WIDTH / 2) &&
                     (y < base_y + LETTER_HEIGHT / 2)) ||
                    (((base_x + LETTER_WIDTH - 1 - x) >= ((y - base_y) * (LETTER_WIDTH / 2)) / (LETTER_HEIGHT / 2) - LINE_WIDTH / 2) &&
                     ((base_x + LETTER_WIDTH - 1 - x) <= ((y - base_y) * (LETTER_WIDTH / 2)) / (LETTER_HEIGHT / 2) + LINE_WIDTH / 2) &&
                     (y < base_y + LETTER_HEIGHT / 2)))
                    pix = 1'b1;

                // Barra vertical central en la parte inferior
                else if ((x >= base_x + (LETTER_WIDTH >> 1) - (LINE_WIDTH >> 1)) &&
                         (x < base_x + (LETTER_WIDTH >> 1) + (LINE_WIDTH >> 1)) &&
                         (y >= base_y + LETTER_HEIGHT / 2) && (y < base_y + LETTER_HEIGHT))
                    pix = 1'b1;
            end

            // Z (8'h5A): Barras horizontales y diagonal con ancho uniforme.
            8'h5A: begin
                // Barra superior
                if ((x >= base_x) && (x < base_x + LETTER_WIDTH) &&
                    (y >= base_y) && (y < base_y + LINE_WIDTH))
                    pix = 1'b1;

                // Barra inferior
                else if ((x >= base_x) && (x < base_x + LETTER_WIDTH) &&
                         (y >= base_y + LETTER_HEIGHT - LINE_WIDTH) &&
                         (y < base_y + LETTER_HEIGHT))
                    pix = 1'b1;

                // Diagonal dentro de la Z con ancho uniforme
                else if ((x >= base_x) && (x < base_x + LETTER_WIDTH) &&
                         (y >= base_y) && (y < base_y + LETTER_HEIGHT) &&
                         ((x - base_x) >= (LETTER_WIDTH - 1 - (y - base_y) * LETTER_WIDTH / LETTER_HEIGHT) - LINE_WIDTH / 2 &&
                          (x - base_x) <= (LETTER_WIDTH - 1 - (y - base_y) * LETTER_WIDTH / LETTER_HEIGHT) + LINE_WIDTH / 2))
                    pix = 1'b1;
            end

            default: pix = 1'b0; // Cualquier otro carácter no se dibuja
        endcase
    end

    assign pixel = pix;

endmodule