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
   output [2:0] GPIO
	);

wire [15:0] data_out_x, data_out_y, data_out_z;

//accel ac1(
//   .MAX10_CLK1_50(MAX10_CLK1_50),
//   .HEX0(HEX0),
//   .HEX1(HEX1),
//   .HEX2(HEX2),
//   .HEX3(HEX3),
//   .HEX4(HEX4),
//   .HEX5(HEX5),
//   .GSENSOR_CS_N(GSENSOR_CS_N),
//   .GSENSOR_INT(GSENSOR_INT),
//   .GSENSOR_SCLK(GSENSOR_SCLK),
//   .GSENSOR_SDI(GSENSOR_SDI),
//   .GSENSOR_SDO(GSENSOR_SDO),
//	.KEY(KEY),
//   .data_out_x(data_out_x),
//   .data_out_y(data_out_y),
//   .data_out_z(data_out_z)
//   );

PWM pwm1(
   .clk(MAX10_CLK1_50),
   .en(SW[0]),
   .data(rom_data_x/3),
   .pwm_out(GPIO[0])
   );

PWM pwm2(
   .clk(MAX10_CLK1_50),
   .en(SW[0]),
   .data(rom_data_y/3),
   .pwm_out(GPIO[1])
   );

PWM pwm3(
   .clk(MAX10_CLK1_50),
   .en(SW[0]),
   .data(rom_data_z/3),
   .pwm_out(GPIO[2])
   );
	
ROM2 #(.DATA_WIDTH(8), .ADDRESS_WIDTH(8), .HEX_FILE("servo1.hex")) rom_x (
        .ce(1'b1),
        .read_en(1'b1),
        .address(rom_address),
        .data(rom_data_x)
    );
ROM2 #(.DATA_WIDTH(8), .ADDRESS_WIDTH(8), .HEX_FILE("servo2.hex")) rom_y (
        .ce(1'b1),
        .read_en(1'b1),
        .address(rom_address),
        .data(rom_data_y)
    );
ROM2 #(.DATA_WIDTH(8), .ADDRESS_WIDTH(8), .HEX_FILE("servo3.hex")) rom_z (
        .ce(1'b1),
        .read_en(1'b1),
        .address(rom_address),
        .data(rom_data_z)
    );


endmodule