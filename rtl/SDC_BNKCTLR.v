/////////////////////////////////////////////////////////////////////////////
//     									   //
//  Copyright(c) 2002 iPlay Networks P. Ltd.All Rights Reserved. 	   //
//  This document contain information which is both confidential and 	   //
//  proprietary to  iPlay Networks P. Ltd.	               		   //
//                  Himayat Nagar Hyderabad. India.  011-91-40-4076669     //
//     									   //
/////////////////////////////////////////////////////////////////////////////
// Filename: SDC_BNKCTLR.v                                                 //        
//		  							   //
// Author: Saji Sebastian              				           //
//     									   //
// Description : Bank Controller Module					   //
// Rev1.4     : 19 August 2002    				           //
//				Rmd delay 4 wr_next			   //	
/////////////////////////////////////////////////////////////////////////////

`include"define.v"
module sdc_bnkctlr(

   //Outputs

	write_en,read_en,Mrow_addr,row_addr,mrs_addr,StWrRd,cmd_out,
	init_ed,sdr_wr_next,trca_end,enAp,req_ack,rdAdr,blx,StRef,extMR,SLA,
	
   //Inputs
	clk,clk2x,rst2,ren,wen,ref_set,
	sdr_req,sdr_en,sdr_req_wr_n,sdr_mode_reg,sdr_tras_d,sdr_trp_d,sdr_trcd_d,
	sdr_cas,sdr_trca_d,sdr_twr_d,adrChg,AdrCntOvf,auto_prech,sdr_sel,bnkAdr,
	req_len,RowOvfOut,ref_end
	
	);
 parameter 	s_powerup 		= 4'h4,//,
		s_wait    		= 4'h3,//1, 
		s_prech   		= 4'h2, 
		s_aref    		= 4'h1,//3, 
		s_lmreg   		= 4'h0,//4, 
		s_idle    		= 4'h5,
		s_burstx  		= 4'h8, 
		s_prechwait		= 4'hC, 
		s_arefwait 		= 4'hD;

  output	write_en,		// wr en o/p
		read_en,		// rd en
		Mrow_addr,		// row adr for precharge
		row_addr,		// row adr for rd/wr
		mrs_addr,		// mode reg
		StWrRd,			// rd/wr in current bank
	 	init_ed,		// initialized	
		sdr_wr_next,		// wr nxt to mc
		trca_end,
		enAp,			// enable auto precharge
		req_ack,		// request ack to mc	
		rdAdr	;		// increment rd/wr addr cnt

  output [2:0]	cmd_out;		// command out
  output [8:0]	blx;			// burst length
  output 	StRef,			// start refresh
		extMR,
		SLA;            // single location access 19-12-02

  input		clk,clk2x,		// clks
		rst2,			// delayed rst
		ren,			// rd enable
		wen,			// wr enable
		ref_set,		// refresh counter set	
		sdr_en,			// enable controller
		sdr_req_wr_n;           // wr/rd request

  input  [`SDC_ADDR_MSB:0]
		sdr_mode_reg;		// mode reg i/p

  input  [3:0]	sdr_tras_d,		// delay i/ps
		sdr_trp_d,
		sdr_trcd_d;
  input  [2:0]	sdr_cas;

  input  [3:0]	sdr_trca_d,	
		sdr_twr_d;
  input 	auto_prech,		// auto precharge
		adrChg,			// addr change
		AdrCntOvf,		// address counter overflow
		RowOvfOut,		// row counter overflow
		sdr_req,		// request for next rd/wr
		sdr_sel,		// select ddr/sdr
		ref_end;

  input [1:0]	bnkAdr,			// bank addr
		req_len;		// # of beats

reg [3:0] 		i_cnt,trca_cnt,tras_cnt,
	  		trp_cnt,state,n_state;
wire  w_powerup 	= (state == s_powerup);
wire  w_wait		= (state == s_wait );
wire  w_prech		= (state == s_prech);
wire  w_aref		= (state == s_aref);
wire  w_lmreg		= (state == s_lmreg);
wire  w_idle 		= (state == s_idle);
wire  w_burstx		= (state == s_burstx);

reg [1:0]lmod;
reg init_done;
reg [1:0] i_cmd;

wire [1:0]lmod1 	= lmod;
wire  lmodChk		= (sdr_sel) ? (lmod1 == 2'b01):(lmod1 == 2'b10);

