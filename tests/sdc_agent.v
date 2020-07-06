/////////////////////////////////////////////////////////////////////////////
//     									   //
//  Copyright(c) 2002 iPlay Networks P. Ltd.All Rights Reserved. 	   //
//  This document contain information which is both confidential and 	   //
//  proprietary to  iPlay Networks P. Ltd.	               		   //
//                  Himayat Nagar Hyderabad. India.  011-91-40-4076669     //
//     									   //
/////////////////////////////////////////////////////////////////////////////
// Filename: sdc_agent.v                                                   //
//		  							   //
// Author: Saji Sebastian              				           //
//     									   //
// Description : Agent File     		                           //
// Rev1.4     : 19 August 2002    				           //
//	        			                                   //
/////////////////////////////////////////////////////////////////////////////

`include"define.v"
module sdc_agent(

   //.....outputs......
   mclk,s_resetn,sdc_req,sdc_req_adr,sdc_req_len,sdc_req_wr_n,sdc_wr_data,
   sdc_wr_en_n,sdc_en,	sdc_mode_reg,sdc_tras_d,sdc_trp_d,sdc_trcd_d,
   sdc_cas,sdc_trca_d,sdc_twr_d,sdc_rfrsh,sdc_rfmax,sdc_sel,

   //.....inputs.......
   sdc_clk, sdc_req_ack,sdc_rd_data, sdc_rd_valid,
   sdc_wr_next,sdc_init_done

	);

  output		mclk,
			s_resetn,
			sdc_req;
  output [`U_ADDR_MSB:0]
			sdc_req_adr;
  output	[1:0]	sdc_req_len;
  output		sdc_req_wr_n;

  output  [`U_DATA_MSB:0]
			sdc_wr_data;
  output  [3:0]		sdc_wr_en_n;

  output		sdc_en;

  output  [`SDC_ADDR_MSB:0]
			sdc_mode_reg;

  output  [3:0]		sdc_tras_d,
			sdc_trp_d,
			sdc_trcd_d;
  output  [2:0]		sdc_cas;

  output  [3:0]		sdc_trca_d,
			sdc_twr_d;
  output  [11:0]	sdc_rfrsh;
  output  [2:0]		sdc_rfmax;
  output 		sdc_sel;

  input [`U_DATA_MSB:0]
         		sdc_rd_data;

  input			sdc_init_done;
  input			sdc_req_ack,
			sdc_rd_valid,
			sdc_wr_next,
			sdc_clk;



  reg		mclk,
		s_resetn,
		sdc_req;
  reg [`U_ADDR_MSB:0]
		sdc_req_adr;
  reg	[1:0]	sdc_req_len;
  reg		sdc_req_wr_n;

  reg  [`U_DATA_MSB:0]
		sdc_wr_data;
  reg  [3:0]	sdc_wr_en_n;

  reg		sdc_en;

  reg  [`SDC_ADDR_MSB:0]
		sdc_mode_reg;

  reg  [3:0]	sdc_tras_d,
		sdc_trp_d,
		sdc_trcd_d;
  reg  [2:0]	sdc_cas;

  reg  [3:0]	sdc_trca_d,
		sdc_twr_d;
  reg  [11:0]	sdc_rfrsh;
  reg  [2:0]	sdc_rfmax;
  reg 		sdc_sel;

  wire [`U_DATA_MSB:0]
         	sdc_rd_data;

  wire		sdc_init_done;
  wire		sdc_req_ack,
		sdc_rd_valid,
		sdc_wr_next,sdc_clk;
  integer 	j,k;

reg  [31:0]mem_wr[0:511];
reg  [31:0]mem_rd[0:511];
reg [3:0]bl;

`ifdef debug
wire debug = 1;
`else
wire debug = 0;
`endif


//-------------------------------------------------//
parameter SDR_ModCas3BLP = 12'h037,
	  SDR_ModCas3BL8 = 12'h033,
	  SDR_ModCas3BL4 = 12'h032,
	  SDR_ModCas3BL2 = 12'h031,
	  SDR_ModCas3BL1 = 12'h030,

	  SDR_ModCas2BLP = 12'h027,
	  SDR_ModCas2BL8 = 12'h023,
	  SDR_ModCas2BL4 = 12'h022,
	  SDR_ModCas2BL2 = 12'h021,
	  SDR_ModCas2BL1 = 12'h020,

	  SDR_ModCas25BL8= 12'h063,
	  SDR_ModCas25BL4= 12'h062,
	  SDR_ModCas25BL2= 12'h061,

	  DDR_ModCas3BL8 = 12'h033;



parameter ClkHP	 = 2.5,			//clk high time
	  MClkTP = 2*ClkHP,
	  SClkTP = 2*MClkTP;

parameter	REQLEN3 		= 4'h3,
		REQLEN2 		= 4'h2,
		REQLEN1 		= 4'h1,
		REQLEN0 		= 4'h0,
`ifdef XS
		ADDRESS0		= 23'h1FF_FF8,
		ADDRESS1		= 23'h2FF_FF8,
		ADDRESS2		= 23'h4FF_FF8,
		ADDRESS3		= 23'h6FF_FF8,
`else
`ifdef XD
		ADDRESS0		= 23'h1FF_EF8,
		ADDRESS1		= 23'h2FF_EF8,
		ADDRESS2		= 23'h4FF_EF8,
		ADDRESS3		= 23'h6FF_EF8,
`else
		ADDRESS0		= 23'h000_200,
		ADDRESS1		= 23'h200_400,
		ADDRESS2		= 23'h400_600,
		ADDRESS3		= 23'h600_000,
`endif
`endif

		ADDRESS0XS		= 23'h1FF_FF8,
		ADDRESS1XS		= 23'h2FF_FF8,
		ADDRESS2XS		= 23'h4FF_FF8,
		ADDRESS3XS		= 23'h6FF_FF8,

		ADDRESS0XD		= 23'h1FF_EF8,
		ADDRESS1XD		= 23'h2FF_EF8,
		ADDRESS2XD		= 23'h4FF_EF8,
		ADDRESS3XD		= 23'h6FF_EF8;

//-------------------------------------------------//


wire [1:0]sft	 = (bl==4'h8) ? 2'b11:
		   (bl==4'h4) ? 2'b10:
		   (bl==4'h2) ? 2'b01:2'b00;
reg [2:0]beat;
reg [7:0]byte;
reg [7:0]bustNT;
reg [7:0]bustN;
reg sdc_req_ack1,sdc_req_ack2,chk;

wire burstPage = (sdc_mode_reg[2:0] == 3'b111);

wire [7:0]Plen  = 	(burstPage)           ?
			((sdc_req_len==2'b00) ? 8'h04 :
		  	(sdc_req_len==2'b01)  ? 8'h08 :
		  	(sdc_req_len==2'b10)  ? 8'h10 :
		  	(sdc_req_len==2'b11)  ? 8'h20 : 8'h10) :8'h00;
always @(mclk)
begin
        	bl   =      ( sdc_mode_reg[2:0] == 3'b000) ? 4'h1 :
			    ( sdc_mode_reg[2:0] == 3'b001) ? 4'h2 :
 	                    ( sdc_mode_reg[2:0] == 3'b010) ? 4'h4 :
             	 	    ( sdc_mode_reg[2:0] == 3'b011) ? 4'h8 :
	                    ( sdc_mode_reg[2:0] == 3'b111) ? 4'hff : 4'h8;

		beat	 	= sdc_req_len + 3'b001;	//# of beat = len + 1
		byte   	= (8'h08)  << beat;
		bustNT 	= (byte)   >> 2;
		bustN  	= (bustNT) >>sft ;
end

always @(mclk)
begin
	sdc_req_ack1 <= #SClkTP sdc_req_ack;
	sdc_req_ack2 <= #SClkTP sdc_req_ack1;
end

always @(posedge sdc_req_ack)
	sdc_req = 1'b0;

wire [`U_ADDR_MSB:`U_ADDR_MSB-1]bankAdr;
wire [`U_ADDR_MSB-2:`COL_ADDR_MSB]rowAdr;
wire [`COL_ADDR_MSB-1:0] colAdr;

assign {bankAdr,rowAdr,colAdr}=sdc_req_adr;


//-------generate clock-------------

always
	#ClkHP mclk = ~mclk;

 task initialize_sdr_ddr;
   input [11:0]mod_reg;
   input sel;
   begin
if(debug)
   $display("\t\t+---------------------+\n\t\t| INITIALIZING SDRAM  |\n\t\t+---------------------+");

		j=0;k=0;
		mclk 			<= 1'b0;
		s_resetn 		<= 1'b0;
		sdc_req			<= 1'b0;
  		sdc_req_adr		<= 23'h080000;
  		sdc_req_len		<= 2'b00;
  		sdc_req_wr_n	        <= 1'b0;
		sdc_wr_data		<= 32'h0000;
  		sdc_wr_en_n		<= 4'h0;
		sdc_en			<= 1'b1;

  		sdc_mode_reg	        <= 12'h000;
  		sdc_tras_d		<=	4'hF;
		sdc_trp_d		<=	4'h8;
		sdc_trcd_d		<=	4'h3;
//  		sdc_cas			<=	3'b011;

  		sdc_trca_d		<=	4'hA;
		sdc_twr_d		<=	4'h2;
	 	sdc_sel			<=  sel;
  		sdc_rfrsh		<=	12'h07f;//61B;//-1563-clk cycS for 15.625uS//(sel) ? 12'h001f : 12'h00f;
  		sdc_rfmax		<=	3'b011;
	   #MClkTP s_resetn  = 1'b1;

//#(115*MClkTP);

//#(10420*SClkTP);
wait(sdc_init_done);
	sdc_mode_reg     =  (sdc_init_done) ? mod_reg :12'h000;//_is_necessary?
	sdc_cas			 = sdc_mode_reg[6:4];
#SClkTP;
#SClkTP;
#SClkTP;
end
 endtask

//-------------------------------------------------//
task reset_sdr;
 begin
if(debug)
	$display("\t\t+-------------+\n\t\t|   -RESET-   |\n\t\t+-------------+ ");
#(5*SClkTP);
    	s_resetn  = 1'b0;
	#(20*SClkTP);
	s_resetn  = 1'b1;
 end
endtask

//-------------------------------------------------//
task sdram_write;
   input [22:0]addr;
   input [1:0]req_len;
   integer l,m;
   reg [3:0]bt;
   begin
      sdc_req_len            = req_len;
      sdc_req_adr            = addr;
      repeat(3) @(posedge sdc_clk);
      {sdc_req,sdc_req_wr_n} = 2'b10;
      bt = req_len+1'b1;
      if(debug) $display("\t\t+------------------------+\n\t\t|REQ.LEN-%d BEAT-%d:WRITE |\n\t\t+------------------------+",req_len,bt);

      wait(sdc_wr_next);


//while(sdc_wr_next)begin
      if(!burstPage)
      begin

	 for(l=0;l<bustN;l=l+1)
	 begin
	    for(m=0;m<bl;m=m+1)
	    begin
	       sdc_wr_data  = m+l*8;
	       @(posedge sdc_clk);//!!
	       #SClkTP;
	    end
	 end
      end
      else    for(m=0;m<Plen;m=m+1)
      begin
	 @(posedge sdc_clk)//!!
	 sdc_wr_data  = m;
         //#SClkTP;
      end
//   end
   #SClkTP;
   end
endtask
//always@(posedge sdc_rd_valid) $display("\nsdc.rd.valid@",$time);
//always@(posedge sdc_wr_next) $display("\nsdc.wr.next@",$time);
//always@(posedge sdc_req_ack) $display("\nsdc.req.ack@",$time);
//always@(negedge sdc_req_ack) $display("\nsdc.req.ack@",$time);
//-------------------------------------------------//
task sdram_read;
   input [22:0]addr;
   input [1:0]req_len;
   integer l,m;
   reg [3:0]bt;
   begin
   sdc_req_len		= req_len;
   sdc_req_adr	 	= addr;
      @(posedge sdc_clk)
   {sdc_req,sdc_req_wr_n} = 2'b11;
   bt = req_len+1'b1;
   #SClkTP;
   if(debug)
      $display("\t\t+-----------------------+\n\t\t|REQ.LEN-%d BEAT-%d:READ |\n\t\t+-----------------------+",req_len,bt);
wait(sdc_rd_valid);
while(sdc_rd_valid)begin
   if(!burstPage)
   begin
      for(l=0;l<1;l=l+1)//bustN;l=l+1)
      begin
	 for(m=0;m<bl;m=m+1)begin
	    #SClkTP;
	 end
      end
   end
   else    for(m=0;m<Plen;m=m+1)#SClkTP;
end
end
 endtask


//-------------------------------------------------//
 task sdram_writeDM;
  input [22:0]addr;
  input [1:0]req_len;
  input [3:0] DM;
  integer l,m;
  reg [3:0]bt;
  begin
         sdc_wr_en_n            = DM;
	 sdc_req_len		= req_len;
	{sdc_req,sdc_req_wr_n} = 2'b10;
 	 sdc_req_adr	 	= addr;
         bt = req_len+1'b1;
	 if(debug)
	    $display("\t\t+----------------------------+\n\t\t|REQ.LEN-%d BEAT-%d:WRITE DM-%d|\n\t\t+----------------------------+",req_len,bt,sdc_wr_en_n);
wait(sdc_wr_next);


if(!burstPage)
begin
   for(l=0;l<bustN;l=l+1)
   begin

     for(m=0;m<bl;m=m+1)
     begin
     @(posedge sdc_clk)//!!
	sdc_wr_data  = m;
     //	mem_wr[k]    = k;
     #SClkTP;
      end
  end
end
else    for(m=0;m<Plen;m=m+1)
      begin
     @(posedge sdc_clk)//!!
	sdc_wr_data  = m;
//        #SClkTP;
      end

//  #300;

  end
 endtask
//-------------------------------------------------//
 task sdram_readDM;
  input [22:0]addr;
  input [1:0]req_len;
  input [3:0] DM;
  integer l,m;
  reg [3:0]bt;
  begin
         sdc_wr_en_n            = DM;
	 sdc_req_len		= req_len;
	{sdc_req,sdc_req_wr_n} = 2'b11;
 	 sdc_req_adr	 	= addr;
	 bt = req_len+1'b1;
if(debug)
$display("\t\t+-----------------------------+\n\t\t|REQ.LEN-%d BEAT-%d:READ DM-%d|\n\t\t+----------------------------+",req_len,bt,sdc_wr_en_n);
#100;

if(!burstPage)
begin
for(l=0;l<bustN;l=l+1)
  begin
    for(m=0;m<bl;m=m+1)
      begin
	sdc_wr_data  = m;
//	mem_wr[k]    = k;
        #SClkTP;
      end
  end
end
else    for(m=0;m<Plen;m=m+1)
      begin
	sdc_wr_data  = m;
        #SClkTP;
      end

  end
 endtask
//-------------------------------------------------//

 task refresh_test;
  begin
	sdc_en	= 1'b0;
  end
 endtask


//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
`include "Testcases/test1_Sc3bl8.v"
`include "Testcases/test2_Sc3bl4.v"
`include "Testcases/test3_Sc3bl2.v"
`include "Testcases/test4_Sc3bl1.v"
`include "Testcases/test5_Sc3blP.v"
`include "Testcases/test6_Sc2bl8.v"
`include "Testcases/test7_Sc2bl4.v"
`include "Testcases/test8_Sc2bl2.v"
`include "Testcases/test9_Sc2bl1.v"
`include "Testcases/test10_Sc2blP.v"
`include "Testcases/test11_Dc3bl8.v"
`include "Testcases/test12_Dc3bl4.v"
`include "Testcases/test13_Dc3bl2.v"
`include "Testcases/test14_Dc2bl8.v"
`include "Testcases/test15_Dc2bl4.v"
`include "Testcases/test16_Dc2bl2.v"
`include "Testcases/test17_Dc25bl8.v"
`include "Testcases/test18_Dc25bl4.v"
`include "Testcases/test19_Dc25bl2.v"
`include "Testcases/test20_Dc3bl8rwEnd.v"
`include "Testcases/test21_Sc3bl8rwEnd.v"
`include "Testcases/test22_BL2_Interleaved_CAS1.v"
`include "Testcases/test23_BL2_Interleaved_CAS2.v"
`include "Testcases/test24_BL2_Interleaved_CAS3.v"
`include "Testcases/test25_BL4_Interleaved_CAS3.v"
`include "Testcases/test26_BL4_Interleaved_CAS2.v"
`include "Testcases/test27_BL4_Interleaved_CAS1.v"
`include "Testcases/test28_BL8_Interleaved_CAS2.v"
`include "Testcases/test29_BL8_Interleaved_CAS1.v"
`include "Testcases/test30_BL8_Interleaved_CAS3.v"
`include "Testcases/test31_BL2_Sequential_CAS1.v"
`include "Testcases/test32_BL2_Sequential_CAS2.v"
`include "Testcases/test33_BL2_Sequential_CAS3.v"
`include "Testcases/test34_BL4_Sequential_CAS1.v"
`include "Testcases/test35_BL4_Sequential_CAS2.v"
`include "Testcases/test36_BL4_Sequential_CAS3.v"
`include "Testcases/test37_BL8_Sequential_CAS1.v"
`include "Testcases/test38_BL8_Sequential_CAS2.v"
`include "Testcases/test39_BL8_Sequential_CAS3.v"
`include "Testcases/test40_BL_Fullpg_CAS123.v"
`include "Testcases/test41_DataMask_Sequen_Add00.v"
`include "Testcases/test42_DataMask_Interleaved_Add00.v"
`include "Testcases/test_43Single_location_Access.v"
`include "Testcases/test_44_Auto_Refresh.v"
`include "Testcases/test_45_Write_1beat_4banks.v"
`include "Testcases/test_46_Read_1beat_4banks.v"
`include "Testcases/test_47_Write_1beat_2banks.v"
`include "Testcases/test_48_Read_1beat_2banks.v"
//`include "Testcases/test_49_WriteB0_at_endof_row.v"
//`include "Testcases/test_50_WriteB1_at_endof_row.v"
//`include "Testcases/test_51_WriteB2_at_endof_row.v"
//`include "Testcases/test_52_WriteB3_at_endof_row.v"
//`include "Testcases/test_53_ReadB0_at_endof_row.v"
//`include "Testcases/test_54_ReadB1_at_endof_row.v"
//`include "Testcases/test_55_ReadB2_at_endof_row.v"
//`include "Testcases/test_56_ReadB3_at_endof_row.v"
//`include "Testcases/test_57_WriteB0_at_end_row.v"
//`include "Testcases/test_58_WriteB1_at_end_row.v"
//`include "Testcases/test_59_WriteB2_at_end_row.v"
//`include "Testcases/test_60_WriteB3_at_end_row.v"
//`include "Testcases/test_61_ReadB0_at_end_row.v"
//`include "Testcases/test_62_ReadB1_at_end_row.v"
//`include "Testcases/test_63_ReadB2_at_end_row.v"
//`include "Testcases/test_64_ReadB3_at_end_row.v"

initial
begin
chk = 1'b0;

`ifdef t1
test1;

`else
`ifdef t2
test2;

`else
`ifdef t3
test3;

`else
`ifdef t4
test4;

`else
`ifdef t5
test5;

`else
`ifdef t6
test6;

`else
`ifdef t7
test7;

`else
`ifdef t8
test8;

`else
`ifdef t9
test9;

`else
`ifdef t10
test10;

`else
`ifdef t11
test11;

`else
`ifdef t12
test12;

`else
`ifdef t13
test13;

`else
`ifdef t14
test14;

`else
`ifdef t15
test15;

`else
`ifdef t16
test16;

`else
`ifdef t17
test17;

`else
`ifdef t18
test18;

`else
`ifdef t19
test19;

`else
`ifdef t20
test20;

`else
`ifdef t21
test21;

`else
`ifdef t22
test22;

`else
`ifdef t23
test23;

`else
`ifdef t24
test24;

`else
`ifdef t25
test25;

`else
`ifdef t26
test26;

`else
`ifdef t27
test27;

`else
`ifdef t28
test28;

`else
`ifdef t29
test29;

`else
`ifdef t30
test30;

`else
`ifdef t31
test31;

`else
`ifdef t32
test32;

`else
`ifdef t33
test33;

`else
`ifdef t34
test34;

`else
`ifdef t35
test35;

`else
`ifdef t36
test36;

`else
`ifdef t37
test37;

`else
`ifdef t38
test38;

`else
`ifdef t39
test39;

`else
`ifdef t40
test40;

`else
`ifdef t41
test41;

`else
`ifdef t42
test42;

`else
`ifdef t43
test43;

`else
`ifdef t44
test44;

`else
`ifdef t45
test45;

`else
`ifdef t46
test46;

`else
`ifdef t47
test47;

`else
`ifdef t48
test48;

`else
`ifdef t49
test49;

`else
`ifdef t50
test50;

`else
`ifdef t51
test51;

`else
`ifdef t52
test52;

`else
`ifdef t53
test53;

`else
`ifdef t54
test54;

`else
`ifdef t55
test55;

`else
`ifdef t56
test56;

`else
`ifdef t57
test57;

`else
`ifdef t58
test58;

`else
`ifdef t59
test59;

`else
`ifdef t60
test60;

`else
`ifdef t61
test61;

`else
`ifdef t62
test62;
`else
`ifdef t63
test63;

`else
`ifdef t64
test64;


`else

`ifdef all

test1;
test2;
test3;
test4;
test5;
test6;
test7;
test8;
test9;
test10;
test11;
test12;
test13;
test14;
test15;
test16;
test17;
test18;
test19;
test20;
test21;
test22;
test23;
test24;
test25;
test26;
test27;
test28;
test29;
test30;
test31;
test32;
test33;
test34;
test35;
test36;
test37;
test38;
test39;
test40;
test41;
test42;
test43;
test44;
test45;
test46;
test47;
test48;
//test49;
//test50;
//test51;
//test52;
//test53;
//test54;
//test55;
//test56;
//test57;
//test58;
//test59;
//test60;
//test61;
//test62;
//test63;
//test64;
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif

#(12*SClkTP);


$finish;
end
//---------------------------------------------------------------//
//---------------------------------------------------------------//
initial
begin
          `ifdef DUMPVCD
              $dumpfile("sdram.vcd");
              $dumpvars();
           `endif
	   #9333 $finish;
end
endmodule
