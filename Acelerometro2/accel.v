//===========================================================================
// accel.v
//
// Módulo modificado para ralentizar la actualización de los displays
// y mostrar los valores de los 3 ejes (X, Y y Z) en 2 dígitos cada uno.
//===========================================================================

module accel (
   //////////// CLOCK //////////
   input                   MAX10_CLK1_50,
   //////////// SEG7 //////////
   output          [7:0]   HEX0,
   output          [7:0]   HEX1,
   output          [7:0]   HEX2,
   output          [7:0]   HEX3,
   output          [7:0]   HEX4,
   output          [7:0]   HEX5,

   //////////// Accelerometer ports //////////
   output                  GSENSOR_CS_N,
   input           [2:1]   GSENSOR_INT,
   output                  GSENSOR_SCLK,
   inout                   GSENSOR_SDI,
   inout                   GSENSOR_SDO,
	
	input [1:0] KEY,
	
	output reg [15:0] data_out_x, data_out_y, data_out_z

		
   );

//===== Declarations
   localparam SPI_CLK_FREQ  = 200;  // Frecuencia del SPI (Hz)
   localparam UPDATE_FREQ   = 1;    // Frecuencia de muestreo (Hz)

   // Relojes y reset
   wire reset_n;
   wire clk, spi_clk, spi_clk_out;

   // Datos de salida
   wire data_update;
   wire [15:0] data_x, data_y, data_z;

   //===== Instanciación del PLL (copiado desde el IP Catalog de Quartus)
   PLL ip_inst (
      .inclk0 ( MAX10_CLK1_50 ),
      .c0 ( clk ),                 // 25 MHz, fase 0 grados
      .c1 ( spi_clk ),             // 2 MHz, fase 0 grados
      .c2 ( spi_clk_out )          // 2 MHz, fase 270 grados
      );

   //===== Instanciación del módulo spi_control para la comunicación con el acelerómetro
   spi_control spi_ctrl (
         .reset_n    (reset_n),
         .clk        (clk),
         .spi_clk    (spi_clk),
         .spi_clk_out(spi_clk_out),
         .data_update(data_update),
         .data_x     (data_x),
         .data_y     (data_y),
         .data_z     (data_z),
         .SPI_SDI    (GSENSOR_SDI),
         .SPI_SDO    (GSENSOR_SDO),
         .SPI_CSN    (GSENSOR_CS_N),
         .SPI_CLK    (GSENSOR_SCLK),
         .interrupt  (GSENSOR_INT)
      );

   // KEY0 se utiliza para congelar la salida del acelerómetro
   assign reset_n = KEY[0];
   wire rst_n = !reset_n;

   //===== Divisor de reloj para refrescar la visualización a 1 Hz (más lento)
   wire clk_1_hz;
   clock_divider #(.FREQ(1)) DIVISOR_REFRESH (
      .clk(MAX10_CLK1_50),
      .rst(rst_n),
      .clk_div(clk_1_hz)
   );

   //===========================================================================
 // Parte relevante del módulo accel modificado para mostrar valores de 0 a 18
//===========================================================================

   // Registro de los datos de los 3 ejes (se actualizan a 1 Hz)
   reg [15:0] data_x_reg, data_y_reg, data_z_reg;
   always @(posedge clk_1_hz) begin
      data_x_reg <= data_x;
      data_y_reg <= data_y;
      data_z_reg <= data_z;
   end

   // Convertir a valor absoluto (complemento a 2 para negativos)
   wire [15:0] abs_data_x = (data_x_reg[15]) ? (~data_x_reg + 1) : data_x_reg;
   wire [15:0] abs_data_y = (data_y_reg[15]) ? (~data_y_reg + 1) : data_y_reg;
   wire [15:0] abs_data_z = (data_z_reg[15]) ? (~data_z_reg + 1) : data_z_reg;

   // Escalar el valor dividiendo por 10 (de 0 a 180 pasa a 0 a 18)
   wire [7:0] scaled_x = abs_data_x / 10;
   wire [7:0] scaled_y = abs_data_y / 10;
   wire [7:0] scaled_z = abs_data_z / 10;

	
	always @(*)
	 begin
		data_out_x = scaled_x;
		data_out_y = scaled_y;
		data_out_z = scaled_z;
	 end
   // Extraer dígitos decenas y unidades para cada eje
   wire [3:0] tens_x = scaled_x / 10;
   wire [3:0] ones_x = scaled_x % 10;

   wire [3:0] tens_y = scaled_y / 10;
   wire [3:0] ones_y = scaled_y % 10;

   wire [3:0] tens_z = scaled_z / 10;
   wire [3:0] ones_z = scaled_z % 10;

   // Instanciación de los módulos seg7 para cada dígito:
   // Se asignan 2 displays por eje:
   // - HEX0 y HEX1 para X
   // - HEX2 y HEX3 para Y
   // - HEX4 y HEX5 para Z
   seg7 seg0 (
      .in      (tens_x),
      .display (HEX0)
   );

   seg7 seg1 (
      .in      (ones_x),
      .display (HEX1)
   );

   seg7 seg2 (
      .in      (tens_y),
      .display (HEX2)
   );

   seg7 seg3 (
      .in      (ones_y),
      .display (HEX3)
   );

   seg7 seg4 (
      .in      (tens_z),
      .display (HEX4)
   );

   seg7 seg5 (
      .in      (ones_z),
      .display (HEX5)
   );

   // (Opcional) Puedes seguir usando LEDR para otra visualización
   assign LEDR = data_z_reg[9:0];
endmodule