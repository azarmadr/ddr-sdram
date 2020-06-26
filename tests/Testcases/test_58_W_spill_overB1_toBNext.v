//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2002 iPlay Networks Pvt. Ltd.  All rights reserved.
//
// This document contains information which is both confidential and
//
// proprietary to iPlay Networks Pvt. Ltd.
//
//  3-6-157, Himayat Nagar, Hyderabad, India        011-91-40-3225204
//
///////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------
//    Name    : test_58_W_spill_overB1_toBNext.v 
//    Author(): Udaykumar.R
//
//    Description:   Load the MODE register and Write/Read Beat to Bank0 
//                   starting at the end of last row in a bank of SDRAM and Check 
//                   if it  spills over bank x to bank x+1..
//    History    :   Dec 24, 2002    Ver 1.0  Initial declarations
//
//////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------



task test58;
/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

parameter 	SDR_ModCas3BLP 	= 12'h037,
	  	SDR_ModCas3BL8 	= 12'h033;

parameter 	MClkTP 			= 20,
	  	SClkTP 			= 40,

		REQLEN3 		= 4'h3,
		REQLEN2 		= 4'h2,
		REQLEN1 		= 4'h1,
		REQLEN0 		= 4'h0,

//              ADDRESS0XS		= 23'h1FF_FFF,
//		ADDRESS1XS		= 23'h7FF_FFF,
		ADDRESS2XS		= 23'h5FF_FF8,
		ADDRESS3XS		= 23'h6FF_FF8;

                ADDRESS1XS              = 23'h700_400,
//              ADDRESS2XS              = 23'h400_600,
//              ADDRESS3XS              = 23'h600_000;


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/

   begin
$display("\t\t+---------------------------------+\n\t\t|test_58_W_spill_overBx_toBNext.v|\n\t\t+---------------------------------+");

// lodading the Mode Register with Burst length = 8, Rt =0, CAS Latency = 2
//initialize_sdr_ddr(SDR_ModCas3BL8,1'b1); // sel = 1 for sdram
initialize_sdr_ddr(SDR_ModCas3BL8,1'b1); // sel = 1 for sdram

/*      <------------------- 23 bit's ------------------------>
        -------------------------------------------------------
        | Bank ADD |      Row ADDRESS    |    Column ADDRESS  |
        -------------------------------------------------------
          2-bit's           12-bit's               9-bit's

*/

// Write 1 Beat to Bank0 

// Bank Address =1 ,Row Address = 6 and Column Address = 0
sdram_write(23'h3FFFF8,REQLEN3);
//wait(sdc_req_ack2);


#(15*SClkTP);

`ifdef all
		reset_sdr;
`endif

   
   end
endtask

