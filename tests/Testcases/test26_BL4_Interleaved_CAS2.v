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
//    Name    : test26_BL4_Interleaved_CAS2.v
//    Author(): Udaykumar.R
//
//    Description:   Load the MODE  register Burst length bits with 4 and starting 
//                   Column Address bit with 0,1,2,3 and Burst Type bit to 1 and 
//                   Write to SDRAM and Read  we will observe that the order of 
//                   Write/Read Address will be 0-1,1-0,2-3-0-1,3-2-1-0.
//    History    :   Dec 17, 2002    Ver 1.0  Initial declarations
//
//////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------


task test26;

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
$display("\t\t+--------------------------------+\n\t\t| test26_BL4_Interleaved_CAS2.v  |\n\t\t+--------------------------------+");


// lodading the Mode Register with Burst length = 4, Rt =1, CAS Latency = 2
initialize_sdr_ddr(12'h02A,1'b1); // sel = 1 for sdram

/*      <------------------- 23 bit's ------------------------>
        -------------------------------------------------------
        | Bank ADD |      Row ADDRESS    |    Column ADDRESS  |
        -------------------------------------------------------
          2-bit's           12-bit's               9-bit's
*/

// Bank Address = 3,Row Address = 6 and Column Address = 0
sdram_write(23'h600_600,REQLEN3);
wait(sdc_req_ack2);
sdram_read(23'h600_600,REQLEN3);

wait(sdc_req_ack2);
// Bank Address = 3,Row Address = 6 and Column Address = 1
sdram_write(23'h600_601,REQLEN3);
wait(sdc_req_ack2);
sdram_read(23'h600_601,REQLEN3);

wait(sdc_req_ack2);
// Bank Address = 3,Row Address = 6 and Column Address = 2
sdram_write(23'h600_602,REQLEN3);
wait(sdc_req_ack2);
sdram_read(23'h600_602,REQLEN3);

wait(sdc_req_ack2);
// Bank Address = 3,Row Address = 6 and Column Address = 3
sdram_write(23'h600_603,REQLEN3);
wait(sdc_req_ack2);
sdram_read(23'h600_603,REQLEN3);

wait(sdc_req_ack2);


`ifdef all
		reset_sdr;
`endif



   end
endtask


