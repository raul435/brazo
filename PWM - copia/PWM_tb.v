module PWM_tb;

    // Declaración de señales de entrada y salida
    reg pb_inc, pb_dec, clk, rst, enable;
    wire pwm_out;

    // Instancia del módulo PWM (unidad bajo prueba)
    PWM_servo DUT(
        .pb_inc(pb_inc),
        .pb_dec(pb_dec),
        .clk(clk),
        .rst(rst),
		  .enable(enable),
        .pwm_out(pwm_out)
    );

    // Generación del reloj principal (simulamos 50 MHz: período = 20 ns)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Bloque para simular la secuencia de prueba
    initial begin
        // Inicialización: ambos botones en reposo (nivel alto) y reset activado
        pb_inc = 1;
        pb_dec = 1;
        rst    = 1;
        #100;          // Espera 100 ns
        rst    = 0;   // Libera el reset

        // Espera para estabilizar el sistema
        #1000;

        // Simula pulsación del botón de incremento (pb_inc)
        // Debido a que se invierte la señal internamente, un pulso consiste en
        // bajar la señal (0) durante un breve período y luego volverla a 1.
        pb_inc = 0;
        #40;         // Mantiene la pulsación por 40 ns (ajustable según el debouncer)
        pb_inc = 1;

        // Espera antes de la siguiente pulsación
        #2000;

        // Simula pulsación del botón de decremento (pb_dec)
        pb_dec = 0;
        #40;
        pb_dec = 1;

        // Se pueden repetir las pulsaciones para probar distintos escenarios:
        #2000;
        pb_inc = 0;
        #40;
        pb_inc = 1;

        #2000;
        pb_dec = 0;
        #40;
        pb_dec = 1;

        // Finaliza la simulación después de un tiempo
        #5000;
        $finish;
    end

endmodule
