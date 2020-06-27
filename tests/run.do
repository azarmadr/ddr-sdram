vlog ../micron/*.V   
vlog +define+t1 +define+debug +define+mod1 +define+DUMPVCD +incdir+./Testcases +incdir+../rtl *.v
vsim -novopt TOP_TB
run -all
