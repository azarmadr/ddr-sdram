/////////////////////////////////////////////////////////////////////////////
//     									   //
//  Copyright(c) 2002 iPlay Networks P. Ltd.All Rights Reserved. 	   //
//  This document contain information which is both confidential and 	   //
//  proprietary to  iPlay Networks P. Ltd.	               		   //
//                  Himayat Nagar Hyderabad. India.  011-91-40-4076669     //
//     									   //
/////////////////////////////////////////////////////////////////////////////
// Filename: TOP_TB.v                                                      //        
//		  							   //
// Author: Saji Sebastian              				           //
//     									   //
// Description : Top Test Bench File     		                   //
// History     :  29-JULY- 2002  Rev1.3 			           //	
//	        			                                   //
/////////////////////////////////////////////////////////////////////////////

module TOP_TB;


//(1Meg x 16 x 4 Banks)DDR	//......DDR SDRAM


 mt46v4m16 
	   	ddram(.Dq(sdc_dq[15:0]), .Dqs(sdc_dqs), .Addr(sdc_ad),		
		      .Ba(sdc_ba), .Clk(sdc_clk), .Clk_n(~sdc_clk),
		      .Cke(sdc_cke), .Cs_n(sdc_csb), .Ras_n(sdc_rasb),
		      .Cas_n(sdc_casb), .We_n(sdc_web), .Dm(sdc_dm[1:0]));

		   
//(2Meg x 16 x 4 Banks)		 //.......SDR SDRAM -1-


 mt48lc8m16a2 
	       sdram0( .Dq(sdc_dq[15:0]), .Addr(sdc_ad), .Ba(sdc_ba), .Clk(sdc_clk), 
		      .Cke(sdc_cke), .Cs_n(~sdc_csb), .Ras_n(sdc_rasb),
		      .Cas_n(sdc_casb), .We_n(sdc_web), .Dqm(sdc_dm[1:0]));


//(2Meg x 16 x 4 Banks)		 //.......SDR SDRAM -2-


 mt48lc8m16a2 
	       sdram1( .Dq(sdc_dq[31:16]), .Addr(sdc_ad), .Ba(sdc_ba), .Clk(sdc_clk), 
		      .Cke(sdc_cke), .Cs_n(~sdc_csb), .Ras_n(sdc_rasb),
		      .Cas_n(sdc_casb), .We_n(sdc_web), .Dqm(sdc_dm[3:2]));


 sdc_top CTLR_TOP(

   //====Interface to SDRAM=====

   // Outputs
		.sdc_clk(sdc_clk),.sdc_ad(sdc_ad),.sdc_dm(sdc_dm),.sdc_ba(sdc_ba),
		.sdc_rasb(sdc_rasb),.sdc_casb(sdc_casb),.sdc_web(sdc_web),.sdc_csb(sdc_csb),
		.sdc_cke(sdc_cke), 

   // Inouts
   		.sdc_dq(sdc_dq),.sdc_dqs(sdc_dqs),

   //====Interface to Host=====	

   // Outputs
		.sdr_req_ack(sdc_req_ack),.sdr_rd_valid(sdc_rd_valid),.sdr_wr_next(sdc_wr_next),
		.sdr_rd_data(sdc_rd_data),.sdr_init_done(sdc_init_done),

   // Inputs
		.mclk(mclk),.s_resetn(s_resetn),.sdr_req(sdc_req),.sdr_req_adr(sdc_req_adr),
		.sdr_req_len(sdc_req_len),.sdr_req_wr_n(sdc_req_wr_n),.sdr_wr_data(sdc_wr_data),
		.sdr_wr_en_n(sdc_wr_en_n),.sdr_en(sdc_en),.sdr_mode_reg(sdc_mode_reg),.sdr_tras_d(sdc_tras_d),
		.sdr_trp_d(sdc_trp_d),.sdr_trcd_d(sdc_trcd_d),.sdr_cas(sdc_cas),.sdr_trca_d(sdc_trca_d),
		.sdr_twr_d(sdc_twr_d),.sdr_rfrsh(sdc_rfrsh),.sdr_rfmax(sdc_rfmax),.sdr_sel(sdc_sel)

		);


 sdc_agent agent(

   //.....outputs......
  		 mclk,s_resetn,sdc_req,sdc_req_adr,sdc_req_len,sdc_req_wr_n,sdc_wr_data,
		 sdc_wr_en_n,sdc_en,sdc_mode_reg,sdc_tras_d,sdc_trp_d,sdc_trcd_d,
		 sdc_cas,sdc_trca_d,sdc_twr_d,sdc_rfrsh,sdc_rfmax,sdc_sel,

   //.....inputs.......
   		sdc_clk,sdc_req_ack,sdc_rd_data,sdc_rd_valid,  
   		sdc_wr_next,sdc_init_done
	);


   //-----------for sdram----------

   wire [`SDC_ADDR_MSB:0] 	sdc_ad;
   wire [`SDC_DATA_MSB:0]  	sdc_dq;   
   wire [3:0] 	    		sdc_dm;
   wire [1:0] 	    		sdc_ba; 
   wire 		    	sdc_rasb, sdc_casb, sdc_web;
   wire 		    	sdc_clk;
   wire   	    		sdc_dqs;
   wire 		    	sdc_csb, sdc_cke;

  //----------for host-------------

  wire		mclk,
		s_resetn,
		sdc_req;
  wire [`U_ADDR_MSB:0] 
		sdc_req_adr;
  wire	[1:0]	sdc_req_len;
  wire		sdc_req_wr_n;

  wire  [`U_DATA_MSB:0]
		sdc_wr_data,
		sdc_rd_data;
  wire  [3:0]	sdc_wr_en_n;

  wire		sdc_en;

  wire  [`SDC_ADDR_MSB:0]	sdc_mode_reg;

  wire  [3:0]	sdc_tras_d,
		sdc_trp_d,
		sdc_trcd_d;
  wire  [2:0]	sdc_cas;

  wire  [3:0]	sdc_trca_d,	
		sdc_twr_d;
  wire  [11:0]	sdc_rfrsh;
  wire  [2:0]	sdc_rfmax;
  wire 	sdc_sel;  


  wire		sdc_req_ack,
		sdc_rd_valid,
		sdc_wr_next,
		sdc_init_done;
 
   wire [2:0]cmd_out_sdc = {sdc_rasb, sdc_casb, sdc_web};

endmodule
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//