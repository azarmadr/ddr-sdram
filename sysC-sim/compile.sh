clear
verilator -f verilator.cmd
verilator --sc -Wno-fatal ../micron/MT48LC1M16A1.V
#verilator --sc +1364-2005ext+V --bbox-unsup ../micron/MT46V4M16.V
