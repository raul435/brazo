module num_gen(
    input  [3:0] number_code,  // Código del número a dibujar (0-9)
    input  [9:0] x,             // Coordenada X actual del VGA
    input  [9:0] y,             // Coordenada Y actual del VGA
    input  [9:0] base_x,        // Posición X de inicio para este número
    input  [9:0] base_y,        // Posición Y de inicio para este número
    output       pixel          // Salida: 1 si (x,y) pertenece al número
);
    // Parámetros internos para el tamaño del número
    localparam NUMBER_HEIGHT = 100;
    localparam NUMBER_WIDTH  = 60;
    localparam LINE_WIDTH    = 20;

    reg pix;
    
    always @(*) begin
        // Por defecto, no se dibuja nada
        pix = 1'b0;
        case(number_code)
            // Número 0
            4'd0: if ((x >= base_x) && (x < base_x + LINE_WIDTH) && (y >= base_y) && (y < base_y + NUMBER_HEIGHT) ||
                     (x >= base_x + NUMBER_WIDTH - LINE_WIDTH) && (x < base_x + NUMBER_WIDTH) && (y >= base_y) && (y < base_y + NUMBER_HEIGHT) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y) && (y < base_y + LINE_WIDTH) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y + NUMBER_HEIGHT - LINE_WIDTH) && (y < base_y + NUMBER_HEIGHT))
                pix = 1'b1;
            
            // Número 1
            4'd1: if ((x >= base_x + NUMBER_WIDTH / 2 - LINE_WIDTH / 2) && (x < base_x + NUMBER_WIDTH / 2 + LINE_WIDTH / 2) && (y >= base_y) && (y < base_y + NUMBER_HEIGHT))
                pix = 1'b1;
            
            // Número 2
            4'd2: if ((x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y) && (y < base_y + LINE_WIDTH) ||
                     (x >= base_x + NUMBER_WIDTH - LINE_WIDTH) && (x < base_x + NUMBER_WIDTH) && (y >= base_y) && (y < base_y + NUMBER_HEIGHT / 2) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y + NUMBER_HEIGHT / 2 - LINE_WIDTH / 2) && (y < base_y + NUMBER_HEIGHT / 2 + LINE_WIDTH / 2) ||
                     (x >= base_x) && (x < base_x + LINE_WIDTH) && (y >= base_y + NUMBER_HEIGHT / 2) && (y < base_y + NUMBER_HEIGHT) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y + NUMBER_HEIGHT - LINE_WIDTH) && (y < base_y + NUMBER_HEIGHT))
                pix = 1'b1;
            
            // Número 3
            4'd3: if ((x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y) && (y < base_y + LINE_WIDTH) ||
                     (x >= base_x + NUMBER_WIDTH - LINE_WIDTH) && (x < base_x + NUMBER_WIDTH) && (y >= base_y) && (y < base_y + NUMBER_HEIGHT) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y + NUMBER_HEIGHT / 2 - LINE_WIDTH / 2) && (y < base_y + NUMBER_HEIGHT / 2 + LINE_WIDTH / 2) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y + NUMBER_HEIGHT - LINE_WIDTH) && (y < base_y + NUMBER_HEIGHT))
                pix = 1'b1;
            
            // Número 4
            4'd4: if ((x >= base_x) && (x < base_x + LINE_WIDTH) && (y >= base_y) && (y < base_y + NUMBER_HEIGHT / 2) ||
                     (x >= base_x + NUMBER_WIDTH - LINE_WIDTH) && (x < base_x + NUMBER_WIDTH) && (y >= base_y) && (y < base_y + NUMBER_HEIGHT) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y + NUMBER_HEIGHT / 2 - LINE_WIDTH / 2) && (y < base_y + NUMBER_HEIGHT / 2 + LINE_WIDTH / 2))
                pix = 1'b1;
            
            // Número 5
            4'd5: if ((x >= base_x) && (x < base_x + LINE_WIDTH) && (y >= base_y) && (y < base_y + NUMBER_HEIGHT / 2) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y) && (y < base_y + LINE_WIDTH) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y + NUMBER_HEIGHT / 2 - LINE_WIDTH / 2) && (y < base_y + NUMBER_HEIGHT / 2 + LINE_WIDTH / 2) ||
                     (x >= base_x + NUMBER_WIDTH - LINE_WIDTH) && (x < base_x + NUMBER_WIDTH) && (y >= base_y + NUMBER_HEIGHT / 2) && (y < base_y + NUMBER_HEIGHT) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y + NUMBER_HEIGHT - LINE_WIDTH) && (y < base_y + NUMBER_HEIGHT))
                pix = 1'b1;
            
            // Número 6
4'd6: if ((x >= base_x) && (x < base_x + LINE_WIDTH) && (y >= base_y) && (y < base_y + NUMBER_HEIGHT) || 
         (x >= base_x + NUMBER_WIDTH - LINE_WIDTH) && (x < base_x + NUMBER_WIDTH) && (y >= base_y + NUMBER_HEIGHT / 2) && (y < base_y + NUMBER_HEIGHT) ||
         (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y + NUMBER_HEIGHT - LINE_WIDTH) && (y < base_y + NUMBER_HEIGHT) ||
         (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y + NUMBER_HEIGHT / 2 - LINE_WIDTH / 2) && (y < base_y + NUMBER_HEIGHT / 2 + LINE_WIDTH / 2)) 
    pix = 1'b1;
            // Número 7, 8, 9 (declaraciones por separado)
            4'd7: if ((x >= base_x + NUMBER_WIDTH - LINE_WIDTH) && (x < base_x + NUMBER_WIDTH) && (y >= base_y) && (y < base_y + NUMBER_HEIGHT) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y) && (y < base_y + LINE_WIDTH))
                pix = 1'b1;
            4'd8: if ((x >= base_x) && (x < base_x + LINE_WIDTH) && (y >= base_y) && (y < base_y + NUMBER_HEIGHT) ||
                     (x >= base_x + NUMBER_WIDTH - LINE_WIDTH) && (x < base_x + NUMBER_WIDTH) && (y >= base_y) && (y < base_y + NUMBER_HEIGHT) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y) && (y < base_y + LINE_WIDTH) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y + NUMBER_HEIGHT / 2 - LINE_WIDTH / 2) && (y < base_y + NUMBER_HEIGHT / 2 + LINE_WIDTH / 2) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y + NUMBER_HEIGHT - LINE_WIDTH) && (y < base_y + NUMBER_HEIGHT))
                pix = 1'b1;
            4'd9: if ((x >= base_x + NUMBER_WIDTH - LINE_WIDTH) && (x < base_x + NUMBER_WIDTH) && (y >= base_y) && (y < base_y + NUMBER_HEIGHT) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y) && (y < base_y + LINE_WIDTH) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y + NUMBER_HEIGHT / 2 - LINE_WIDTH / 2) && (y < base_y + NUMBER_HEIGHT / 2 + LINE_WIDTH / 2) ||
                     (x >= base_x) && (x < base_x + LINE_WIDTH) && (y >= base_y) && (y < base_y + NUMBER_HEIGHT / 2) ||
                     (x >= base_x) && (x < base_x + NUMBER_WIDTH) && (y >= base_y + NUMBER_HEIGHT - LINE_WIDTH) && (y < base_y + NUMBER_HEIGHT))
                pix = 1'b1;
            
            default: pix = 1'b0; // Cualquier otro valor no se dibuja
        endcase
    end

    assign pixel = pix;

endmodule