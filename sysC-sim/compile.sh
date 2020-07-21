clear
verilator -f verilator.cmd
cd obj_dir
make -f Vsdc_agent.mk
make -f ../sc.mk all
cd ..
