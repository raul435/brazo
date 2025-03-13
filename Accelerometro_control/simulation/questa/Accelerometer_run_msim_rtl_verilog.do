transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/joser/Documents/GitHub/brazo/Accelerometro_control {C:/Users/joser/Documents/GitHub/brazo/Accelerometro_control/decoder_7_seg.v}
vlog -vlog01compat -work work +incdir+C:/Users/joser/Documents/GitHub/brazo/Accelerometro_control {C:/Users/joser/Documents/GitHub/brazo/Accelerometro_control/clkdiv.v}
vlog -vlog01compat -work work +incdir+C:/Users/joser/Documents/GitHub/brazo/Accelerometro_control/hdl {C:/Users/joser/Documents/GitHub/brazo/Accelerometro_control/hdl/spi_serdes.v}
vlog -vlog01compat -work work +incdir+C:/Users/joser/Documents/GitHub/brazo/Accelerometro_control/hdl {C:/Users/joser/Documents/GitHub/brazo/Accelerometro_control/hdl/spi_control.v}
vlog -vlog01compat -work work +incdir+C:/Users/joser/Documents/GitHub/brazo/Accelerometro_control {C:/Users/joser/Documents/GitHub/brazo/Accelerometro_control/accel.v}
vlog -vlog01compat -work work +incdir+C:/Users/joser/Documents/GitHub/brazo/Accelerometro_control {C:/Users/joser/Documents/GitHub/brazo/Accelerometro_control/PLL.v}
vlog -vlog01compat -work work +incdir+C:/Users/joser/Documents/GitHub/brazo/Accelerometro_control/db {C:/Users/joser/Documents/GitHub/brazo/Accelerometro_control/db/pll_altpll.v}

vlog -vlog01compat -work work +incdir+C:/Users/joser/Documents/GitHub/brazo/Accelerometro_control {C:/Users/joser/Documents/GitHub/brazo/Accelerometro_control/accel_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  accel_tb

add wave *
view structure
view signals
run -all
