


task test7;
/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 

parameter 	SDR_ModCas2BL4 	= 12'h022;

parameter 	MClkTP 			= 20,
	  	SClkTP 			= 40,

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

$display("\t\t+---------------------+\n\t\t|   test7_Sc2bl4.v    |\n\t\t+---------------------+");
									//--==>23 bits  ba(2)+ row(12)+ col(9)
//---->-----------cas=2--bl=4----

initialize_sdr_ddr(SDR_ModCas2BL4,1'b1); // sel = 1 for sdram

`ifdef mod1

sdram_write(ADDRESS0,REQLEN3);
wait(sdc_req_ack2);
sdram_write(ADDRESS1,REQLEN2);
wait(sdc_req_ack2);
sdram_write(ADDRESS2,REQLEN1);
wait(sdc_req_ack2);
sdram_write(ADDRESS3,REQLEN0); 

wait(sdc_req_ack2);
sdram_read(ADDRESS0,REQLEN3);
wait(sdc_req_ack2);
sdram_read(ADDRESS1,REQLEN2);
wait(sdc_req_ack2);
sdram_read(ADDRESS2,REQLEN1);
wait(sdc_req_ack2);
sdram_read(ADDRESS3,REQLEN0);



`else

sdram_write(ADDRESS0,REQLEN3);

wait(sdc_req_ack2);
sdram_read(ADDRESS0,REQLEN3);
	
wait(sdc_req_ack2);
sdram_write(ADDRESS1,REQLEN2);

wait(sdc_req_ack2);
sdram_read(ADDRESS1,REQLEN2);

wait(sdc_req_ack2);
sdram_write(ADDRESS2,REQLEN1);

wait(sdc_req_ack2);
sdram_read(ADDRESS2,REQLEN1);

wait(sdc_req_ack2);
sdram_write(ADDRESS3,REQLEN0); 

wait(sdc_req_ack2);
sdram_read(ADDRESS3,REQLEN0);


`endif

#(10*SClkTP);


`ifdef all
		reset_sdr;
`endif

   
   end

endtask

