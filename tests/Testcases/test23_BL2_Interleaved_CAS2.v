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
//    Name    : test23_BL2_Interleaved_CAS2.v
//    Author(): Udaykumar.R
//
//    Description:   Load the MODE  register Burst length bits with 2 and starting 
//                   Column Address bit with 0 and Burst Type bit to 1 and Write to 
//                   SDRAM and Read  we will observe that the order of Write/Read
//                   Address will be 0-1.
//    History    :   Dec 17, 2002    Ver 1.0  Initial declarations
//
//////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------


task test23;

/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

parameter 	SDR_ModCas3BLP 	= 12'h037,
	  	SDR_ModCas3BL8 	= 12'h023;
parameter 	SDR_ModCas3BL8_I= 12'h03B,

parameter 	MClkTP 			= 10,
	  	SClkTP 			= 20,

		REQLEN3 		= 4'h3,
		REQLEN2 		= 4'h2,
		REQLEN1 		= 4'h1,
		REQLEN0 		= 4'h0,

		ADDRESS0		= 23'h000_200,
		ADDRESS1		= 23'h200_400,
		ADDRESS2		= 23'h400_600,
		ADDRESS3		= 23'h600_000;

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/

  begin
$display("\t\t+----------------------------+\n\t\t| test22_Interleaved_Add01.v |\n\t\t+----------------------------+");


// lodading the Mode Register with Burst length = 2, Rt =1, CAS Latency = 2
initialize_sdr_ddr(12'h029,1'b1); // sel = 1 for sdram

/*      <------------------- 23 bit's ------------------------>
        -------------------------------------------------------
        | Bank ADD |      Row ADDRESS    |    Column ADDRESS  |
        -------------------------------------------------------
          2-bit's           12-bit's               9-bit's
*/

// Bank Address = 1,Row Address = 10 and Column Address = 0
sdram_write(23'ha00_a00,REQLEN3);
wait(sdc_req_ack2);
sdram_read(23'ha00_a00,REQLEN3);

wait(sdc_req_ack2);
// Bank Address = 2,Row Address = 11 and Column Address = 1
sdram_write(23'ha00_b01,REQLEN3);
wait(sdc_req_ack2);
sdram_read(23'ha00_b01,REQLEN3);

wait(sdc_req_ack2);

`ifdef all
		reset_sdr;
`endif



   end
endtask


