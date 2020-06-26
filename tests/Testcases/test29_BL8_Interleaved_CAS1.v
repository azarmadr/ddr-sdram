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
//    Name    : test29_BL8_Interleaved_CAS1.v
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


task test29;

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
$display("\t\t+--------------------------------+\n\t\t| test29_BL8_Interleaved_CAS1.v |\n\t\t+--------------------------------+");


// lodading the Mode Register with Burst length = 8, Rt =1, CAS Latency = 1
initialize_sdr_ddr(12'h01B,1'b1); // sel = 1 for sdram

/*      <------------------- 23 bit's ------------------------>
        -------------------------------------------------------
        | Bank ADD |      Row ADDRESS    |    Column ADDRESS  |
        -------------------------------------------------------
          2-bit's           12-bit's               9-bit's
*/

// Bank Address = 2,Row Address = 6 and Column Address = 0
sdram_write(23'h400_600,REQLEN3);
wait(sdc_req_ack2);
sdram_read(23'h400_600,REQLEN3);

wait(sdc_req_ack2);
// Bank Address = 2,Row Address = 6 and Column Address = 1
sdram_write(23'h400_601,REQLEN3);
wait(sdc_req_ack2);
sdram_read(23'h400_601,REQLEN3);

wait(sdc_req_ack2);
// Bank Address = 2,Row Address = 6 and Column Address = 2
sdram_write(23'h400_602,REQLEN3);
wait(sdc_req_ack2);
sdram_read(23'h400_602,REQLEN3);

wait(sdc_req_ack2);
// Bank Address = 2,Row Address = 6 and Column Address = 3
sdram_write(23'h400_603,REQLEN3);
wait(sdc_req_ack2);
sdram_read(23'h400_603,REQLEN3);

wait(sdc_req_ack2);
// Bank Address = 2,Row Address = 6 and Column Address = 4
sdram_write(23'h400_604,REQLEN3);
wait(sdc_req_ack2);
sdram_read(23'h400_604,REQLEN3);

wait(sdc_req_ack2);
// Bank Address = 2,Row Address = 6 and Column Address = 5
sdram_write(23'h400_605,REQLEN3);
wait(sdc_req_ack2);
sdram_read(23'h400_605,REQLEN3);

wait(sdc_req_ack2);
// Bank Address = 2,Row Address = 6 and Column Address = 6
sdram_write(23'h400_606,REQLEN3);
wait(sdc_req_ack2);
sdram_read(23'h400_606,REQLEN3);

wait(sdc_req_ack2);
// Bank Address = 2,Row Address = 6 and Column Address = 7
sdram_write(23'h400_607,REQLEN3);
wait(sdc_req_ack2);
sdram_read(23'h400_607,REQLEN3);

wait(sdc_req_ack2);


`ifdef all
		reset_sdr;
`endif



   end
endtask