assign  extMR		= (lmod == 2'b01)& w_lmreg;


reg 			waitcnt_st,trp_st,trca_st,
    			tras_st,burst1,burst2,burst3;
reg [1:0]		arefcnt;

reg 			trp_end1;
reg		 	tras_end1,
    			wr_req1,wr_req2,wr_req3;
reg 			init_done1,init_done2,init_done3,init_done4,
			sdr_reqD,StRef;
reg [15:0]		w_cnt;


//-----------wires---------------
wire  wait_end   ;
wire  tras_end   ;
wire  trp_end    ;
wire burstp  	;
//wire rdAdr0,rdAdr1,rdAdr2,rdAdr3;
wire [2:0]cmdBA,cmdBA0,cmdBA1,cmdBA2,cmdBA3;
wire StWrRd,wrNxt;
wire 	write_en0,write_en1,write_en2,write_en3,
	read_en0,read_en1,read_en2,read_en3,
	rowAdrB0,rowAdrB1,rowAdrB2,rowAdrB3,
	StWrRd0,StWrRd1,StWrRd2,StWrRd3,
	wrNxt0,wrNxt1,wrNxt2,wrNxt3;

wire [7:0]BstNumX0,BstNumX1,BstNumX2,BstNumX3,BstNumI;


  wire		clk,clk2x,
		rst2,
		ren,
		wen,
		trca_end,
		sdr_en,
		sdr_req_wr_n;
  wire  [`SDC_ADDR_MSB:0]
		sdr_mode_reg;

  wire  [3:0]	sdr_tras_d,
		sdr_trp_d,
		sdr_trcd_d;
  wire  [2:0]	sdr_cas;

  wire  [3:0]	sdr_trca_d,	
		sdr_twr_d;
  wire 		auto_prech,
		adrChg; 
  wire 		sdr_req,
		req_ack,
		sdr_sel,
		init_ed,
		ref_set,
		AdrCntOvf,
		RowOvfOut,
		ref_end,
		extMR;
  wire	[1:0]	bnkAdr,req_len;

  wire		write_en,
		read_en,
		Mrow_addr,row_addr,
		mrs_addr;
//  reg		sdr_wr_next;
  wire		sdr_wr_next;

  reg		DbnkSel0,DbnkSel1,DbnkSel2,DbnkSel3;
  reg		D1bnkSel0,D1bnkSel1,D1bnkSel2,D1bnkSel3;//!!

  wire  [2:0]	cmd_out;	
  wire  	bnkSel0,bnkSel1,bnkSel2,bnkSel3;
		
  wire		ReqAck0,ReqAck1,ReqAck2,ReqAck3;
  wire 		Busy0,Busy1,Busy2,Busy3;
  wire 		BusFree;
  wire		enAp,enAp0,enAp1,enAp2,enAp3;
  wire		rdAdr,rdAdr0,rdAdr1,rdAdr2,rdAdr3;

always @(posedge clk or negedge rst2)
   		  
	if(!rst2)
		i_cmd <= 2'b00;	
	else if(!rst2 && init_done)
		i_cmd <= 2'b01;	
	else if(!sdr_en && init_done)
		i_cmd <= 2'b10;	
	else
		i_cmd <= 2'b11;	

reg bx,bx1;

always @ (posedge clk or  negedge rst2)
if(!rst2)
 begin
	state  <= s_idle;
 end
else
 begin
	state  <= n_state;
 end

always @ (state or wait_end or trp_end or trca_end or lmodChk or sdr_en or i_cmd or trca_cnt or init_done
	  or arefcnt or  burstp or StRef or bx or ref_end)
begin
     case(state)

	s_powerup	:	n_state = s_wait;
	
	s_wait   	: begin
		   	   if(!sdr_en)
				n_state = s_idle;
		   	   else if(wait_end)			 
			   	n_state = s_prech;
                   	   else	
			   	n_state = s_wait;
		      end	

       	s_prech      : begin
				n_state = s_prechwait;
	               end

 	s_prechwait  : if(!sdr_en)
			    n_state = s_idle;
			   else if(StRef&trp_end)		        // REFRESH WHEN REF_CNT SET
         		   	n_state = s_aref;
			   else if(trp_end)
			    n_state = s_idle;
			   else	
			    n_state = s_prechwait;

	s_aref 		 : begin
			    n_state = s_arefwait;
			   end

	s_arefwait   : if(ref_end)
			    n_state = s_idle;
			   else if(StRef&trca_end)		        // REFRESH WHEN REF_CNT SET
         		   	n_state = s_aref;
			   else	if(trca_end)
			    n_state = s_idle;
			   else 
			    n_state = s_arefwait;

        s_lmreg	     : begin
			    n_state = s_idle;
	           	   end	

	s_idle           :  begin
			    					
			if(i_cmd == 2'b00)
			   n_state = s_powerup;
			else if(i_cmd == 2'b01)
			   n_state = s_lmreg;
			else if(i_cmd == 2'b10)
			   n_state = (bx) ?  s_aref : s_burstx;

			else 
	begin
	 		if(!init_done && arefcnt == 2'b00) 
			   n_state = s_aref;
			else if(arefcnt == 2'b01)		// SEND AREF CYCLE
	   		   n_state = s_aref; 
			else if(StRef)		        // REFRESH WHEN REF_CNT SET
         		   n_state = s_prech;
			else if(!lmodChk && init_done)     	// IF INITIALIZED LOAD MODE REG
			   n_state = s_lmreg;
			else if(arefcnt == 2'b11)		// SEND AREF CYCLE
	   		   n_state = s_idle;
			else 
			   n_state = s_idle;
		   
 		end
	end
	
	s_burstx     : begin 
         		   if(burstp)
	     			n_state = s_prech;     
		 	   else				
			   	n_state = s_idle;
 		      end
	default      :  n_state = s_idle;
 endcase
end
//---------------------------------------------//
always @(posedge clk or negedge rst2)
     if(!rst2)
 	begin
		waitcnt_st	<= 1'b0;
		trp_st 		<= 1'b0;
		trca_st  	<= 1'b0;
		tras_st		<= 1'b0;
		bx1 		<= 1'b0;
	        lmod		<= 2'b00;	
	end
     else
     begin
	if(w_wait)
	  begin
		waitcnt_st	<= 1'b1;
		trp_st 		<= 1'b0;
		trca_st  	<= 1'b0;
		tras_st		<= 1'b0;
		bx1 		<= 1'b0;
	        lmod		<= 2'b00;	
	  end
	else
	if(w_prech)
	  begin
		waitcnt_st	<= 1'b0;
		trp_st 		<= 1'b1;
		trca_st  	<= 1'b0;
		tras_st		<= 1'b0;
		bx1 		<= 1'b0;
	        lmod		<= lmod;
	  end
	else
	if(w_aref)
	  begin
		waitcnt_st	<= 1'b0;
		trp_st 		<= 1'b0;
		trca_st  	<= 1'b1;
		tras_st		<= 1'b0;
		bx1 		<= 1'b0;
	        lmod		<= lmod;
   	  end
	else
	if(w_lmreg)
	  begin
		waitcnt_st	<= 1'b0;
		trp_st 		<= 1'b0;
		trca_st  	<= 1'b0;
		tras_st		<= 1'b0;
		bx1 		<= 1'b0;
	        lmod		<= lmod+2'b01;	
          end	
	else
	if(w_idle)
	  begin
		waitcnt_st	<= 1'b0;
		trp_st 		<= 1'b0;
		trca_st  	<= 1'b0;
		tras_st		<= 1'b0;
		bx1 		<= 1'b0;
	        lmod		<= lmod;
	 end
	else
	if(w_burstx)
	  begin
		waitcnt_st	<= 1'b0;
		trp_st 		<= 1'b0;
		trca_st  	<= 1'b0;
		tras_st		<= 1'b0;
		bx1 		<= 1'b1;
	        lmod		<= lmod;
	  end
	end	
		
always @(negedge clk)
 begin	
	sdr_reqD	<= sdr_req;
 end

always @(posedge clk or negedge rst2)

     if(~rst2)
      begin	
	bx		<= 1'b0;
	init_done	<= 1'b0;
	init_done1	<= 1'b0;
	init_done2	<= 1'b0;
	init_done3	<= 1'b0;
	init_done4	<= 1'b0;

	burst1  	<= 1'b0; 
	burst2  	<= 1'b0; 
	burst3  	<= 1'b0; 

	wr_req1 	<= 1'b0; 
	wr_req2 	<= 1'b0; 
	wr_req3 	<= 1'b0; 
	trp_end1   	<= 1'b0;	
	tras_end1 	<= 1'b0;

	arefcnt    	<= 2'b0;
	w_cnt		<= 16'h0;
	trp_cnt  	<= 4'h0;

        i_cnt		<= 4'b0;
	trca_cnt   	<= 4'h0;
	tras_cnt	<= 4'h0;
//	sdr_wr_next     <= 1'b0;
	DbnkSel0	<= 1'b0;
	DbnkSel1	<= 1'b0;
	DbnkSel2	<= 1'b0;
	DbnkSel3	<= 1'b0;

	D1bnkSel0	<= 1'b0;
	D1bnkSel1	<= 1'b0;
	D1bnkSel2	<= 1'b0;
	D1bnkSel3	<= 1'b0;

	StRef 		<= 1'b0;

     end
    else
   begin
	bx		<= bx1;
 	init_done    	<= (i_cnt == 4'h4 && arefcnt == 2'b10 && trca_end)  ? 1'b1 : init_done;
	init_done1	<= init_done;
	init_done2	<= init_done1;
	init_done3	<= init_done2;
	init_done4	<= init_done3;
	
      	burst1          <= w_burstx;
      	burst2          <= burst1;
      	burst3          <= burst2;

      	wr_req1         <= sdr_req_wr_n;
      	wr_req2         <= wr_req1;
      	wr_req3         <= wr_req2;

	trp_end1        <= trp_end;
      	tras_end1       <= tras_end;

      i_cnt	  	<=  (w_lmreg) 	?  (i_cnt + 4'h1) :
			    (w_powerup) 	?  (i_cnt + 4'h1) :
			    (w_prech)	?  (i_cnt + 4'h1) :
			    (w_aref) 	?  (i_cnt + 4'h1) :	i_cnt;

      arefcnt     	<=  (w_aref) ? (arefcnt + 2'b1) :
                     	    (init_done) ? 2'b11 : arefcnt; 
	 
      w_cnt    		<= (waitcnt_st) ? (w_cnt + 16'h1) : 16'h0;

      trca_cnt    	<= (trca_end) ? 4'h0  : 
		     	   (trca_st)  ? (trca_cnt  + 4'b1) : 4'h0;

      trp_cnt     	<= (trp_end) ? 4'h0   :
		     	   (trp_st) ? (trp_cnt  + 4'b1) : 4'h0;

      tras_cnt    	<= (tras_end) ? 4'h0   :
		     	   (tras_st)  ? (tras_cnt  + 4'b1) : 4'h0;
//      sdr_wr_next     	<= (init_done1) ? wrNxt :1'b0;

      DbnkSel0		<= bnkSel0;
      DbnkSel1		<= bnkSel1;
      DbnkSel2		<= bnkSel2;
      DbnkSel3		<= bnkSel3;

	D1bnkSel0	<= DbnkSel0;//!!
	D1bnkSel1	<= DbnkSel0;
	D1bnkSel2	<= DbnkSel0;
	D1bnkSel3	<= DbnkSel0;
 
      StRef 		<= (ref_end) ? 1'b0 :			
	       		   (ref_set&(req_ack||!sdr_req)) ? 1'b1 :StRef;

  end


//----------------------------------------------//
 assign sdr_wr_next   = (init_done1) ? wrNxt :1'b0;

 assign rdAdr			= 				
		  (DbnkSel3) ?  rdAdr3:
		  (DbnkSel2) ?  rdAdr2:
		  (DbnkSel1) ?  rdAdr1:
		  (DbnkSel0) ?  rdAdr0: 1'b0;

 assign req_ack			=  	
		  (DbnkSel3) ?  ReqAck3:
		  (DbnkSel2) ?  ReqAck2:
		  (DbnkSel1) ?  ReqAck1:
		  (DbnkSel0) ?  ReqAck0: 1'b0;

 assign enAp  			= enAp0|enAp1|enAp2|enAp3;
 assign BusFree 		= !(Busy0|Busy1|Busy2|Busy3);
 assign Mrow_addr		= w_prech;
 assign mrs_addr		= w_lmreg;
 assign init_ed			= init_done; 

 assign {bnkSel0,bnkSel1,bnkSel2,bnkSel3} 
									//while refresh disable banks
	=	(StRef) 			? (4'h0) : 
		(init_done2&BusFree) ? ({(bnkAdr==2'b00),(bnkAdr==2'b01),(bnkAdr==2'b10),(bnkAdr==2'b11)}) : 
						 ({DbnkSel0,DbnkSel1,DbnkSel2,DbnkSel3});//4'h0;



 wire [2:0]
	cmdTOP  = (w_powerup) 	?	`C_NOP			:
		  (w_wait)      ?	`C_NOP 			:
		  (w_prech)	?	((auto_prech) ? `C_NOP  : `C_PRECHARGE)		:
	  	  (w_aref)	?	`C_AUTO_REFRESH		:
		  (w_lmreg)	?	`C_LOAD_MR		:
		  (w_burstx)	?	`C_BURST_STOP		:
		  (w_idle)	?	`C_NOP			:  `C_NOP;

assign  wait_end   = (sdr_sel) ? (w_cnt == `DLY4SDR) :(w_cnt == `DLY4DDR);
assign trca_end  = (trca_cnt == sdr_trca_d)  	  	? 1'b1 : 1'b0;
assign  tras_end   = (tras_cnt == sdr_tras_d)	  	? 1'b1 : 1'b0;
assign  trp_end    = (trp_cnt  == sdr_trp_d)	  	? 1'b1 : 1'b0;
wire  init_doneW = (sdr_sel) ? init_done2 :init_done4;

wire [8:0]blx 	= (init_done1) ? (
		  (sdr_mode_reg[2:0] == 3'b000) ? 9'h1 :
		  (sdr_mode_reg[2:0] == 3'b001) ? 9'h2 :
               	  (sdr_mode_reg[2:0] == 3'b010) ? 9'h4 : 
                  (sdr_mode_reg[2:0] == 3'b011) ? 9'h8 :
	          (sdr_mode_reg[2:0] == 3'b111 && sdr_sel) ? 9'h1ff : 9'h0ff) : 9'h00;
		
wire [8:0]bly	= (sdr_sel) ? (blx) : ({blx[0],blx[8:1]});

wire [8:0]bl	= (sdr_sel) ? ((sdr_req_wr_n) ? bly : (bly-9'h1)) : bly;
//					  ((bly===9'h01)  ? (bly-9'h1) : bly);

assign burstp  	= (sdr_mode_reg[2:0] == 3'b111) ? 1'b1 : 1'b0;
//wire ref_rst 	= (w_aref) ? 1'b1 : 1'b0;
wire wr_chk 	= ((wr_req1 !== wr_req3)&&(wen || ren)) ? 1'b1 :1'b0;
wire sdr_reqW 	= (sdr_mode_reg[2:0] == 3'b000) ? sdr_req : sdr_reqD;
wire SLA        = (sdr_mode_reg[9]&sdr_sel); // single location access 19-12-02	

//==========================================================================================//

state BA0(

  //Outputs

	.write_en(write_en0),.read_en(read_en0),.row_addr(rowAdrB0),
	.StWrRd(StWrRd0),.wrNxt(wrNxt0),.enAprech(enAp0),.rdAdr(rdAdr0),.ReqAck(ReqAck0),.Busy(Busy0),
	.BstNumO(BstNumX0),.cmdOut02(cmdBA0),
  //Inputs
	.clk(clk),.clk2x(clk2x),.rst2(rst2),.ren(ren),.wen(wen),
	.burstLen(bl),.burstPage(burstp),.adrChg(adrChg),.auto_prech(auto_prech),.AdrCntOvf(AdrCntOvf),
	.wr_chk(wr_chk),.sdr_req(sdr_reqW),.sdr_en(sdr_en),.sdr_tras_d(sdr_tras_d),.sdr_trp_d(sdr_trp_d),
	.sdr_trcd_d(sdr_trcd_d),.sdr_cas(sdr_cas),.sdr_trca_d(sdr_trca_d),.sdr_twr_d(sdr_twr_d),
	.sdr_sel(sdr_sel),.bnkSel(bnkSel0),.req_len(req_len),.ROvf(RowOvfOut&bnkSel0),.BstNumI(BstNumI),
 	.SLA(SLA)
	
	);

//==========================================================================================//
state BA1(


  //Outputs

	.write_en(write_en1),.read_en(read_en1),.row_addr(rowAdrB1),
	.StWrRd(StWrRd1),.wrNxt(wrNxt1),.enAprech(enAp1),.rdAdr(rdAdr1),.ReqAck(ReqAck1),.Busy(Busy1),
	.BstNumO(BstNumX1),.cmdOut02(cmdBA1),

  //Inputs
	.clk(clk),.clk2x(clk2x),.rst2(rst2),.ren(ren),.wen(wen),
	.burstLen(bl),.burstPage(burstp),.adrChg(adrChg),.auto_prech(auto_prech),.AdrCntOvf(AdrCntOvf),
	.wr_chk(wr_chk),.sdr_req(sdr_reqW),.sdr_en(sdr_en),.sdr_tras_d(sdr_tras_d),.sdr_trp_d(sdr_trp_d),
	.sdr_trcd_d(sdr_trcd_d),.sdr_cas(sdr_cas),.sdr_trca_d(sdr_trca_d),.sdr_twr_d(sdr_twr_d),
	.sdr_sel(sdr_sel),.bnkSel(bnkSel1),.req_len(req_len),.ROvf(RowOvfOut&bnkSel1),.BstNumI(BstNumI),
 	.SLA(SLA)
 	
	);

//==========================================================================================//

state BA2(

  //Outputs

	.write_en(write_en2),.read_en(read_en2),.row_addr(rowAdrB2),
	.StWrRd(StWrRd2),.wrNxt(wrNxt2),.enAprech(enAp2),.rdAdr(rdAdr2),.ReqAck(ReqAck2),.Busy(Busy2),
	.BstNumO(BstNumX2),.cmdOut02(cmdBA2),

  //Inputs
	.clk(clk),.clk2x(clk2x),.rst2(rst2),.ren(ren),.wen(wen),
	.burstLen(bl),.burstPage(burstp),.adrChg(adrChg),.auto_prech(auto_prech),.AdrCntOvf(AdrCntOvf),
	.wr_chk(wr_chk),.sdr_req(sdr_reqW),.sdr_en(sdr_en),.sdr_tras_d(sdr_tras_d),.sdr_trp_d(sdr_trp_d),
	.sdr_trcd_d(sdr_trcd_d),.sdr_cas(sdr_cas),.sdr_trca_d(sdr_trca_d),.sdr_twr_d(sdr_twr_d),
	.sdr_sel(sdr_sel),.bnkSel(bnkSel2),.req_len(req_len),.ROvf(RowOvfOut&bnkSel2),.BstNumI(BstNumI),
 	.SLA(SLA)
 
	
	);

//==========================================================================================//
state BA3(
 
  //Outputs

	.write_en(write_en3),.read_en(read_en3),.row_addr(rowAdrB3),
	.StWrRd(StWrRd3),.wrNxt(wrNxt3),.enAprech(enAp3),.rdAdr(rdAdr3),.ReqAck(ReqAck3),.Busy(Busy3),
	.BstNumO(BstNumX3),.cmdOut02(cmdBA3),
	
  //Inputs
	.clk(clk),.clk2x(clk2x),.rst2(rst2),.ren(ren),.wen(wen),
	.burstLen(bl),.burstPage(burstp),.adrChg(adrChg),.auto_prech(auto_prech),.AdrCntOvf(AdrCntOvf),
	.wr_chk(wr_chk),.sdr_req(sdr_reqW),.sdr_en(sdr_en),.sdr_tras_d(sdr_tras_d),.sdr_trp_d(sdr_trp_d),
	.sdr_trcd_d(sdr_trcd_d),.sdr_cas(sdr_cas),.sdr_trca_d(sdr_trca_d),.sdr_twr_d(sdr_twr_d),
	.sdr_sel(sdr_sel),.bnkSel(bnkSel3),.req_len(req_len),.ROvf(RowOvfOut&bnkSel3),.BstNumI(BstNumI),
 	.SLA(SLA)

	);

//==========================================================================================//

//assign BstNumI = BstNumX0|BstNumX1|BstNumX2|BstNumX3;

assign BstNumI =  (D1bnkSel3&RowOvfOut) ?  BstNumX0:
		  (D1bnkSel2&RowOvfOut) ?  BstNumX1:
		  (D1bnkSel1&RowOvfOut) ?  BstNumX2:
		  (D1bnkSel0&RowOvfOut) ?  BstNumX3: 8'h00;

assign cmd_out = (init_doneW&!StRef) ? cmdBA : cmdTOP; //if ref send ref-commds

assign 	cmdBA 	= (DbnkSel3) ? cmdBA3 :
		  (DbnkSel2) ? cmdBA2 :
		  (DbnkSel1) ? cmdBA1 :
		  (DbnkSel0) ? cmdBA0 : `C_NOP;

assign {write_en,read_en,row_addr,StWrRd,wrNxt} = 
	(bnkSel0) ? {write_en0,read_en0,rowAdrB0,StWrRd0,wrNxt0}:
	(bnkSel1) ? {write_en1,read_en1,rowAdrB1,StWrRd1,wrNxt1}:
	(bnkSel2) ? {write_en2,read_en2,rowAdrB2,StWrRd2,wrNxt2}:
	(bnkSel3) ? {write_en3,read_en3,rowAdrB3,StWrRd3,wrNxt3}: 5'h00 ;
	

endmodule
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
