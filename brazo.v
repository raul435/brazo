module brazo (
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
   input [9:0] SW,
   
   // Salidas VGA (asegúrate de tener los pines disponibles en tu placa)
   output         [3:0] VGA_R,
   output         [3:0] VGA_G,
   output         [3:0] VGA_B,
   output               VGA_HS,
   output               VGA_VS,
   
   output         [2:0] GPIO
   );

   // Señales que provienen del acelerómetro
   wire [15:0] data_acc_x, data_acc_y, data_acc_z;
	wire [15:0] data_out_x, data_out_y, data_out_z;

   // Instanciación del módulo acelerómetro
   accel ac1(
      .MAX10_CLK1_50(MAX10_CLK1_50),
      .HEX0(HEX0),
      .HEX1(HEX1),
      .HEX2(HEX2),
      .HEX3(HEX3),
      .HEX4(HEX4),
      .HEX5(HEX5),
      .GSENSOR_CS_N(GSENSOR_CS_N),
      .GSENSOR_INT(GSENSOR_INT),
      .GSENSOR_SCLK(GSENSOR_SCLK),
      .GSENSOR_SDI(GSENSOR_SDI),
      .GSENSOR_SDO(GSENSOR_SDO),
      .KEY(KEY),
      .data_out_x(data_acc_x),
      .data_out_y(data_acc_y),
      .data_out_z(data_acc_z)
   );

   // Instanciación del módulo VGA, conectando los datos del acelerómetro
   VGADemo vga1(
      .MAX10_CLK1_50(MAX10_CLK1_50),
      .data_x(data_out_x),
      .data_y(data_out_y),
      .data_z(data_out_z),
      .VGA_R(VGA_R),
      .VGA_G(VGA_G),
      .VGA_B(VGA_B),
      .VGA_HS(VGA_HS),
      .VGA_VS(VGA_VS)
   );

   // maquina de estados
   FSM fsm1(
      .clk(MAX10_CLK1_50),
      .rst(SW[0]),
      .enable(SW[1]),
      .btn_mem(SW[2]),
      .rom_data_x(rom_data_x),
      .rom_data_y(rom_data_y),
      .rom_data_z(rom_data_z),
      .data_accel_x(data_acc_x),
      .data_accel_y(data_acc_y),
      .data_accel_z(data_acc_z),
      .data_out_x(data_out_x),
      .data_out_y(data_out_y),
      .data_out_z(data_out_z),
   );
   
   // Instanciación de las ROM (sin cambios)
   ROM2 #(.DATA_WIDTH(8), .ADDRESS_WIDTH(8), .HEX_FILE("servo1.hex")) rom_x (
       .ce(1'b1),
       .read_en(1'b1),
       .address(SW[9:7]),
       .data(rom_data_x)
   );
   ROM2 #(.DATA_WIDTH(8), .ADDRESS_WIDTH(8), .HEX_FILE("servo2.hex")) rom_y (
       .ce(1'b1),
       .read_en(1'b1),
       .address(SW[9:7]),
       .data(rom_data_y)
   );
   ROM2 #(.DATA_WIDTH(8), .ADDRESS_WIDTH(8), .HEX_FILE("servo3.hex")) rom_z (
       .ce(1'b1),
       .read_en(1'b1),
       .address(SW[9:7]),
       .data(rom_data_z)
   );
	
	

	// Instanciación de los módulos PWM (sin cambios)
   PWM pwm1(
      .clk(MAX10_CLK1_50),
      .en(SW[0]),
      .data(data_out_x),
      .pwm_out(GPIO[0])
   );

   PWM3 pwm2(
      .clk(MAX10_CLK1_50),
      .en(SW[0]),
      .data(data_out_y),
      .pwm_out(GPIO[1])
   );

   PWM2 pwm3(
      .clk(MAX10_CLK1_50),
      .en(SW[0]),
      .data(data_out_z),
      .pwm_out(GPIO[2])
   );
	
endmodule
