/////////////////////////////////////////////////////////////////////////////
//     									   //
//  Copyright(c) 2002 iPlay Networks P. Ltd.All Rights Reserved. 	   //
//  This document contain information which is both confidential and 	   //
//  proprietary to  iPlay Networks P. Ltd.	               		   //
//                  Himayat Nagar Hyderabad. India.  011-91-40-4076669     //
//     									   //
/////////////////////////////////////////////////////////////////////////////
// Filename: SDC_TOP.v                                                     //        
//		  							   //
// Author: Saji Sebastian              				           //
//     									   //
// Description : sdr/ddr-sdram controller top level   			   //
// Rev1.4     : 19 August 2002    				           //	
//	        			                                   //
/////////////////////////////////////////////////////////////////////////////

module sdc_top(

   //====Interface to SDRAM=====

   // Outputs
		sdc_clk,sdc_ad, sdc_dm, sdc_ba, sdc_rasb, sdc_casb, sdc_web,  
  		sdc_csb, sdc_cke, 

   // Inouts
   		sdc_dq, sdc_dqs,

   //====Interface to Host=====	

   // Outputs
		sdr_req_ack,sdr_rd_valid,sdr_wr_next,sdr_rd_data,sdr_init_done,

   // Inputs
		mclk,s_resetn,sdr_req,sdr_req_adr,sdr_req_len,sdr_req_wr_n,sdr_wr_data,
		sdr_wr_en_n,sdr_en,sdr_mode_reg,sdr_tras_d,sdr_trp_d,sdr_trcd_d,sdr_cas,
		sdr_trca_d,sdr_twr_d,sdr_rfrsh,sdr_rfmax,sdr_sel

		);

   //====Interface to SDRAM=====

  output [`SDC_ADDR_MSB:0]	sdc_ad;           //  address o/p of controller
  output [3:0] 	    		sdc_dm;           //  data mask o/p of controller
  output [1:0] 	    		sdc_ba;           //  bank address o/p
  output 		    	sdc_rasb, 		
				sdc_casb,
				sdc_web;          //  command o/ps    
  output 		    	sdc_clk;          //  clk o/p for ram
  output 		    	sdc_csb, 	  //  chip select o/p of controller
				sdc_cke;	  //  clk enable o/p

  inout  [`SDC_DATA_MSB:0]	sdc_dq;           //  bi-directional data bus
  inout 	 	    	sdc_dqs;          //  bi-directional dqs signal for DDRAM

   //====Interface to Host=====	

  output			sdr_req_ack,      //  Acknowledge o/p to MC
				sdr_rd_valid,     //  rd valid o/p 
				sdr_wr_next;      //  signal for data for Nxt wr
  output [`U_DATA_MSB:0]       	sdr_rd_data;      //  read data o/p to mc
  output			sdr_init_done;    //  initialization done signal 

  input				mclk,		  //  master clk
				s_resetn,	  //  reset host
				sdr_req;	  //  request for next rd/wr operation	
  input [`U_ADDR_MSB:0] 
				sdr_req_adr;      //  rd/wr addr from mc
  input	[1:0]			sdr_req_len;      //  # of beats to wr/rd
  input				sdr_req_wr_n;     //  0 - write, 1 - read 

  input  [`U_DATA_MSB:0]	sdr_wr_data;      //  data in for write
  input  [3:0]			sdr_wr_en_n;      //  data mask 

  input				sdr_en;		  //  enable controller 	

  input  [`SDC_ADDR_MSB:0]	sdr_mode_reg;	  //  mod reg data	

  input  [3:0]			sdr_tras_d,	  //  Tras delay  in clock cycs for SDRAM	
				sdr_trp_d,        //  Trp delay
				sdr_trcd_d;       //  Trcd delay 
  input  [2:0]			sdr_cas;          //  Cas latency for SDRAM 

  input  [3:0]			sdr_trca_d,       //  Trca delay	
				sdr_twr_d;        //  Twr delay
  input  [11:0]			sdr_rfrsh;	  //  number of rows to refresh per burst
  input  [2:0]			sdr_rfmax;	  //  refresh time per row
  input 			sdr_sel;  	  //  select sdr/ddr-sdram 


  wire		mclk,
		s_resetn,
		sdr_req;
  wire [`U_ADDR_MSB:0] 
		sdr_req_adr;

  wire		sdr_req_wr_n;
  wire		sdr_req_ack;
  wire		sdr_rd_valid;
  wire [1:0]	sdr_req_len;  

  wire  [`U_DATA_MSB:0]
		sdr_wr_data;
  wire  [3:0]	sdr_wr_en_n;

  wire [`U_DATA_MSB:0]
         	sdr_rd_data;
  wire		sdr_init_done;
  wire		sdr_en;

  wire  [`SDC_ADDR_MSB:0]	
		sdr_mode_reg;

  wire  [3:0]	sdr_tras_d,
		sdr_trp_d,
		sdr_trcd_d;
  wire  [2:0]	sdr_cas;

  wire  [3:0]	sdr_trca_d,	
		sdr_twr_d;
  wire  [11:0]	sdr_rfrsh;
  wire  [2:0]	sdr_rfmax;
  wire 		sdr_sel;
   wire [`SDC_ADDR_MSB:0]
		sdc_ad;            
   wire [3:0] 	sdc_dm;           
   wire [1:0] 	sdc_ba;             
   wire 	sdc_rasb, 		
		sdc_casb,
		sdc_web;           
   wire 	sdc_clk;           
   wire 	sdc_csb, 	   
		sdc_cke;	   

   wire  [`SDC_DATA_MSB:0]
		sdc_dq;             
   wire	    	sdc_dqs;           

   wire		ref_set,wen,ren;
   wire		clk,clk2x,rst2;

   wire AdrCntSt; 

   wire [`U_ADDR_MSB:0]
	  	u_addr;
   wire [1:0]	bnkAdr;

   wire [1:0] 	cas_lat_max,
		cas_lat_half;
   wire 	burst_2,
		burst_4, 
		burst_8,
		burst_p,
		auto_prech;
   wire		StWrRd,u_data_valid;

   wire [`U_DATA_MSB:0]
		u_data_o;
   wire [8:0]	bl;

   wire		write_en,
		read_en,
		row_addr,
		mrs_addr,
	 	init_done,
		ref_set_in,
		sdr_wr_next,
		ref_end,
		StRef,
		trca_end,Mrow_addr,enAp,rdAdr,adrChg,AdrCntOvf,RowOvfOut,wr_next,Dwrite_en;
   wire  [2:0]	cmd_out;	

   wire		sdr_req_wr_nL,extMR,OvfSet;

