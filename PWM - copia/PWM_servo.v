module PWM_servo (
   input wire clk, 
	input rst,
   input wire enable,
   input wire pb_inc,    // Botón para incrementar
   input wire pb_dec,  // Botón para decrementar
   output reg pwm_out
);

// Parámetros para la señal PWM para servo
parameter frecuencia = 1_000_000;     // 20 ms (50 MHz)
parameter pulso_min = 25_000;     // Pulso mínimo
parameter pulso_max = 125_000;    // Pulso máximo
parameter pulso_manual = 5;      // Incremento/decremento en DC


wire debounced_pb_inc;
wire debounced_pb_dec;
wire slow_clk;


debouncer2 d1(
	.clk(clk),
   .rst(0),
   .pb_1(pb_inc),
   .pb_out(debounced_pb_inc)
    );

debouncer2 d2 (
   .clk(clk),
   .rst(0),
   .pb_1(pb_dec),
   .pb_out(debounced_pb_dec)
    );


clkdiv clock_divider_inst (
   .clk(clk),
   .rst(0),
   .clk_div(slow_clk)
    );

//Registro de Duty Cycle
reg [10:0] DC = 25;
reg [19:0] pulse_width = pulso_min;
reg [19:0] counter = 0;

    // Registros para detectar flanco de bajada en los botones
reg btn_up_last = 1;
reg btn_down_last = 1;

    // Control del duty cycle con slow_clk
    // Se actualiza solo cuando enable está activo
always @(posedge slow_clk) 
begin
if (enable) 
begin
   if (!debounced_pb_inc && btn_up_last)
	begin
      if (DC < 125)
			DC <= DC + pulso_manual;
   end

      //decrementar
	if (!debounced_pb_dec && btn_down_last)
		begin
			if (DC > 25)
				DC <= DC - pulso_manual;
		end
	end
   // Actualiza el estado anterior de los botones (siempre)
   btn_up_last <= debounced_pb_inc;
   btn_down_last <= debounced_pb_dec;
end

// Generación del PWM para el servo 
always @(posedge clk) 
begin
	if (!enable) 
	begin
		pwm_out <= 0;
		counter <= 0;
	end 
	else 
	begin
      // Calculo del ancho de pulso en función del duty_percent.
		pulse_width <= pulso_min + ((pulso_max - pulso_min) * (DC - 25)) / 100;
            
      //Señal PWM
      if (counter < pulse_width)
			pwm_out <= 1;
      else
         pwm_out <= 0;

      // Reinicia el contador al final del periodo
      if (counter >= frecuencia - 1)
			counter <= 0;
      else
			counter <= counter + 1;
   end
end

endmodule