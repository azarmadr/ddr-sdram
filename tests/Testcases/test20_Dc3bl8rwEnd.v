



task test20;
/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

parameter 	SDR_ModCas3BLP 	= 12'h037,
	  	SDR_ModCas3BL8 	= 12'h061;//2;//3-8

parameter 	MClkTP 			= 20,
	  	SClkTP 			= 40,

		REQLEN3 		= 4'h3,
		REQLEN2 		= 4'h2,
		REQLEN1 		= 4'h1,
		REQLEN0 		= 4'h0,

		ADDRESS0XD		= 23'h1FF_EF8,//h1FF_FF8,
		ADDRESS1XD		= 23'h2FF_EF8,//00_400,
		ADDRESS2XD		= 23'h4FF_EF8,//00_600,
		ADDRESS3XD		= 23'h6FF_EF8;//00_000;

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/

   begin
$display("\t\t+---------------------+\n\t\t|test20_Dc3bl8rwEnd.v |\n\t\t+---------------------+");

									//--==>23 bits  ba(2)+ row(12)+ col(9)
//---->-----------cas=3--bl=8----

initialize_sdr_ddr(SDR_ModCas3BL8,1'b0); // sel = 1 for sdram

`ifdef mod1		//FOR READS AFTER ALL WRITES

sdram_write(ADDRESS0XD,REQLEN3);
wait(sdc_req_ack2);
sdram_write(ADDRESS1XD,REQLEN2);
wait(sdc_req_ack2);
sdram_write(ADDRESS2XD,REQLEN1);
wait(sdc_req_ack2);
sdram_write(ADDRESS3XD,REQLEN0); 

wait(sdc_req_ack2);
sdram_read(ADDRESS0XD,REQLEN3);
wait(sdc_req_ack2);
sdram_read(ADDRESS1XD,REQLEN2);
wait(sdc_req_ack2);
sdram_read(ADDRESS2XD,REQLEN1);
wait(sdc_req_ack2);
sdram_read(ADDRESS3XD,REQLEN0);


`else

sdram_write(ADDRESS0XD,REQLEN3);

wait(sdc_req_ack2);
sdram_read(ADDRESS0XD,REQLEN3);

wait(sdc_req_ack2);
sdram_write(ADDRESS1XD,REQLEN2);

wait(sdc_req_ack2);
sdram_read(ADDRESS1XD,REQLEN2);

wait(sdc_req_ack2);
sdram_write(ADDRESS2XD,REQLEN1);

wait(sdc_req_ack2);
sdram_read(ADDRESS2XD,REQLEN1);

wait(sdc_req_ack2);
sdram_write(ADDRESS3XD,REQLEN0); 

wait(sdc_req_ack2);
sdram_read(ADDRESS3XD,REQLEN0);

`endif

#(50*SClkTP);


`ifdef all
		reset_sdr;
`endif

   
   end
endtask