//========================================================//

 assign sdc_clk 	= clk;
 assign sdc_dm    	= sdr_wr_en_n;

 assign sdc_cke     = sdr_en;
 assign sdc_csb     = sdr_sel;
 assign {sdc_rasb,sdc_casb,sdc_web} = cmd_out;    

 assign	sdr_rd_valid  = u_data_valid;
 assign	sdr_rd_data   = u_data_o;
 assign	sdr_init_done = init_done;
 assign AdrCntSt   = write_en | read_en;

 assign ref_set_in = ref_set;
 assign sdr_wr_next = (sdr_sel) ? wr_next : Dwrite_en;
//==========================================================================================//
// Refresh check module 

  ref_chk refresh( 

   // Outputs
		.ref_set(ref_set),.ref_end(ref_end),.wen(wen),.ren(ren),.clk(clk),.clk2x(clk2x),.rst2(rst2),
		.sdr_req_wr_nL(sdr_req_wr_nL),

   // Inputs
		.mclk(mclk),.s_resetn(s_resetn),.trca_end(trca_end),.sdr_rfrsh(sdr_rfrsh),
		.sdr_rfmax(sdr_rfmax),.init_done(init_done),.sdr_req_wr_n(sdr_req_wr_n),
		.sdr_req(sdr_req),.StRef(StRef),.req_ack(sdr_req_ack)
		
		);

