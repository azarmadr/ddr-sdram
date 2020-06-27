/////////////////////////////////////////////////////////////////////////////
//     									   //
//  Copyright(c) 2002 iPlay Networks P. Ltd.All Rights Reserved. 	   //
//  This document contain information which is both confidential and 	   //
//  proprietary to  iPlay Networks P. Ltd.	               		   //
//                  Himayat Nagar Hyderabad. India.  011-91-40-4076669     //
//     									   //
/////////////////////////////////////////////////////////////////////////////
// Filename: StMac.v                                                       //
//		  							   //
// Author: Saji Sebastian              				           //
//     									   //
// Description : State Machine File					   //
// Rev1.4     : 19 August 2002    				           //	
//	        			                                   //
/////////////////////////////////////////////////////////////////////////////

module state(
	
   //Outputs

	write_en,read_en,row_addr,StWrRd,wrNxt,
	enAprech,rdAdr,ReqAck,Busy,BstNumO,cmdOut02,

   //Inputs
	clk,clk2x,rst2,ren,wen,burstLen,burstPage,auto_prech,
	AdrCntOvf,wr_chk,adrChg,sdr_req,sdr_en,sdr_tras_d,sdr_trp_d,sdr_trcd_d,
	sdr_cas,sdr_trca_d,sdr_twr_d,sdr_sel,bnkSel,req_len,ROvf,BstNumI,SLA

	
	);

  output	write_en,
		read_en,
		row_addr,
		StWrRd,
		wrNxt,enAprech,rdAdr,
		ReqAck,Busy;
  output [7:0]   BstNumO;
  output [2:0]	cmdOut02;	


  input		clk,clk2x,//2x + @02-08-02
		rst2,
		ren,
		wen,
		sdr_en;
	
  input  [8:0]	burstLen;
  input		burstPage,auto_prech,AdrCntOvf,wr_chk;

  input  [3:0]	sdr_tras_d,
		sdr_trp_d,
		sdr_trcd_d;
  input  [2:0]	sdr_cas;

  input  [3:0]	sdr_trca_d,	
		sdr_twr_d;
  input 	sdr_req,
		sdr_sel,adrChg,
		bnkSel,ROvf;
  input [1:0]   req_len;
  input [7:0]   BstNumI;
  input 	SLA;

//-----------wires---------------
wire Endbt1bl8   ;
wire  [8:0]wr_Len ;
wire  rd_endD    ;
wire  rd_endS    ;
wire  wr_end 	 ;

  wire		clk,clk2x,
		rst2,
		ren,
		wen,
		sdr_en;

  wire  [3:0]	sdr_tras_d,
		sdr_trp_d,
		sdr_trcd_d;
  wire  [2:0]	sdr_cas;

  wire  [3:0]	sdr_trca_d,	
		sdr_twr_d;
  wire 		sdr_req,sdr_sel;

  wire		write_en,
		read_en,
		adrChg,	
		auto_prech,
		AdrCntOvf,
		wr_chk,rdAdr,StWrRd,
		bnkSel,wrNxt,ReqAckW,burstPage,ROvf;
  wire  [8:0]	burstLen;
  wire  [1:0] 	req_len;
  reg   [1:0]	req_lenM;

  wire  [2:0]	cmd_out,cmd_out_pbl,cmd_out_sla;//+ for prog. burstlen &single location access 19-12-02	
  wire  [7:0]   BstNumI,BstNumOW;
  reg 		row_addr,ReqAck;
  reg   [7:0]   BstNumO,BstNumO1;

 parameter 	s_prech   		= 4'h2,
		s_idle    		= 4'h5,
		s_write   		= 4'h6,
		s_read    		= 4'h7,
		s_burstx  		= 4'h8,
		s_wr_wait 		= 4'hA,
		s_rd_wait 		= 4'hB,
		s_prechwait		= 4'hC,
		s_trcd_delay 	= 4'hE,
		s_wr_end		= 4'h1,
		s_act_row		= 4'hF;

/*-----------
`define C_LOAD_MR            3'b000
`define C_AUTO_REFRESH       3'b001
`define C_PRECHARGE          3'b010
`define C_ACT_ROW            3'b011
`define C_WRITEA             3'b100
`define C_READA              3'b101
`define C_BURST_STOP         3'b110
`define C_NOP                3'b111
------------*/

