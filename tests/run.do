vlog ../micron/*.V   
vlog  +incdir+./Testcases +incdir+../rtl *.v +define+t1+debug+DUMPVCD+#mod1
vsim -novopt TOP_TB
run -all
