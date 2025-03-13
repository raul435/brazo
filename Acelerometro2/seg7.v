module seg7(
    input  [3:0] in,
    output reg [6:0] display
);

always @(*) begin
    case(in)
        4'd0:  display = 7'b1000000; // 0
        4'd1:  display = 7'b1111001; // 1
        4'd2:  display = 7'b0100100; // 2
        4'd3:  display = 7'b0110000; // 3
        4'd4:  display = 7'b0011001; // 4
        4'd5:  display = 7'b0010010; // 5
        4'd6:  display = 7'b0000010; // 6
        4'd7:  display = 7'b1111000; // 7
        4'd8:  display = 7'b0000000; // 8
        4'd9:  display = 7'b0010000; // 9

        // Letras para representar los ejes (valores asignados: 10->X, 11->Y, 12->Z)
        4'd10: display = 7'b0100101; // Aproximación de "X"
        4'd11: display = 7'b0000011; // Aproximación de "Y"
        4'd12: display = 7'b0100111; // Aproximación de "Z"
        
        default: display = 7'b1111111; // Apaga el display o muestra un guión
    endcase
end

endmodule
