/////////////////////////////////////////////////////////////////////////////
//     									   //
//  Copyright(c) 2002 iPlay Networks P. Ltd.All Rights Reserved. 	   //
//  This document contain information which is both confidential and 	   //
//  proprietary to  iPlay Networks P. Ltd.	               		   //
//                  Himayat Nagar Hyderabad. India.  011-91-40-4076669     //
//     									   //
/////////////////////////////////////////////////////////////////////////////
// Filename: data_path.v                                                   //
//		  							   //
// Author: Saji Sebastian              				           //
//     									   //
// Description : Data Path Module       		                   //
// Rev1.4     : 19 August 2002    				           //	
//	        			                                   //
/////////////////////////////////////////////////////////////////////////////
`include "define.v"
module data_path (
   u_data_o, sdc_dqs, u_data_valid, Dwrite_en,// Outputs

   sdc_dq,// Inouts

   clk2x, clk,rst2,u_data_i,// Inputs
   cas_lat_max,sdc_write, sdc_read,cas_lat_half,// Inputs
   sdc_sel,burst_2,burst_4,burst_8,burst_p,rdAdr,// Inputs
   req_len,OvfSet

);

   output [`U_DATA_MSB:0]    	u_data_o;	              	// data o/p to host
   output 		     	u_data_valid,            	// data valid o/p to host
					Dwrite_en;					// for wr_nxt for ddr
   inout 	 	     	sdc_dqs;                 	// dqs signal for ddram
   inout [`SDC_DATA_MSB:0]   	sdc_dq;                  	// bidirectional data bus

   input [`U_DATA_MSB:0]     	u_data_i;                	// data i/p from host

   input	             	sdc_write;	      		// write enable i/p	
   input 		     	sdc_sel;		      	// select sdr/ddr i/p	
   input                     	sdc_read;	      		// read enable i/p	
   input 		     	clk2x, 		      		// clk x 2 i/p	
			     	clk,		      		// clk i/p
					rst2;
   input [1:0]		     	cas_lat_max,	      		// cas latency count i/p	
			     	cas_lat_half;	      		// cas i/p for .5
   input 		     	burst_2,		      	// burst length 2	
			     	burst_4,		      	// burst length 4	
			     	burst_8,		      	// burst length 8
 			     	burst_p,                 	// burst full page
				rdAdr,
				OvfSet;
   input [1:0] 			req_len;

   wire [`U_DATA_MSB:0]      	u_data_i;
   wire                      	sdc_write,
			     	sdc_read;
   wire 	             	sdc_sel,OvfSet;

   wire 		     	clk2x, clk,rst2;	
   wire [1:0]		     	cas_lat_max,cas_lat_half;
   wire 		     	burst_2,burst_4,burst_8,burst_p;
   wire 		     	rdAdr;
   wire	[1:0] 				req_len;
   wire  [`SDC_DATA_MSB:0]   	sdc_dq,sdc_dq_i_wire,sdc_dq_i;
   wire   	    	     	sdc_dqs;
   reg  [`U_DATA_MSB:0]      	u_data_o2,u_data_oC25,u_data_oC32,u_data_o;
   wire [`U_DATA_MSB:0]      	u_data_o1;

   reg [`SDC_DATA_MSB:0]    	data_lsb,data_msb,sdc_dq_o;
   reg [`U_DATA_MSB:0]      	read_data;
   reg 				sdc_read_en,sdc_read_en2,sdc_read_en1,sdc_read_en0,
				sdc_read_en15,sdc_read_en25,sdc_read_en3,sdc_read_en35,sdc_read_en4,
				sdc_write_en,sdc_write_en2,sdc_write_en25,sdc_write_en1,sdc_write_en0;
   wire [`U_DATA_MSB:0]      	write_data;
   wire [`SDC_DATA_MSB:0]	rd_lsb;
   wire 			u_data_valid;
	
   wire [`U_DATA_MSB:0]		rd_sd;//,u_data_o;
   wire [`SDC_DATA_MSB:0]	sdc_dq_t;
   wire	 			sdc_dqs_i,sdc_dqs_o;
   wire 			cas3,cas25,cas2;

   reg 				Dread_en0,Dread_en1,Dread_en2,Dread_en3,rdAdr1,rdAdr15,rdAdr2,
				rdAdr3,rdAdr4,rdAdr5,rdAdr6,OvfSet1,OvfSetD,OvfSetD1;
   reg 				sdc_dqsT;
   reg [1:0]			req_len1,req_len2,req_len3;

   wire [31:0]TDAT /* verilator split_var */ ;
   assign TDAT = ((cas3|cas2)&clk) ? read_data :	(cas25&&~clk&&clk2x&1)  ? read_data : TDAT ;

   wire Dwrite_en	= (burst_4) ? ((OvfSet)  ? (sdc_write_en|sdc_write_en1): sdc_write_en):
			  (burst_2) ?  sdc_write_en1 :
			  (OvfSet)  ? sdc_write_en2 & sdc_write_en25 //ext wr_en when ovf
						: sdc_write_en2 & sdc_write_en;

