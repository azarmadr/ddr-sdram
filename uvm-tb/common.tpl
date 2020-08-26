dut_top         = sdc_agent
dut_source_path = ../rtl
project         = ddr_sdram_controller
backup          = no
timeunit        = 1ns
timeprecision   = 100ps

th_generate_clock_and_reset = no
th_inc_inside_module        = th_time.sv inline