//==========================================================================================//
//Bank ontroller module
 
   sdc_bnkctlr BANKCTLR(

  //Outputs
			.write_en(write_en),.read_en(read_en),
			.Mrow_addr(Mrow_addr),.row_addr(row_addr),.mrs_addr(mrs_addr),.StWrRd(StWrRd),
			.cmd_out(cmd_out),.init_ed(init_done),.sdr_wr_next(wr_next),.trca_end(trca_end),
			.enAp(enAp),.req_ack(sdr_req_ack),.rdAdr(rdAdr),.blx(bl),.StRef(StRef),.extMR(extMR),
			.SLA(SLA),
   //Inputs
			.clk(clk),.clk2x(clk2x),.rst2(rst2),.ren(ren),.wen(wen),.ref_set(ref_set_in),
			.sdr_req(sdr_req),.sdr_en(sdr_en),.sdr_req_wr_n(sdr_req_wr_nL),.sdr_mode_reg(sdr_mode_reg),
			.sdr_tras_d(sdr_tras_d),.sdr_trp_d(sdr_trp_d),.sdr_trcd_d(sdr_trcd_d),.sdr_cas(sdr_cas),
			.sdr_trca_d(sdr_trca_d),.sdr_twr_d(sdr_twr_d),.adrChg(adrChg),.AdrCntOvf(AdrCntOvf),
			.auto_prech(auto_prech),.sdr_sel(sdr_sel),.bnkAdr(sdc_ba),.req_len(sdr_req_len),
			.RowOvfOut(RowOvfOut),.ref_end(ref_end)
	);

//==========================================================================================//
//Address latch module

  addr_latch addr_latch(

   // Outputs
			.sdc_ad(sdc_ad), .sdc_ba(sdc_ba),.cas_lat_max(cas_lat_max),.cas_lat_half(cas_lat_half),
			.burst_2(burst_2),.burst_4(burst_4), .burst_8(burst_8),.burst_p(burst_p),
			.auto_prech(auto_prech),.adrChg(adrChg),.AdrCntOvf(AdrCntOvf),.RowOvfOut(RowOvfOut),
			.OvFlSet(OvfSet),
   // Inputs			 
			.clk(clk),.clk2x(clk2x),.reset1(~rst2),.u_addr(sdr_req_adr),.mode_reg(sdr_mode_reg),
			.Mrow_addr(Mrow_addr),.row_addr(row_addr),.mrs_addr(mrs_addr),.StWrRd(StWrRd),
			.init_done(init_done),.AdrCntSt(AdrCntSt),.enAp(enAp),.rdAdr(rdAdr),.sdr_req(sdr_req),
			.sdr_req_wr_n(sdr_req_wr_nL),.sdc_sel(sdr_sel),.bl(bl),.req_ack(sdr_req_ack),.extMR(extMR),
			.SLA(SLA)
	);

//==========================================================================================//
//Data path module

   data_path data_path (

 	// Outputs
			.u_data_o(u_data_o), .sdc_dqs(sdc_dqs),.u_data_valid(u_data_valid),
			.Dwrite_en(Dwrite_en),
	// Inouts		
			.sdc_dq(sdc_dq),

	// Inputs		
			.clk2x(clk2x), .clk(clk),.rst2(rst2),.u_data_i(sdr_wr_data),
			.cas_lat_max(cas_lat_max),.sdc_write(write_en), .sdc_read(read_en),
			.cas_lat_half(cas_lat_half),.sdc_sel(sdr_sel),.burst_2(burst_2),
			.burst_4(burst_4), .burst_8(burst_8),.burst_p(burst_p),.rdAdr(rdAdr),
			.req_len(sdr_req_len),.OvfSet(OvfSet)
	);

//==========================================================================================//
    
endmodule
