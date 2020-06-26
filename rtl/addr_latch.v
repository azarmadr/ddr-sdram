/////////////////////////////////////////////////////////////////////////////
//     									   //
//  Copyright(c) 2002 iPlay Networks P. Ltd.All Rights Reserved. 	   //
//  This document contain information which is both confidential and 	   //
//  proprietary to  iPlay Networks P. Ltd.	               		   //
//                  Himayat Nagar Hyderabad. India.  011-91-40-4076669     //
//     									   //
/////////////////////////////////////////////////////////////////////////////
// Filename: address_latch.v                                               //        
//		  							   //
// Author: Saji Sebastian              				           //
//     									   //
// Description : Address Latch Module       		                   //
//  Rev1.4     : 19 August 2002    				           //	
//	        			                                   //
/////////////////////////////////////////////////////////////////////////////


module addr_latch(

   // Outputs
   	sdc_ad, sdc_ba, cas_lat_max, cas_lat_half, burst_2,burst_4,
   	burst_8,burst_p,auto_prech,adrChg,AdrCntOvf,RowOvfOut,OvFlSet,
   // Inputs
    	clk,clk2x, reset1,u_addr,mode_reg,Mrow_addr, row_addr, mrs_addr,StWrRd,
	init_done,AdrCntSt,enAp,rdAdr,sdr_req,sdr_req_wr_n,sdc_sel,bl,req_ack,extMR,SLA
   );

   output [`SDC_ADDR_MSB:0] 	sdc_ad;             // address o/p of controller
   output [1:0] 	    	cas_lat_max;        // cas latency count o/p
   output [1:0]		    	cas_lat_half;       // cas o/p for .5
   output [1:0] 	    	sdc_ba;		    // bank address o/p	
   output 		    	burst_2,            // burst length 2
				burst_4, 	    // burst length 4	
				burst_8,            // burst length 8
				burst_p,            // full page burst    
				auto_prech,         // auto_prech out
				adrChg,		    // addr change	
				AdrCntOvf,	    // adr cnt overflow	
				RowOvfOut,	    // row end
				OvFlSet;
   input 		    	clk,clk2x;          // clks
   input 		    	reset1;		    // reset	
   input [`U_ADDR_MSB:0]    	u_addr;		    // address i/p from host 
   input [`SDC_ADDR_MSB:0]	mode_reg;	    // mod reg data	

   input 		    	Mrow_addr,
				row_addr;           // row address select
   input 		    	StWrRd,
				mrs_addr;    	    // mode reg select
   input 		    	init_done,	    // initialization done
				AdrCntSt,	    // start addr counter	
				enAp,		    // enable auto precharge	
				rdAdr,		    // increment addr cnt	
				sdr_req,            // next rd/wr request		 
				sdr_req_wr_n,	    // 0 - wr , 1 - rd
				sdc_sel,	    // select sdr/ddr 1-sdr.0-ddr 	
				req_ack,
				extMR,
				SLA;        //!!19-12-02
   input [8:0]			bl;		    // burst length	

   parameter MAXROWS = 12'hFFF,
	     SDRCOLS = 12'h1FF,
	     DDRCOLS = 12'hFF;

   wire  [`SDC_ADDR_MSB:0] 	sdc_ad;
   wire  [1:0] 			sdc_ba;
   wire  [`U_ADDR_MSB:0]    	u_addr;
   wire  [`SDC_ADDR_MSB:0]	mode_reg;

   wire   			Mrow_addr,row_addr,clk,clk2x,reset1,mrs_addr,StWrRd,init_done,
				AdrCntSt,sdr_req,sdr_req_wr_n,sdc_sel,req_ack,enAp,rdAdr,extMR,SLA;

   reg  [1:0] 			next_cas_lat_max, cas_lat_max;
   reg 			    	next_cas_lat_half;
   reg  [1:0] 		    	cas_lat_half;
   wire [2:0] 		    	sdc_burst_length;
   wire [2:0] 		    	sdc_cas_latency;
   
   reg 			   	burst_2,burst_4,burst_8,burst_p,mrs_addr1;
   reg 			    	next_burst_2, next_burst_4, next_burst_8,next_burst_p;
   reg  [`U_ADDR_MSB:0]    	u_addr1,u_addr2,u_addr3;
   reg 				init1,init2;
 
   reg  [11:0] 			AdrCnt,RdAdrCnt;
   reg				AdrCntSt1,AdrCntSt2,AdrCntSt3,AdrCntSt4,row_addr1,
				StWrRd1,RowOvfOut,RowOvfOut1;
   reg [2:0]			CasCnt;
   reg				SrdOvfD,DrdOvfD;

   reg 				OvFlSet;
   reg [`U_ADDR_MSB:`U_ADDR_MSB-1]
				bankAdr;
   reg [`U_ADDR_MSB-2:`COL_ADDR_MSB]
				rowAdr;
   reg [`COL_ADDR_MSB-1:0]	colAdr;
   reg 				adrChg,sdr_reqD,sdr_req1;
   reg [7:0]			SRowOvf;
   wire[8:0]			bl;
   wire burst_1;

   assign sdc_burst_length = mode_reg[2:0];
   assign sdc_cas_latency  = mode_reg[6:4];
   assign burst_1 = !burst_2&!burst_4&!burst_8&!burst_p;

   always  @(posedge clk)
   begin
    if(reset1)
     begin	
	mrs_addr1	<= 1'b0;
	burst_2	 	<= 1'b0;
	burst_4	 	<= 1'b0;
	burst_8  	<= 1'b0;
	burst_p  	<= 1'b0;
	
	row_addr1	<= 1'b0;
	AdrCntSt1	<= 1'b0;
	AdrCntSt2	<= 1'b0;
	AdrCntSt3	<= 1'b0;
	AdrCntSt4	<= 1'b0;
	StWrRd1  	<= 1'b0;
	RowOvfOut1	<= 1'b0;
	RowOvfOut 	<= 1'b0;
	SrdOvfD		<= 1'b0;
	DrdOvfD		<= 1'b0;
	init1	 	<= 1'b0;
	init2	 	<= 1'b0;

   	next_burst_2 	<= 1'b0;
	next_burst_4 	<= 1'b0; 
	next_burst_8 	<= 1'b0;
        next_burst_p 	<= 1'b0;

	AdrCnt	 	<= 12'h000;
	RdAdrCnt	<= 12'h000;
        CasCnt	 	<= 3'b000;

     end
    else
     begin	
       	mrs_addr1 	<= mrs_addr;
    	burst_2 	<= next_burst_2;
	burst_4 	<= next_burst_4;
	burst_8 	<= next_burst_8;
	burst_p 	<= next_burst_p;
	row_addr1	<= row_addr;
	AdrCntSt1	<= AdrCntSt;
	AdrCntSt2	<= AdrCntSt1;
	AdrCntSt3	<= AdrCntSt2;
	AdrCntSt4	<= AdrCntSt3;
	StWrRd1	 	<= StWrRd;
	RowOvfOut1	<= RowOvfD;
	RowOvfOut 	<= RowOvfOut1;
	SrdOvfD 	<= SrdOvf;
	DrdOvfD 	<= DrdOvf;
	init1	 	<= init_done;
	init2	 	<= init1;


   if(!sdr_req)	
    begin
	AdrCnt	 	<= 12'h000;
	RdAdrCnt	<= 12'h000;	
    end
   else
    begin  								// adr for rd/wr for sdr	
       AdrCnt  		<= (sdc_sel) ? 	((!sdr_req_wr_n)
			    	     ? 	((AdrCntSTART) ? (AdrCnt + 12'h001) : {3'h0,colAdr}) ://wr
			      		    ((!AdrCntSTART)? {3'h0,colAdr} :					  //rd
							  ((rdAdr) ? ({3'h0,bl}+AdrCnt) : AdrCnt) )	)

  			    	     :				// adr for rd/wr for ddr
			      		(!AdrCntSTART)? {3'h0,colAdr} : 
     					(!sdr_req_wr_n) ? ((rdAdr) ? ({3'h0,bl}+AdrCnt) : AdrCnt):
			  		(rdAdr)   ? ({3'h0,bl}+AdrCnt) : AdrCnt ;

      RdAdrCnt		<=	(sdr_req_wr_n)
			    	     ?   ((!AdrCntSTART)? {3'h0,colAdr} : (rdSt) ? (RdAdrCnt + 12'h001) 
							   	:RdAdrCnt) :RdAdrCnt;

     end

	CasCnt  	<= (!AdrCntSt) ?  ((sdc_sel) ? sdc_cas_latency-3'h1:sdc_cas_latency+3'h0 ) : 
 		 	   (CasEnd) ? 3'h00 :CasCnt-3'h1;

     case (sdc_burst_length)
 
	3'h0 :{next_burst_p,next_burst_2,next_burst_4,next_burst_8} <= 4'h0;
	3'h1 :{next_burst_p,next_burst_2,next_burst_4,next_burst_8} <= 4'h4;
	3'h2 :{next_burst_p,next_burst_2,next_burst_4,next_burst_8} <= 4'h2;
	3'h3 :{next_burst_p,next_burst_2,next_burst_4,next_burst_8} <= 4'h1;
	3'h7 :{next_burst_p,next_burst_2,next_burst_4,next_burst_8} <= 4'h8;
     endcase
   end 
 end

   always @(posedge clk)
   begin
   if(!init2)
     begin	
	u_addr1 <= {`U_ADDR_MSB+1{1'b0}};
	u_addr2 <= {`U_ADDR_MSB+1{1'b0}};
	u_addr3 <= {`U_ADDR_MSB+1{1'b0}};
     end
   else
    begin	
	u_addr1 <= u_addr;
	u_addr2 <= u_addr1;
	u_addr3 <= u_addr2;
     end
   end
   
   //generate cas_latency_max, cas_lat_half
   always @(sdc_cas_latency)
     case (sdc_cas_latency) 
       3'b011:  begin
	  next_cas_lat_max  = 2'b10; //cas_lat = 3	//...max = 3-1 =2 
	  next_cas_lat_half = 1'b0;			//...3rd bit ==0 no decimal
       end
       3'b101:  begin
	  next_cas_lat_max  = 2'b00; //cas_lat = 1.5
	  next_cas_lat_half = 1'b1;
       end
       3'b110:  begin
	  next_cas_lat_max  = 2'b01; //cas_lat = 2.5
	  next_cas_lat_half = 1'b1;
       end
       default: begin
	  next_cas_lat_max  = 2'b01; //cas_lat = 2
	  next_cas_lat_half = 1'b0;
       end
     endcase 

   always @(posedge clk2x)
    begin
      if (reset1)
	begin
	 cas_lat_max  	<= 2'b00;
         cas_lat_half   <= 2'b00;
	 bankAdr	<= 2'b00;
	 rowAdr		<= 12'h000;
	 colAdr		<= 9'h00;

	 OvFlSet 	<= 1'b0;
	 adrChg  	<= 1'b0;
	 SRowOvf 	<= 8'h00;
	 sdr_req1	<= 1'b0;
	 sdr_reqD	<= 1'b0;

       	end
      else 
	begin
	 cas_lat_max 	<= next_cas_lat_max;
	 cas_lat_half 	<= {2{next_cas_lat_half}};
         SRowOvf 	<= {SRowOvf[6:0],RowOvf};
	 sdr_req1	<= sdr_req;
	 sdr_reqD	<= (sdr_req^sdr_req1)&sdr_req;
	
	if(sdr_reqD | Mrow_addr)
	begin
	 bankAdr 	<=  u_addr[`U_ADDR_MSB:`U_ADDR_MSB-1];
	 rowAdr  	<=  u_addr[`U_ADDR_MSB-2:`COL_ADDR_MSB];
	 colAdr  	<=  u_addr[`COL_ADDR_MSB-1:0];
	end
	else
	begin
	 bankAdr 	<= (RowOvfD) ? (bankAdr+2'b01) : bankAdr;
	 rowAdr  	<= (RowOvfD) ? 12'h000 :
				   (AdrCntOvf&!OvFlSet) ? (rowAdr+12'h1) : rowAdr;  		
	 colAdr  	<= (AdrCntOvf) ? (9'h000) : colAdr;
	    end

	if(AdrCntOvf)
	    OvFlSet 	<= 1'b1;
	else if(OvFlRst|req_ack|sdr_reqD)
	    OvFlSet 	<= 1'b0;

	  adrChg 	<= 1'b0;
	 end
    end
  wire c2  = (sdc_cas_latency===3'b010);
  wire c3  = (sdc_cas_latency===3'b011);

  wire pag  = burst_p & AdrCntSt4;  
  wire rdSt = (!SLA) ? (pag|(c3& AdrCntSt4)|(c2& AdrCntSt3)) //!! SIngle loc. access
                     : AdrCntSt;  
  
		//--==>23 bits  ba(2)+ row(12)+ col(9)

  assign sdc_ba =  (extMR) ? 2'b01 : bankAdr;
  assign sdc_ad = (mrs_addr) ? mode_reg :
                  (Mrow_addr)? (12'h400|(u_addr[`U_ADDR_MSB-2:`COL_ADDR_MSB]))       :
		  (row_addr) ? (rowAdr) : 
		  ((EAP) ? (12'h400|AdrCnt):AdrCnt); //enApre @ end of write/rd

 wire EAP 	= 	(enAp)|((burst_2) ? pDc3bl2 :StWrRd1&rdOvf);

 wire pDc3bl2   = (!sdr_req_wr_n&!sdc_sel&(StWrRd1&(StWrRd^StWrRd1)));

 wire rdOvf	= (!sdc_sel) ?  DrdOvf : 1'b0;//SrdOvf;//!!
 wire auto_prech= (!burst_p & StWrRd) ? sdc_ad[10]: 1'b0;   // check prech bit in adr

 									//->!!29/8/02-17.00
 wire AdrCntOvf = (sdc_sel)? ((sdr_req_wr_n) ? SrdOF: (AdrCnt == SDRCOLS-12'h001))
			   :      (DrdOvf);//!28/8/02

 wire SrdOF = (burst_4&c2)? (SrdOvfD^SrdOvf)&SrdOvfD :
	   (burst_4|burst_p|burst_8) ?(SrdOvfD^SrdOvf)&SrdOvf :(SrdOvfD^SrdOvf)&SrdOvfD ;//!!29/8/02-17.00
							   //->!!29/8/02-17.00

 wire SrdOvf = (burst_2) ? (AdrCnt >= SDRCOLS-12'h004 && AdrCnt <= SDRCOLS) :
	       (burst_1) ? (AdrCnt >= SDRCOLS-12'h003 && AdrCnt < SDRCOLS) :
               (burst_4&c2) ? (RdAdrCnt >= SDRCOLS-12'h004 && RdAdrCnt < SDRCOLS-12'h001) :
	       (burst_8&c2) ? (RdAdrCnt > SDRCOLS-12'h004 && RdAdrCnt < SDRCOLS) :
	       (burst_p&c2) ? (RdAdrCnt > SDRCOLS-12'h004 && RdAdrCnt < SDRCOLS) ://!!``
		RdAdrCnt > SDRCOLS-12'h005 && RdAdrCnt < SDRCOLS; 

 wire DrdOF  =  (burst_4) ?(DrdOvf^DrdOvfD)&DrdOvfD :DrdOvf;

 wire DrdOvf =  (bl==9'h02) ? ((!sdr_req_wr_n) ? (AdrCnt >= DDRCOLS-12'h003):(AdrCnt >= DDRCOLS)):
		(bl==9'h04) ? ((!sdr_req_wr_n) ? (AdrCnt >= DDRCOLS-12'h003):(AdrCnt >= DDRCOLS)):
		(!sdr_req_wr_n) ? (AdrCnt > DDRCOLS-12'h005):(AdrCnt > DDRCOLS-12'h002); 

 					//needs to be checked for each burst
 wire OvFlRst = (burst_p) ?(AdrCnt > 12'h010 &AdrCnt <12'h020) :
		(burst_8) ?(AdrCnt > 12'h007 &AdrCnt <12'h010) :
		(burst_4) ?(AdrCnt > 12'h003 &AdrCnt <12'h009) :
		(burst_2) ?(AdrCnt > 12'h001 &AdrCnt <12'h008) :
		(AdrCnt > 12'h001 &AdrCnt <12'h003);
 wire NxtAdrWr = !(AdrCntSt1);
 wire RowOvf   = ((rowAdr == MAXROWS)& AdrCntOvf);
 wire RowOvfD = SRowOvf[7];
 wire AdrCntSTART = ((sdc_sel) ? ((sdr_req_wr_n) ? (AdrCntSt ) : AdrCntSt1) //for sdr 
			      : ((!sdr_req_wr_n) ? (AdrCntSt1) : AdrCntSt)) ;	   //for ddr!!##

 wire CasEnd	 = (CasCnt==3'b000);
 wire [`COL_ADDR_MSB-1:0]	colAdrW;
 wire ddrCnt = StWrRd&(StWrRd1^StWrRd);


endmodule // addr_latch


//-------------------------------------/\/\/\/\--------------------------------------------//