// generate read_en for reading from ddram


wire Dread_en = (cas3 ) ? (sdc_read_en25) :
		(cas2) ? (sdc_read_en2)  : sdc_read_en25	 ;
//---------------------------------------------------------//

//!! to avoid rd_valid mismatch
wire req0 = (req_len3==2'b00);
wire req1 = (req_len3==2'b01);
wire req2 = (req_len3==2'b10);
wire req3 = (req_len3==2'b11);

wire c3bl2 = (sdc_read_en4)? ((OvfSetD&!req0)? (sdc_read_en0&(sdc_read_en0^sdc_read_en))|
								 (sdc_read_en3&(sdc_read_en2^sdc_read_en3)):
	     (!sdc_read_en2)? (sdc_read_en3^sdc_read_en4):
			      (!sdc_read_en0)? (sdc_read_en1^sdc_read_en0): rdAdr):1'b0;//c3bl2-t13

wire c3bl4 = (sdc_read_en4)? ((OvfSetD1&OvfSet)? (sdc_read_en3&(sdc_read_en1^sdc_read_en3)):
	     (rdAdr2|rdAdr1|rdAdr15)^((sdc_read_en2^sdc_read_en4)&sdc_read_en4))
				   : 1'b0;						//c3bl4-t12

wire c3bl8 = (OvfSetD&OvfSet)? (sdc_read_en3&(sdc_read_en^sdc_read_en3)) :
	     ((Dread_en3 && Dread_en1)&!(rdAdr2|rdAdr15|rdAdr1));//c3bl8-t11


wire c2bl2 = (sdc_read_en4)? ((OvfSetD&OvfSet1)? (sdc_read_en2&(sdc_read_en1^sdc_read_en2)) :
				  (!sdc_read_en1)? (sdc_read_en3^sdc_read_en2):
			      (!sdc_read_en)? (sdc_read_en^sdc_read_en0): rdAdr2):1'b0;//c2bl2-t16

wire c2bl4 = (sdc_read_en4)? ((OvfSetD1&OvfSet)? (sdc_read_en2&(sdc_read_en0^sdc_read_en2)) :
		(rdAdr|rdAdr1)^((sdc_read_en1^sdc_read_en3)&sdc_read_en3))
				   : 1'b0;						//c2bl4-t15

wire c2bl8 = (OvfSet)? (sdc_read_en2&sdc_read_en4) :
		       ((sdc_read_en3 && sdc_read_en4)&!(rdAdr|rdAdr1));//c25bl8+c2bl8 = t14/t17

wire burst_1 = (~burst_2 && ~burst_4 && ~burst_8 && ~burst_p);
wire req0bl1 = (req_len3==2'b00 & burst_1);
//----------------------------------------------------------//
wire c3bl1R0 = (req0bl1) ? ((sdc_read_en4&&sdc_read_en3)?  rdAdr2 :1'b0):1'b0;//en0->en3

wire Drd_valid =
   //(OvfSet&|req_len)  ? ((sdc_read_en^sdc_read_en3)&sdc_read_en3)://Dread_en0 & Dread_en3 :
   (cas3 && burst_2) ?	c3bl2 :
   (cas3 && burst_4) ? c3bl4 :
   (cas3 && burst_8) ? c3bl8 :
   ((cas25||cas2) && burst_2) ? c2bl2 :
   ((cas25||cas2) && burst_4) ? c2bl4 :
   ((cas25||cas2) && burst_8) ? c2bl8 : 1'b0;


wire Sc3bl2Of  = (!sdc_read_en)? (sdc_read_en0^sdc_read_en2)&sdc_read_en2 : 1'b0;//!!
wire Sc3bl1Of  = (!req0&OvfSetD1) ? ((!sdc_read_en2)? (sdc_read_en3^sdc_read_en4)&sdc_read_en4 :
		 (!sdc_read_en)? (sdc_read_en0^sdc_read_en1)&sdc_read_en1 :	1'b0) :1'b0;

wire ChkOvf    = (req1) ? OvfSetD1 :(OvfSetD&OvfSet);

wire Sc2bl4    =  (OvfSet)? (sdc_read_en2&(sdc_read_en25& !rdAdr1)):(sdc_read_en25& !rdAdr1);
wire Sc2bl2    =  (OvfSet)? (sdc_read_en1&(sdc_read_en2&sdc_read_en25&!(rdAdr1|rdAdr2|rdAdr15))):
			                      (sdc_read_en2&sdc_read_en25&!(rdAdr1|rdAdr2|rdAdr15));		

wire Srd_valid = (req_len3===2'b00&burst_8) ? Dread_en0 :
		 (cas2&burst_8) ? (sdc_read_en3 & !rdAdr6) :
		 (cas2&burst_4) ? (Sc2bl4) :
		 (cas2&burst_2) ? (Sc2bl2) :
		 (cas2&burst_1) ? (sdc_read_en3&rdAdr4) :
		 (cas3&burst_2) ? ((OvfSet&!req1&!req0) ? Sc3bl2Of ://!!
				  (sdc_read_en4)?(rdAdr|rdAdr1)^((sdc_read_en1^sdc_read_en25)&sdc_read_en25):1'b0):
		 (cas3&burst_1) ? ((ChkOvf) ? Sc3bl1Of :(req0bl1)? (c3bl1R0):
				  ((sdc_read_en4)?((!sdc_read_en0)? (sdc_read_en25^sdc_read_en2): rdAdr2):1'b0)):
		 (req0bl1)      ?  (1'b0) :	
		 (burst_p)      ? Dread_en0 :
		 (OvfSet&sdc_sel)? Dread_en0 :	(Dread_en1|Dread_en0);

// generate burst1



// generate read_en for reading from sdram
   wire Sread_en =
	(cas_lat_max == 2'b10 ) ? (sdc_read_en2|sdc_read_en3):
	(cas_lat_max == 2'b01 ) ? (sdc_read_en15|sdc_read_en2): 1'b0;

   wire read_en = (sdc_sel) ? Sread_en : Dread_en;
//   assign u_data_o = (sdc_sel) ? u_data_o2 : u_data_o1;

// generate write_en for reading from sdram
   wire Swrite_en =   sdc_write;
   wire IntClk = (sdc_sel) ? clk : clk2x;

 wire dqsEn = (burst_4) ? ((OvfSet)  ? (!sdc_sel&(sdc_write_en|sdc_write_en2)):
							   (~sdc_sel & sdc_write_en & sdc_write_en0)):
	      (burst_2) ? (!sdc_sel & sdc_write_en1) :
              (OvfSet)  ? (!sdc_sel & sdc_write_en25) ://ext dqs when ovf
				  (!sdc_sel & sdc_write_en25 & sdc_write_en0);

// generating cas latency signals
   assign cas3  = (cas_lat_max == 2'b10 && ~cas_lat_half[1]);
   assign cas25 = (cas_lat_max == 2'b01 &&  cas_lat_half[1]);
   assign cas2  = (cas_lat_max == 2'b01 && ~cas_lat_half[1]);

// io-buffer for dqs
  IOBUF_SSTL2_II sdc_dqs0 (.I(sdc_dqs_i), .IO(sdc_dqs), .O(sdc_dqs_o),
			   .T(~sdc_sel && (sdc_read_en == 1'b1)));    // O = T ? IO : 1'bz; 	
                                                       		      // IO = I;

   assign sdc_dqs_i = sdc_dqsT;     // generate dqs
   assign rd_sd     = sdc_dq_i;
   assign sdc_dq_t  = (read_en == 1'b1)   ? {(`SDC_DATA_MSB +1){read_en}} : {(`SDC_DATA_MSB +1){1'b0}};

   //delay input data for 1clk cycle
 always @(posedge clk)
   begin
	sdc_read_en		<= sdc_read;
	sdc_write_en 	<= sdc_write;
	sdc_read_en0 	<= sdc_read_en;
	sdc_read_en1 	<= sdc_read_en0;
	sdc_read_en2 	<= sdc_read_en1;
	sdc_read_en3 	<= sdc_read_en2;
	sdc_read_en4 	<= sdc_read_en3;

	sdc_write_en2	<= sdc_write_en1;

	Dread_en0 	<= Dread_en;
	Dread_en1 	<= Dread_en0;
	Dread_en3 	<= Dread_en2;
	rdAdr1		<= rdAdr;
	rdAdr2		<= rdAdr1;
	rdAdr3		<= rdAdr2;
	rdAdr4		<= rdAdr3;
	rdAdr5		<= rdAdr4;
	rdAdr6		<= rdAdr5;
	req_len1     <= req_len;
	req_len2     <= req_len1;
	req_len3     <= req_len2;

	u_data_oC32 <= read_data;
	u_data_o = (sdc_sel) ? u_data_o2 : u_data_o1;
	OvfSet1		<=  OvfSet;
	OvfSetD		<=	OvfSet1;
	OvfSetD1    <=  OvfSetD;
  end
 assign  write_data  = u_data_i;

 always @(posedge IntClk)
 begin
        sdc_write_en0	<= sdc_write_en;
	sdc_write_en1	<= sdc_write_en0;
	data_lsb     	<= (sdc_sel) ? write_data[`SDC_DATA_MSB:0] : {16'h0,write_data[`SDC_DATA_MSB:`SYS_DATA_MSB+1]};
	data_msb     	<= (sdc_sel) ? write_data[`SDC_DATA_MSB:0] : {16'h0,write_data[`SYS_DATA_MSB:0]};

   end
 always @(negedge clk2x)//neg
  begin
   if(sdc_sel)
 	read_data	<= rd_lsb;	
   else
   begin	
	read_data[`SYS_DATA_MSB:0] <= rd_lsb[`SYS_DATA_MSB:0];//!!	
	read_data[`SDC_DATA_MSB:`SYS_DATA_MSB+1] <= read_data[`SYS_DATA_MSB:0];

   end	
	sdc_write_en25  <= sdc_write_en2;
        sdc_read_en15   <= sdc_read_en1;
	sdc_dqsT 	= dqsEn ? ~clk : 1'bz;
  end
								// dqs en diff bl4 & bl2
//dqsEn drives dqs signal for writing data

 always @(posedge IntClk)
   begin
        if(!rst2)
         begin
 	          	sdc_dq_o  = {(`SDC_DATA_MSB +1){1'b0}};
			u_data_o2 = {(`U_DATA_MSB +1){1'b0}};
	 end
        else
        if(sdc_sel)							//.....SDRAM
         begin
		if(Sread_en)
		     u_data_o2 = rd_sd;
		else
             	if(Swrite_en)
	             sdc_dq_o = write_data;//_msb;
		else
		begin
	           	sdc_dq_o  = {(`SDC_DATA_MSB +1){1'bz}};
			u_data_o2 = {(`U_DATA_MSB +1){1'bz}};
		end
         end
        else										//---DDRAM
         begin
		if(Dwrite_en & ~clk)//~
	      		sdc_dq_o  = data_msb;
		else
		if(Dwrite_en & 	clk)//~~
 	      		sdc_dq_o  = data_lsb;
		else
		if(!sdc_write_en)
	      		sdc_dq_o  = {(`SDC_DATA_MSB +1){1'bz}};
   	 end
       sdc_read_en25   <= sdc_read_en2;

   end

 always @(negedge clk)
         begin	sdc_read_en35<=sdc_read_en3;
		Dread_en2 	<= Dread_en1;
		u_data_oC25 <= read_data;
	rdAdr15		<= rdAdr1;
 	 end

assign u_data_o1 = (cas3|cas2) ? u_data_oC32 :u_data_oC25;


//Dwrite_en enables data write to dq

   assign rd_lsb = sdc_dq_i;
   assign u_data_valid  = (sdc_sel) ? Srd_valid : Drd_valid;
   assign sdc_dq_i = sdc_dq_i_wire;

//dq_i = o/p
//dq_o = i/p
//dq_t - i/p - need to be high for reading data from the dq -i/o- bus on to dq_i

  sdc_dq_io_64 sdc_dq_io (.sdc_dq_i(sdc_dq_i_wire), .sdc_dq(sdc_dq), .sdc_dq_o(sdc_dq_o), .sdc_dq_t(sdc_dq_t));


endmodule
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//

