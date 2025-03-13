// Testbench para el módulo accel
`timescale 1ns/1ps

module accel_tb();

  // Señales para conectar al DUT (Device Under Test)
  reg ADC_CLK_10;
  reg MAX10_CLK1_50;
  reg MAX10_CLK2_50;
  wire [0:6] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg [1:0] KEY;
  wire [9:0] LEDR;
  reg [9:0] SW;
  wire GSENSOR_CS_N;
  reg [2:1] GSENSOR_INT;
  wire GSENSOR_SCLK;
  wire GSENSOR_SDI;
  wire GSENSOR_SDO;
  wire [15:0] data_out_x;  // Modificado a 16 bits
  wire [15:0] data_out_y;  // Modificado a 16 bits
  wire [15:0] data_out_z;  // Modificado a 16 bits

  // Instancia del módulo a probar
  accel dut (
    .ADC_CLK_10(ADC_CLK_10),
    .MAX10_CLK1_50(MAX10_CLK1_50),
    .MAX10_CLK2_50(MAX10_CLK2_50),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX2(HEX2),
    .HEX3(HEX3),
    .HEX4(HEX4),
    .HEX5(HEX5),
    .KEY(KEY),
    .LEDR(LEDR),
    .SW(SW),
    .GSENSOR_CS_N(GSENSOR_CS_N),
    .GSENSOR_INT(GSENSOR_INT),
    .GSENSOR_SCLK(GSENSOR_SCLK),
    .GSENSOR_SDI(GSENSOR_SDI),
    .GSENSOR_SDO(GSENSOR_SDO),
    .data_out_x(data_out_x),
    .data_out_y(data_out_y),
    .data_out_z(data_out_z)
  );

  // Modelado básico del acelerómetro - para simular la comunicación SPI
  reg [15:0] sim_data_x = 16'h0123;
  reg [15:0] sim_data_y = 16'h0456;
  reg [15:0] sim_data_z = 16'h0789;
  
  // Asigna valores simulados al bus SPI (simplificado)
  assign GSENSOR_SDI = 1'bz;  // Alta impedancia
  assign GSENSOR_SDO = ~GSENSOR_CS_N ? 1'b1 : 1'bz;  // Datos simulados cuando CS está activo

  // Generación de relojes
  always begin
    #5 MAX10_CLK1_50 = ~MAX10_CLK1_50;  // Reloj de 50MHz (período de 20ns)
  end
  
  always begin
    #50 ADC_CLK_10 = ~ADC_CLK_10;  // Reloj de 10MHz (período de 100ns)
  end

  always begin
    #10 MAX10_CLK2_50 = ~MAX10_CLK2_50;  // Reloj de 50MHz (período de 20ns) con fase
  end

  // Función para decodificar los segmentos y mostrar el dígito
  function [3:0] decode_7seg;
    input [0:6] seg;
    begin
      case(seg)
        7'b1000000: decode_7seg = 4'd0;
        7'b1111001: decode_7seg = 4'd1;
        7'b0100100: decode_7seg = 4'd2;
        7'b0110000: decode_7seg = 4'd3;
        7'b0011001: decode_7seg = 4'd4;
        7'b0010010: decode_7seg = 4'd5;
        7'b0000010: decode_7seg = 4'd6;
        7'b1111000: decode_7seg = 4'd7;
        7'b0000000: decode_7seg = 4'd8;
        7'b0010000: decode_7seg = 4'd9;
        7'b0001000: decode_7seg = 4'd10; // A
        7'b0000011: decode_7seg = 4'd11; // b
        7'b1000110: decode_7seg = 4'd12; // C
        7'b0100001: decode_7seg = 4'd13; // d
        7'b0000110: decode_7seg = 4'd14; // E
        7'b0001110: decode_7seg = 4'd15; // F
        default:    decode_7seg = 4'd15; // Desconocido
      endcase
    end
  endfunction

  // Tareas para imprimir los valores de display
  task print_displays;
    begin
      $display("HEX0: %d", decode_7seg(HEX0));
      $display("HEX1: %d", decode_7seg(HEX1));
      $display("HEX2: %d", decode_7seg(HEX2));
      $display("HEX3: %d", decode_7seg(HEX3));
      $display("HEX4: %d", decode_7seg(HEX4));
      $display("HEX5: %d", decode_7seg(HEX5));
    end
  endtask

  // Secuencia de prueba
  initial begin
    // Inicialización
    MAX10_CLK1_50 = 0;
    MAX10_CLK2_50 = 0;
    ADC_CLK_10 = 0;
    KEY = 2'b11;  // Activo en bajo
    SW = 10'b0;
    GSENSOR_INT = 2'b0;
    
    // Iniciar un reset
    #100;
    KEY[0] = 0;  // Reset activo (activo en bajo)
    #100;
    KEY[0] = 1;  // Liberar reset
    
    // Esperar un tiempo para permitir la inicialización
    #1000;
    
    // Ciclo de prueba 1: Valores positivos
    $display("------ Test 1: Valores positivos ------");
    
    // Forzamos los valores internos del módulo spi_control (esto es un hack para el testbench)
    force dut.spi_ctrl.data_x = 16'h0055;  // Valor positivo 85
    force dut.spi_ctrl.data_y = 16'h0078;  // Valor positivo 120 
    force dut.spi_ctrl.data_z = 16'h00A0;  // Valor positivo 160
    
    // Simular múltiples ciclos del reloj dividido para asegurar que los valores se propaguen
    #1000000;  // Esperar suficiente tiempo para que clk_2_hz genere varios pulsos
    
    // Imprimir resultados
    $display("Valores forzados: X=85, Y=120, Z=160");
    $display("data_out_x: %d", data_out_x);
    $display("data_out_y: %d", data_out_y);
    $display("data_out_z: %d", data_out_z);
    print_displays();
    
    // Ciclo de prueba 2: Valores negativos
    $display("\n------ Test 2: Valores negativos ------");
    
    // Forzamos valores negativos
    force dut.spi_ctrl.data_x = 16'h8037;  // Valor negativo -55 en complemento a 2
    force dut.spi_ctrl.data_y = 16'h8050;  // Valor negativo -80 en complemento a 2
    force dut.spi_ctrl.data_z = 16'h8064;  // Valor negativo -100 en complemento a 2
    
    #1000000;  // Esperar suficiente tiempo para que clk_2_hz genere varios pulsos
    
    // Imprimir resultados
    $display("Valores forzados: X=-55, Y=-80, Z=-100");
    $display("data_out_x: %d", data_out_x);
    $display("data_out_y: %d", data_out_y);
    $display("data_out_z: %d", data_out_z);
    print_displays();
    
    // Fin de simulación
    #1000;
    $display("\n------ Simulación completada ------");
    $finish;
  end
  
  // Monitoreo
  initial begin
    $monitor("Tiempo=%t, Displays: %d %d %d %d %d %d", 
      $time, 
      decode_7seg(HEX0), decode_7seg(HEX1), decode_7seg(HEX2),
      decode_7seg(HEX3), decode_7seg(HEX4), decode_7seg(HEX5)
    );
  end

endmodule