wire [8:0]bl1	 = (wen) ? (burstLen + 9'h01):burstLen;
wire [8:0]bl	 = (sdr_sel)? bl1 : (/*(burstLen === 9'h01) ? 9'h01 :*/ burstLen<<1);
reg trp_st,trca_st,trcd_st,twr_st,
    tras_st;
reg [1:0]arefcnt;
reg [3:0] w_cnt,i_cnt,trca_cnt,tras_cnt,twr_cnt,
	  trp_cnt,trcd_cnt,state,n_state;
reg [8:0]rd_cnt,wr_cnt;
reg write_st,write_st1,read_st,read_st1;
reg wr_end1,rd_end1;
reg trp_end1,trcd_end1;
reg tras_end1,tras_end2,tras_end3,tras_end4;
reg [2:0]cmdOut01,cmdOut02;
reg rowActed,sdr_reqL,Rprech,ReqEnd,Busy,Busy0;
reg [7:0]BstNum,pgCnt;
reg enAprech,sdr_req1,sdr_reqD,ReqAck1,ReqAckL,pgEnd1,
    StpBst,Endbt1bl8r,AdrCntOvfD,prechD;

 assign BstNumOW 		= (burstPage) ? (AdrCntOvfD ? pgCnt :BstNumOW) : (bnkSel)? BstNum : 8'h00;

wire  rd_endW    = (burstLen==9'h00&BstNum==8'h00)?1'b1:
		   (ren) ? ((sdr_sel)? rd_endS :rd_endD)|Endbt1bl8:1'b0;
						// if page & Ovf send PgCnt to o/p BstNumO
wire  rd_end	 = rd_endW&ren;
 assign rdAdr			= (ren) ? rd_end :				//-mfed for ddr-blen2
			
				  (wen&!sdr_sel) ? ((burstLen==9'h08|burstLen==9'h04) ?
				  (wr_cnt == burstLen-9'h02):wr_cnt ==9'h00):
				  (wr_cnt == burstLen-9'h01);
													
//load # of bytes for page
wire [7:0]PlenW  = 	(burstPage) ?
			((req_lenM==2'b00) ? 8'h04 :
			 (req_lenM==2'b01) ? 8'h08 :
		  	 (req_lenM==2'b10) ? 8'h10 :
		  	 (req_lenM==2'b11) ? 8'h20 :
			  8'h08) :8'h00;
wire [7:0]Plen 	= PlenW - 8'h01 ;
wire pgEnd  	 =	(burstPage) ?(pgCnt == Plen):1'b0;	//pgEnd 4 burst page

wire  w_prech		= (state == s_prech);
wire  w_idle 		= (state == s_idle);
wire  w_write		= (state == s_write);
wire  w_read		= (state == s_read);
wire  w_burstx		= (state == s_burstx);
wire  w_wr_wait 	= (state == s_wr_wait);
wire  w_rd_wait 	= (state == s_rd_wait);
wire  w_wr_end	 	= (state == s_wr_end);
wire  w_trcd_delay 	= (state == s_trcd_delay);
wire  w_act_row		= (state == s_act_row);

 assign ReqAckW			= (BstNum==8'h00&(wr_end1|rd_end1)|StpBst);//pgEnd);
 assign write_en		= (!sdr_sel&bl==9'h04) ? write_st&write_st1:write_st;//!!
 assign read_en			= read_st;
 assign wrNxt 			= (sdr_sel) ? write_st : write_st1;
 assign StWrRd			= w_write |w_read;

 wire [8:0]NxtCnt 		= (burstLen +9'h01)>>1;
wire [3:0]beat	 = {2'b00,req_lenM} +4'b001;

 wire enAprech0 	  	= (((BstNum==8'h01)& w_write &wr_end1)|((BstNum==8'h00)& (w_write|w_read))
				  &!(bl==9'h8&beat==4'h1));

assign Endbt1bl8   = (sdr_sel)&(bl==9'h8)&(beat==4'h1)&((wr_cnt==9'h3)|(rd_cnt==9'h3));

wire Sc3bl1     = sdr_sel &&(burstLen===9'h01) && prechD && req_lenM==2'b10;

wire [7:0]BstNumW= ((rd_end1&&ren&&!Sc3bl1)||(wr_end1&&wen))? BstNum-8'h01 : BstNum;

wire  wr_endW     = (burstLen==9'h00&BstNum==8'h00)?1'b0:
		   (wen) ? (wr_cnt == wr_Len)|Endbt1bl8r : 1'b0;

assign  wr_Len =  (sdr_sel) ? burstLen : ((bl==9'h2)? (burstLen-9'h1) :
				(~|BstNum) ? (burstLen):(burstLen-9'h1));

assign  rd_endD    = (rd_cnt == (burstLen))	? 1'b1 : 1'b0;
									//gen 1 byte more 4 bl 1/2
wire [8:0]RdEnd	 = (burstLen==9'h08|burstLen==9'h04)?(burstLen -{6'b0,sdr_cas}+9'h01):burstLen;
assign  rd_endS    = (rd_cnt == RdEnd)	? 1'b1 : 1'b0;
assign  wr_end 	 = (bl==9'h01) ? (wr_endW&write_en) :
		   (bl==9'h02&!sdr_sel)? (write_st&wr_endW):
			 (wr_endW&wen);//;
wire ReqEndW	 = ((BstNumW==8'h00)&(rd_end|wr_end)&(write_st|read_st));

wire  trca_end   = (trca_cnt == sdr_trca_d)  	  	? 1'b1 : 1'b0;
wire  tras_end   = (tras_cnt == sdr_tras_d)	  	? 1'b1 : 1'b0;
wire  twr_end    = (twr_cnt  == sdr_twr_d)	  	? 1'b1 : 1'b0;
wire  trp_end    = (trp_cnt  == sdr_trp_d)	  	? 1'b1 : 1'b0;

wire  trcd_end	 = (wen) ?  (trcd_cnt == (sdr_trcd_d)) 	:
		   (ren) ?  (trcd_cnt == (sdr_trcd_d))   :	1'b0;

reg adrChgL;
wire AdrCntOvfR = (bl===9'h01) ? AdrCntOvfD :AdrCntOvf;

wire [7:0]bustNS = (bl===9'h8) ? ((beat===4'h4)? 8'h04 :
				 (beat===4'h3)? 8'h02 :
				 (beat===4'h2)? 8'h01 :
				 (beat===4'h1)? 8'h01 : 8'h00): 	 	 						

		   (bl===9'h4) ? ((beat===4'h4)? 8'h08 :
				 (beat===4'h3)? 8'h04 :
				 (beat===4'h2)? 8'h02 :
				 (beat===4'h1)? 8'h01 : 8'h00):	

		   (bl===9'h2) ? ((beat===4'h4)? 8'h10 :
				 (beat===4'h3)? 8'h08 :
				 (beat===4'h2)? 8'h04 :
				 (beat===4'h1)? 8'h02 : 8'h00):

		   (bl===9'h1) ? ((beat===4'h4)? 8'h20 :  //+ 4 c2bl1
				 (beat===4'h3)? 8'h10 :
				 (beat===4'h2)? 8'h08 :
				 (beat===4'h1)? 8'h04 :8'h00)

					   :  8'h00;

wire [7:0]bustND = bustNS<<8'h01;	//..# of bursts = 2x burst for sdr

wire [7:0]bustN  = (sdr_sel) ? bustNS-8'h01 :((bl==9'h8)&(beat==4'h1))
					 ? bustND-8'h02 : bustND-8'h01 ;

 always @(posedge clk or negedge rst2)

     if(~rst2)
      begin	
	prechD		<= 1'b0;
	AdrCntOvfD  	<= 1'b0;
	req_lenM	<= 2'b00;
	pgEnd1		<= 1'b0;
	StpBst		<= 1'b0;

	ReqAck		<= 1'b0;
	ReqAck1		<= 1'b0;
	ReqAckL		<= 1'b0;

	Endbt1bl8r	<= 1'b0;
	BstNumO1    	<= 8'h00;
	BstNumO  	<= 8'h00;
	
	cmdOut01	<= 3'b000;
	cmdOut02	<= 3'b000;

	trp_end1    	<= 1'b0;	
	trcd_end1   	<= 1'b0;
	tras_end1 	<= 1'b0;
	tras_end2 	<= 1'b0;
	tras_end3 	<= 1'b0;
	tras_end4 	<= 1'b0;
	wr_end1     	<= 1'b0;
	rd_end1     	<= 1'b0;

	arefcnt    	<= 2'b0;
	w_cnt		<= 4'h0;
	trp_cnt  	<= 4'h0;
	rd_cnt		<= 9'h0;
	wr_cnt		<= 9'h0;
        i_cnt		<= 4'b0;
	trca_cnt   	<= 4'h0;
	tras_cnt	<= 4'h0;
	trcd_cnt	<= 4'h0;
	twr_cnt		<= 4'h0;
	row_addr	<= 1'b0;
	pgCnt		<= 8'h00;		//4 page len
	rowActed    	<= 1'b0;
	sdr_reqL	<= 1'b0;
	Rprech		<= 1'b0;
	adrChgL		<= 1'b0;
	BstNum		<= 8'h00;
	ReqEnd		<= 1'b0;
	Busy		<= 1'b0;
	Busy0		<= 1'b0;
	enAprech	<= 1'b0;
	write_st1   	<= 1'b0;
	sdr_req1	<= 1'b0;
	sdr_reqD	<= 1'b0;
	read_st1	<= 1'b0;
     end
   else
     begin
	prechD		<= w_prech;
	AdrCntOvfD	<= AdrCntOvf;
	req_lenM	    = (sdr_reqD) ? req_len :req_lenM;
	pgEnd1		<= pgEnd;
	StpBst		<= pgEnd1;

      ReqAck1	 	<= ReqAckW;
      ReqAckL	 	<=  (ReqAckW)?1'b1:(sdr_reqD/*&bnkSel*/)? 1'b0 : ReqAckL;
      ReqAck	 	<= (burstLen==9'h01&sdr_cas==3'b010) ? ReqAckW : ReqAck1;

      Endbt1bl8r	<= Endbt1bl8;       	
      BstNumO1 	 	<= BstNumOW;
      BstNumO    	<= (bl==9'h01&ren)? BstNum : BstNumO1;
      row_addr	  	<= w_act_row;
	
      wr_end1       	<= wr_end;
      rd_end1       	<= rd_end;
      sdr_req1		<= sdr_req;
      sdr_reqD		<= (sdr_req^sdr_req1)&sdr_req;

      wr_cnt   	  	<= (wr_end|burstPage)  ? 9'h0    :
	     	           ((sdr_sel&write_st)|(!sdr_sel&write_st)) ? (wr_cnt + 9'h1) : wr_cnt;
	
      rd_cnt 	  	<= (rd_end1)   ?  9'h0  :
		           (read_st &!burstPage) ? (rd_cnt + 9'h1) : rd_cnt;

      trca_cnt    	<= (trca_end) ? 4'h0  :
		     	   (trca_st)  ? (trca_cnt  + 4'b1) : 4'h0;

      trp_cnt     	<= (trp_end) ? 4'h0   :
		     	   (trp_st) ? (trp_cnt  + 4'b1) : 4'h0;

      tras_cnt    	<= (tras_end) ? 4'h0   :
		           (tras_st)  ? (tras_cnt  + 4'b1) : 4'h0;

      trcd_cnt    	<= (trcd_end) ? 4'h0   :
		           (trcd_st)  ? (trcd_cnt  + 4'b1) : 4'h0;

      twr_cnt	  	<= (twr_end)	? 4'h0  :
		           (twr_st)	? (twr_cnt   + 4'h1)  : 4'h0;

      pgCnt	  	<= (ROvf) ? BstNumI : (pgEnd)	? 8'h00 :
			   (write_st|read_st) ? (pgCnt+8'h01)	:
			   (ReqAckW|sdr_reqD) ? 8'h00 : pgCnt;//8'h00;

      cmdOut02	  	<= cmd_out;

      BstNum	  	<= (ROvf) ? BstNumI : (sdr_reqD) ? bustN :  BstNumW;

      ReqEnd	  	<= ReqEndW;	
	
      if(w_act_row)
	rowActed 	<= (burstPage) ? 1'b0:1'b1;
      else if(adrChg)
	rowActed 	<= 1'b0;

   	sdr_reqL 	<= (sdr_req) ? 1'b1 :
		           (wr_end|rd_end|burstPage) ?  1'b0 : sdr_reqL;
	Rprech   	<= (w_prech) ? 1'b1 :
		           (w_act_row)? 1'b0 : Rprech;  		
	
	Busy	   	<= (write_st|read_st) ? 1'b1: (ReqEnd & w_prech) ? 1'b0 : 1'b0;					
	enAprech 	<= (!SLA) ? ((bl==9'h01) ? ((BstNum==8'h00)& w_write &wr_end1) : enAprech0)
					  : (((BstNum==8'h00) && wr_end1)?1'b1: 1'b0);//+for single location access 19-12-02
	write_st1	<= write_st;
	read_st1    <= read_st;

  end

always @(negedge clk or negedge rst2)
     if(!rst2)
 	begin
				write_st 	<= 1'b0;
				read_st  	<= 1'b0;
				twr_st		<= 1'b0;	
				trp_st 		<= 1'b0;
				trca_st  	<= 1'b0;
				tras_st		<= 1'b0;
				trcd_st		<= 1'b0;  		
 	end
    else
    begin
	if(w_idle)									//------- + @ 31-7-02
	 begin
	               	write_st <= 1'b0;
			   	read_st  <= 1'b0;
				twr_st   <= 1'b0;
				trp_st   <= 1'b0;
				trca_st  <= 1'b0;
	 	       	tras_st  <= 1'b0;
				trcd_st  <= 1'b0;    	    //----
	end
	else if(w_prech)
	 begin
	               	write_st <= 1'b0;
			   	read_st  <= 1'b0;
				trp_st   <= 1'b1;
				trca_st  <= trca_st;
	 	       	tras_st  <= 1'b0;
				twr_st	 <= 1'b0;
				trcd_st  <=trcd_st;    	
	end
	else if(w_act_row)
	 begin			
				write_st <= write_st ;
			   	read_st  <= read_st;
				twr_st   <= twr_st ;
				trp_st   <= trp_st;
				trca_st  <= trca_st;
	 	       	tras_st  <= tras_st;
        		   	trcd_st  <= 1'b1;
	 end		
	else if(w_write)
	 begin
		    	write_st <= 1'b1;
			   	read_st  <= read_st;
				twr_st   <= twr_st ;
				trp_st   <= trp_st;
				trca_st  <= trca_st;
	 	       	tras_st  <= tras_st;
				trcd_st  <=trcd_st;
	 end
	else if(w_wr_wait)
	 begin
				write_st <= write_st;
			   	read_st  <= read_st;
				twr_st   <= twr_st ;
				trp_st   <= trp_st;
				trca_st  <= trca_st;
	 	       	tras_st  <= 1'b1;
        		   	trcd_st  <= trcd_st;
	 end
	else if(w_wr_end)
	  begin	
				write_st <= 1'b0;
		   	   	read_st  <= 1'b0;
				twr_st 	 <= 1'b1;
				trp_st   <= trp_st;
				trca_st  <= trca_st;
	 	       	tras_st  <= tras_st;
        		   	trcd_st  <= trcd_st;

	   end
	else if(w_read)						//4 read @-1Aug02
	  begin
				write_st <= 1'b0;
		   	   	read_st  <= 1'b1;
				twr_st 	 <= twr_st;
				trp_st   <= trp_st;
				trca_st  <= trca_st;
	 	       	tras_st  <= tras_st;
        		   	trcd_st  <= 1'b0;

	  end							// ------------ +
	else if(w_rd_wait)
	  begin
				write_st <= 1'b0;
		   	   	read_st  <= read_st;
				twr_st 	 <= twr_st;
				trp_st   <= trp_st;
				trca_st  <= trca_st;
	 	       	tras_st  <= 1'b1;
        		   	trcd_st  <= 1'b0;

	  end	
	else if(w_burstx)
	  begin
				write_st <= 1'b0;
		   	   	read_st  <= 1'b0;
				twr_st 	 <= twr_st;
				trp_st   <= trp_st;
				trca_st  <= trca_st;
	 	       	tras_st  <= tras_st;
        		   	trcd_st  <= trcd_st;

	  end
	else
 	 begin
				write_st 	<= write_st;
				read_st  	<= read_st;
				twr_st		<= twr_st;	
				trp_st 		<= trp_st ;
				trca_st  	<= trca_st;
				tras_st		<= tras_st;
				trcd_st		<= trcd_st;  		
	  end

     end

always @ (state or twr_end or trp_end or trcd_end or wr_end or rd_end1 or wen or ren or sdr_en or Rprech
	 or sdr_sel or sdr_reqL or rowActed or burstPage  or adrChg or AdrCntOvf or wr_chk or twr_st or
	 ReqEndW or ReqEnd or bl or bnkSel or pgEnd or Endbt1bl8 or AdrCntOvfR)
begin
     case(state)

       s_prech          : begin
						n_state = s_prechwait;
		          end

	s_prechwait    :     if(trp_end)
			    	n_state = s_idle;
			     else	
			    	n_state = s_prechwait;

	s_idle        :  begin
				 if(!bnkSel)
			   		n_state = s_idle;					
				 else if(ReqEnd & bl==9'h01)
			   		n_state = s_prech;			//prech rm bcaz of Apre
				 else if(ReqEnd)
			   		n_state = s_idle;//prech;		//prech rm bcaz of Apre
			     else if((wen && !twr_st) | ren)		
			   		n_state = s_act_row;

				 else if(!adrChg & wen & !ren & rowActed&!ReqEnd)
				    n_state = s_write;
 			     else if(!adrChg & !wen & ren & rowActed&!ReqEnd)
				    n_state = s_read;
			     else
			   		n_state = s_idle;
		 	  end

	s_trcd_delay   : begin
			   if(wen && trcd_end)				
			   	n_state = s_write;
			   else if(ren && trcd_end)			
			   	n_state = s_read;
			   else
			   	n_state = s_trcd_delay;
			 end

	s_act_row	: begin
			   	n_state = s_trcd_delay;
			  end
	s_trcd_delay	: begin
			   if(wen && trcd_end)		
			   	n_state = s_write;
			   else if( ren && trcd_end)		
			   	n_state = s_read;
			   else
			   	n_state = s_trcd_delay;
			  end
			  		
	s_write  	: begin	
				if(AdrCntOvf)
 				    n_state =  (sdr_sel) ? s_prech : s_wr_end;
		  	  else if(ReqEndW|ReqEnd)
					n_state = s_idle;
			    else if((bl==9'h01)|(bl==9'h02&!sdr_sel))
					n_state = s_write;
				else
		    		n_state = s_wr_wait;
		          end
	s_wr_wait   	: begin
			  if(Endbt1bl8)
				n_state = s_burstx;	
			  else	if(ReqEndW|ReqEnd)
					n_state = s_idle;
			  else if(AdrCntOvf|(wr_end & adrChg))
 				    n_state =  (sdr_sel) ? s_prech : s_wr_end;
		  	  else if(pgEnd | wr_end | wr_chk |(wr_end &sdr_reqL))
			    	n_state = (!burstPage) ? s_write : s_burstx;
			  else
			    	n_state = s_wr_wait;
				
        	       	  end
	s_wr_end : begin
			if(twr_end)
				n_state =  s_prech;
			else
				n_state =  s_wr_end;
		  end
			
  	s_read       	: begin
			   			
 				    n_state =  (AdrCntOvfR) ? s_prech : s_rd_wait;
					
                       	  end

	s_rd_wait    	: begin
			  if(Endbt1bl8)
				n_state = s_burstx;	
			  else if(ReqEndW|ReqEnd)
					n_state = s_idle;
			  else if(AdrCntOvfR)
 				    n_state =  s_prech;
		   	  else if(pgEnd | rd_end1 | adrChg | wr_chk)
			    	n_state = (!burstPage) ? s_read : s_burstx;
			  else
			    	n_state = s_rd_wait;

		       	  end

	s_burstx    	: begin
         		  if(burstPage|Endbt1bl8r)
			  	n_state = s_prech;
			  else				
			  	n_state = s_idle;
 		          end
	default      	: 	n_state = s_idle;

	endcase
end

always @ (posedge clk or  negedge rst2)
if(!rst2)
 begin
	state  <= s_idle;
 end
else if(!bnkSel|!sdr_req|ReqAckL)		
 begin
	state  <= s_idle;
 end
else
 begin
	state  <= n_state;
 end
wire  read_st2      = (read_st|read_st1);//^read_st)&read_st;//

								//calc # of bytes & bursts
assign	cmd_out_pbl = (w_prech)	?	((auto_prech) ? `C_NOP  : `C_PRECHARGE)		:
		  	  (w_write)	?	`C_WRITEA		:
		      (w_read)	?	`C_READA		:
		      (w_burstx)	?	`C_BURST_STOP		:
		      (w_act_row)	? 	`C_ACT_ROW		:
		      (w_idle)	?	`C_NOP			:  `C_NOP;
//!!
assign	cmd_out_sla = (w_prech)	?	((auto_prech) ? `C_NOP  : `C_PRECHARGE)		:
		  	  (write_st)	?	`C_WRITEA		:
		      (w_read)	?	`C_READA		:
		      (w_burstx)	?	`C_BURST_STOP		:
		      (w_act_row)	? 	`C_ACT_ROW		:
		      (w_idle)	?	`C_NOP			:  `C_NOP;

assign	cmd_out     = (SLA) ? cmd_out_sla : cmd_out_pbl;
endmodule
