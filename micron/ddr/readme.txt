Disclaimer of Warranty:
-----------------------
This software code and all associated documentation, comments or other 
information (collectively "Software") is provided "AS IS" without 
warranty of any kind. MICRON TECHNOLOGY, INC. ("MTI") EXPRESSLY 
DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
TO, NONINFRINGEMENT OF THIRD PARTY RIGHTS, AND ANY IMPLIED WARRANTIES 
OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. MTI DOES NOT 
WARRANT THAT THE SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE 
OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. 
FURTHERMORE, MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR 
THE RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS, 
ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT OF USE 
OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO EVENT SHALL MTI, 
ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE LIABLE FOR ANY DIRECT, 
INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR SPECIAL DAMAGES (INCLUDING, 
WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS, BUSINESS INTERRUPTION, 
OR LOSS OF INFORMATION) ARISING OUT OF YOUR USE OF OR INABILITY TO USE 
THE SOFTWARE, EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
DAMAGES. Because some jurisdictions prohibit the exclusion or 
limitation of liability for consequential or incidental damages, the 
above limitation may not apply to you.

Copyright 2003 Micron Technology, Inc. All rights reserved.

Getting Started:
----------------
Unzip the included files to a folder.
Compile ddr.v and tb.v using a verilog simulator.
Simulate the top level test bench tb.
Or, if you are using the ModelSim simulator, type "do tb.do" at the prompt.

File Descriptions:
------------------
ddr.v               -ddr component model 
ddr_dimm.v          -structural wrapper that instantiates ddr components
ddr_parameters.vh   -file that contains all parameters used by the model
readme.txt          -this file
tb.v                -component test bench
subtest.vh          -example test included by the test bench.
tb.do               -compiles and runs the component model and test bench

Defining the Speed Grade:
-------------------------
The verilog compiler directive "`define" may be used to choose between 
multiple speed grades supported by the ddr model.  Allowable speed 
grades are listed in the ddr_parameters.vh file and begin with the 
letters "sg".  The speed grade is used to select a set of timing 
parameters for the ddr model.  The following are examples of defining 
the speed grade.

    simulator   command line
    ---------   ------------
    ModelSim    vlog +define+sg5 ddr.v
    VCS         vcs +define+sg5 ddr.v
    NC-Verilog  ncverilog +define+sg5 ddr.v

Defining the Organization:
--------------------------
The verilog compiler directive "`define" may be used to choose between 
multiple organizations supported by the ddr model.  Valid 
organizations include "x4", "x8", "x16", and "x32", and are listed in the 
ddr_parameters.vh file.  The organization is used to select the amount 
of memory and the port sizes of the ddr model.  The following are
examples of defining the organization.

    simulator   command line
    ---------   ------------
    ModelSim    vlog +define+x8 ddr.v
    VCS         vcs +define+x8 ddr.v
    NC-Verilog  ncverilog +define+x8 ddr.v

All combinations of speed grade and organization are considered valid 
by the ddr model even though a Micron part may not exist for every 
combination.

Allocating Memory:
------------------
An associative array has been implemented to reduce the amount of 
static memory allocated by the DDR model.  The number of 
entries in the associative array is controlled by the part_mem_bits 
parameter, and is equal to 2^part_mem_bits.  For example, if the 
part_mem_bits parameter is equal to 10, the associative array will be 
large enough to store 1024 write data transfers to unique addresses.  
The following are examples of setting the part_mem_bits parameter to 8.

    simulator   command line
    ---------   ------------
    ModelSim    vsim -Gpart_mem_bits=8 ddr
    VCS         vcs -pvalue+part_mem_bits=8 ddr.v
    NC-Verilog  ncverilog +defparam+ddr.part_mem_bits=8 ddr.v

It is possible to allocate memory for every address supported by the 
ddr model by using the verilog compiler directive "`define FULL_MEM".
This procedure will improve simulation performance at the expense of 
system memory.  The following are examples of allocating memory for
every address.

    Simulator   command line
    ---------   ------------
    ModelSim    vlog +define+FULL_MEM ddr.v
    VCS         vcs +define+FULL_MEM ddr.v
    NC-Verilog  ncverilog +define+FULL_MEM ddr.v

Defining the Number of Ranks on a DIMM:
--------------------------------------
The verilog compiler directive "`define" may be used to choose between 
single rank and dual rank DIMM configurations.  The default is single 
rank if nothing is defined.  Dual rank configuration can be selected by 
defining "DUAL_RANK" when the ddr_dimm is compiled.  The following are 
examples of defining a dual rank DIMM configuration.

    simulator   command line
    ---------   ------------
    ModelSim    vlog +define+DUAL_RANK ddr_dimm.v
    VCS         vcs +define+DUAL_RANK ddr_dimm.v
    NC-Verilog  ncverilog +define+DUAL_RANK ddr_dimm.v


Defining the Buffering for a DIMM:
---------------------------------
The verilog compiler directive "`define" may be used to choose between 
registered and unregistered DIMM configurations.  The default is 
unregistered if nothing is defined.  Registered configuration can be 
selected by defining "RDIMM" when the ddr_dimm is compiled.  The 
following are examples of defining a registered DIMM configuration.

    simulator   command line
    ---------   ------------
    ModelSim    vlog +define+RDIMM ddr_dimm.v
    VCS         vcs +define+RDIMM ddr_dimm.v
    NC-Verilog  ncverilog +define+RDIMM ddr_dimm.v


Defining the ECC for a DIMM:
---------------------------
The verilog compiler directive "`define" may be used to choose between 
ECC and nonECC DIMM configurations.  The default is nonECC if nothing 
is defined.  ECC configuration can be selected by defining "ECC" when 
the ddr_dimm is compiled.  The following are examples of defining an
ECC DIMM configuration.

    simulator   command line
    ---------   ------------
    ModelSim    vlog +define+ECC ddr_dimm.v
    VCS         vcs +define+ECC ddr_dimm.v
    NC-Verilog  ncverilog +define+ECC ddr_dimm.v


All combinations of ranks, buffering, and ECC are considered valid by 
the ddr_dimm model even though a Micron part may not exist for every 
combination.
