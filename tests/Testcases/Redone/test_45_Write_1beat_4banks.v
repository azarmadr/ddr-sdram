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
//    Name    : test_45_Write_1beat_4banks.v 
//    Author(): Udaykumar.R
//
//    Description:   Load the MODE register and Write t Beat to all the 4 banks of 
//                   SDRAM and Check if there are any gaps between bank writing.
//    History    :   Dec 23, 2002    Ver 1.0  Initial declarations
//
//////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------



task test45;
/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

parameter 	SDR_ModCas3BLP 	= 12'h037,
	  	SDR_ModCas3BL8 	= 12'h023;

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
$display("\t\t+-------------------------------+\n\t\t| test_45_Write_1beat_4banks.v |\n\t\t+-------------------------------+");
/*
// lodading the Mode Register with Burst length = 8, Rt =0, CAS Latency = 2
initialize_sdr_ddr(SDR_ModCas3BL8,1'b1); // sel = 1 for sdram
*/
/*      <------------------- 23 bit's ------------------------>
        -------------------------------------------------------
        | Bank ADD |      Row ADDRESS    |    Column ADDRESS  |
        -------------------------------------------------------
          2-bit's           12-bit's               9-bit's

*/
/*
// READ ALL 4 Banks with 1 Beat 

// Bank Address =0 ,Row Address = 6 and Column Address = 0
sdram_write(ADDRESS0,REQLEN0);

wait(sdc_req_ack2);
// Bank Address = 1,Row Address = 6 and Column Address = 0
sdram_write(ADDRESS1,REQLEN0);

wait(sdc_req_ack2);
// Bank Address = 2,Row Address = 6 and Column Address = 0
sdram_write(ADDRESS2,REQLEN0);

wait(sdc_req_ack2);
// Bank Address = 3,Row Address = 6 and Column Address = 0
sdram_write(ADDRESS3,REQLEN0); 

wait(sdc_req_ack2);
*/

initialize_sdr_ddr(SDR_ModCas3BL8,1'b1); // sel = 1 for sdram

//`ifdef mod1		//FOR READS AFTER ALL WRITES

sdram_write(ADDRESS0,REQLEN0);

wait(sdc_req_ack2);
sdram_write(ADDRESS1,REQLEN0);

wait(sdc_req_ack2);
sdram_write(ADDRESS2,REQLEN0);

wait(sdc_req_ack2);
sdram_write(ADDRESS3,REQLEN0); 

wait(sdc_req_ack2);
sdram_read(ADDRESS0,REQLEN0);

wait(sdc_req_ack2);
sdram_read(ADDRESS1,REQLEN0);

wait(sdc_req_ack2);
sdram_read(ADDRESS2,REQLEN0);

wait(sdc_req_ack2);
sdram_read(ADDRESS3,REQLEN0);

wait(sdc_req_ack2);

#(15*SClkTP);   

`ifdef all
		reset_sdr;
`endif



   end
endtask


