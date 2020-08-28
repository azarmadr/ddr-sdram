dut_top         = sdc_agent
dut_source_path = ../rtl
project         = ddr_sdram_controller
backup          = no
timeunit        = 1ns
timeprecision   = 100ps

th_generate_clock_and_reset = no
th_inc_inside_module        = th_time.sv inline

test_inc_inside_class = test_run_drain_t.sv   inline
top_seq_inc=vseq_sdr.sv inline
top_default_seq_count=1
top_factory_set       = top_default_seq top_fmt_seq
