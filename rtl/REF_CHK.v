/////////////////////////////////////////////////////////////////////////////
//     									   //
//  Copyright(c) 2002 iPlay Networks P. Ltd.All Rights Reserved. 	   //
//  This document contain information which is both confidential and 	   //
//  proprietary to  iPlay Networks P. Ltd.	               		   //
//                  Himayat Nagar Hyderabad. India.  011-91-40-4076669     //
//     									   //
/////////////////////////////////////////////////////////////////////////////
// Filename: ref_chk.v                                                     //
//		  							   //
// Author: Saji Sebastian              				           //
//     									   //
// Description : Refresh Check Module       		                   //
// Rev1.4     : 19 August 2002    				           //	
//	        			                                   //
/////////////////////////////////////////////////////////////////////////////

module ref_chk(

   // -Outputs-
   ref_set,ref_end,wen,ren,clk,clk2x,rst2,
   sdr_req_wr_nL,

   // -Inputs-
   mclk,s_resetn,trca_end,sdr_rfrsh,sdr_rfmax,
   init_done,sdr_req_wr_n,sdr_req,StRef,req_ack

);

output	ref_set,	// refresh set do refresh	
   ref_end,	//
   wen,		// write enble
   ren,		// read enable
   clk,		// clock out
   clk2x,			
   rst2;		// reset o/p

output	sdr_req_wr_nL;

input 	mclk,		// master clock
   s_resetn,	// reset i/p
   trca_end;
input  [11:0]	sdr_rfrsh;	//  number of rows to refresh per burst

input  [2:0]	sdr_rfmax;	//  refresh time per row

input	 	init_done,     	// initialization done i/p
   sdr_req_wr_n,	// 0-wr,1-rd
   sdr_req,	// next rd/wr req
   StRef,
   req_ack;

wire 	        mclk,
   s_resetn,
   trca_end;

wire  [11:0]	sdr_rfrsh;

wire  [2:0]	sdr_rfmax;

wire	 	init_done,
   sdr_req_wr_n,
   sdr_req,	
   StRef,
   req_ack;

reg		sdr_req_wr_nL;


reg [11:0]	ref_time;
reg [2:0] 	ref_max;
reg 		ref_set;//,wen,ren;
wire 		wen,ren;
reg 		rst0,rst1,rst2;
reg [1:0]	cnt;
wire 		clk,clk2x ;
reg		sdr_req1,sdr_reqD,sdr_reqD1;
reg 		ReqAckL1,ReqAckL2;
wire 		ReqAckL;

wire ref_setW = (ref_time == sdr_rfrsh) && init_done;
wire ref_end   = (ref_max==sdr_rfmax-3'b1)&trca_end;

always @(posedge mclk)
begin
   if(~s_resetn)
   begin
      cnt   <= 2'b00;

      rst0  <= 1'b0;
      rst1  <= 1'b0;
      rst2  <= 1'b0;
   end
   else
   begin
      cnt <= cnt + 2'b01;
      rst0  <= rst0;
      rst1  <= rst1;
      rst2  <= rst2;
   end
end
assign clk     = cnt[0];
assign clk2x   = mclk;
assign ReqAckL	= (req_ack) ? 1'b1 :(sdr_req) ? 1'b0 :
   (!init_done) ? 1'b0 : ReqAckL;


always @(posedge clk)
begin
   rst0 <= s_resetn;
   rst1 <= rst0;
   rst2 <= rst1;
end
//----
always @(posedge clk)
   if(!rst2)
   begin
      ref_time        <= 12'h000; //sdr_rfrsh;                   // load refresh time for row
      ref_set 		<= 1'b0;			// refersh counter set
      ref_max         <= 3'b000;  //sdr_rfmax;                   // load no: of rows to be refreshed
   end
   else
   begin
      if(ref_end)
      begin
	 ref_time    <= 12'h000;  //sdr_rfrsh;               // load refresh time for row
	 ref_set     <= 1'b0;
	 ref_max     <= 3'b000;   //sdr_rfmax;               // load no: of rows to be refreshed

      end		
      else
      begin
	 ref_time <= (ref_setW) ? ref_time :(init_done) ? (ref_time + 12'b1) : 12'h000 ;	
	 ref_set  <= ref_setW;//(ref_start) ? 1'b1:1'b0;
	 ref_max	 <= (trca_end&ref_setW&StRef) ? ref_max +3'b001 : ref_max;
      end
   end

always @(posedge clk2x)
   if(!rst2)
   begin
      sdr_req1		<= 1'b0;
      sdr_reqD		<= 1'b0;
      sdr_req_wr_nL   <= 1'b0;
      ReqAckL1		<= 1'b0;
      ReqAckL2		<= 1'b0;

   end
   else
   begin
      sdr_req1		<= sdr_req;
      sdr_reqD		<= (sdr_req^sdr_req1)&sdr_req;
      sdr_req_wr_nL	<= (sdr_reqD) ? sdr_req_wr_n : sdr_req_wr_nL;
      ReqAckL1		<= ReqAckL;
      ReqAckL2		<= ReqAckL1;

   end

assign wen = (!ReqAckL2 && init_done && !sdr_req_wr_nL && sdr_req);
assign ren = (!ReqAckL2 &&init_done && sdr_req_wr_nL && sdr_req);



endmodule

