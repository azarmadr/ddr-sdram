

//========================define.v====================================//

`define T_RCD 2   //ras to cas delay, for -8 SDRAM, we need 3 clock cycles for t_rcd

`define SDC_ADDR_MSB           11
`define SDC_DATA_MSB           31//15	 
`define SYS_ADDR_MSB           22	 
`define SYS_DATA_MSB           15
`define U_ADDR_MSB             22	//  23 bits  ba(2)+ row(12)+ col(9)
`define U_DATA_MSB             31	 
`define ROW_ADDR_MSB           12
`define COL_ADDR_MSB            9		 
`define ENABLE_MSB             15


//.........Controller Command  i/ps...

 `define C_LOAD_MR              3'b000
 `define C_AUTO_REFRESH         3'b001
 `define C_PRECHARGE            3'b010
 `define C_ACT_ROW             	3'b011
 `define C_WRITEA             	3'b100
 `define C_READA              	3'b101
 `define C_BURST_STOP         	3'b110
 `define C_NOP                	3'b111

 `define BANK0                	2'b00
 `define BANK1                	2'b01
 `define BANK2                	2'b10
 `define BANK3                	2'b11
							     //			        for 100Mhz sdc_clk
 `define DLY4SDR				16'h0020 //16'H2710 //Initial delay B4 any command -100uS/10nS = 10,000 = 2710h
 `define DLY4DDR				16'h0030 //16'H4E20 // --------"------------------ -200uS/10nS = 20.000 = 4E20h
