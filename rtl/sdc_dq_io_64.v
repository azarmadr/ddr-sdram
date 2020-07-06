`include"define.v"
module sdc_dq_io_64 (
   // Outputs
   sdc_dq_i, 
   // Inouts
   sdc_dq, 
   // Inputs
   sdc_dq_o, sdc_dq_t
   );

   inout  [`SDC_DATA_MSB:0]   sdc_dq;
   input  [`SDC_DATA_MSB:0]   sdc_dq_o;
   output [`SDC_DATA_MSB:0]   sdc_dq_i;
   input  [`SDC_DATA_MSB:0]   sdc_dq_t;

   wire [`SDC_DATA_MSB:0]sdc_dq,sdc_dq_o, sdc_dq_t,sdc_dq_i;

   IOBUF_SSTL2_II dq0  (.I(sdc_dq_o[0]), .IO(sdc_dq[0]), .O(sdc_dq_i[0]), .T(sdc_dq_t[0]));
   IOBUF_SSTL2_II dq1  (.I(sdc_dq_o[1]), .IO(sdc_dq[1]), .O(sdc_dq_i[1]), .T(sdc_dq_t[1]));
   IOBUF_SSTL2_II dq2  (.I(sdc_dq_o[2]), .IO(sdc_dq[2]), .O(sdc_dq_i[2]), .T(sdc_dq_t[2]));
   IOBUF_SSTL2_II dq3  (.I(sdc_dq_o[3]), .IO(sdc_dq[3]), .O(sdc_dq_i[3]), .T(sdc_dq_t[3]));
   IOBUF_SSTL2_II dq4  (.I(sdc_dq_o[4]), .IO(sdc_dq[4]), .O(sdc_dq_i[4]), .T(sdc_dq_t[4]));
   IOBUF_SSTL2_II dq5  (.I(sdc_dq_o[5]), .IO(sdc_dq[5]), .O(sdc_dq_i[5]), .T(sdc_dq_t[5]));
   IOBUF_SSTL2_II dq6  (.I(sdc_dq_o[6]), .IO(sdc_dq[6]), .O(sdc_dq_i[6]), .T(sdc_dq_t[6]));
   IOBUF_SSTL2_II dq7  (.I(sdc_dq_o[7]), .IO(sdc_dq[7]), .O(sdc_dq_i[7]), .T(sdc_dq_t[7]));
   IOBUF_SSTL2_II dq8  (.I(sdc_dq_o[8]), .IO(sdc_dq[8]), .O(sdc_dq_i[8]), .T(sdc_dq_t[8]));
   IOBUF_SSTL2_II dq9  (.I(sdc_dq_o[9]), .IO(sdc_dq[9]), .O(sdc_dq_i[9]), .T(sdc_dq_t[9]));
   IOBUF_SSTL2_II dq10  (.I(sdc_dq_o[10]), .IO(sdc_dq[10]), .O(sdc_dq_i[10]), .T(sdc_dq_t[10]));
   IOBUF_SSTL2_II dq11  (.I(sdc_dq_o[11]), .IO(sdc_dq[11]), .O(sdc_dq_i[11]), .T(sdc_dq_t[11]));
   IOBUF_SSTL2_II dq12  (.I(sdc_dq_o[12]), .IO(sdc_dq[12]), .O(sdc_dq_i[12]), .T(sdc_dq_t[12]));
   IOBUF_SSTL2_II dq13  (.I(sdc_dq_o[13]), .IO(sdc_dq[13]), .O(sdc_dq_i[13]), .T(sdc_dq_t[13]));
   IOBUF_SSTL2_II dq14  (.I(sdc_dq_o[14]), .IO(sdc_dq[14]), .O(sdc_dq_i[14]), .T(sdc_dq_t[14]));
   IOBUF_SSTL2_II dq15  (.I(sdc_dq_o[15]), .IO(sdc_dq[15]), .O(sdc_dq_i[15]), .T(sdc_dq_t[15]));
   IOBUF_SSTL2_II dq16  (.I(sdc_dq_o[16]), .IO(sdc_dq[16]), .O(sdc_dq_i[16]), .T(sdc_dq_t[16]));
   IOBUF_SSTL2_II dq17  (.I(sdc_dq_o[17]), .IO(sdc_dq[17]), .O(sdc_dq_i[17]), .T(sdc_dq_t[17]));
   IOBUF_SSTL2_II dq18  (.I(sdc_dq_o[18]), .IO(sdc_dq[18]), .O(sdc_dq_i[18]), .T(sdc_dq_t[18]));
   IOBUF_SSTL2_II dq19  (.I(sdc_dq_o[19]), .IO(sdc_dq[19]), .O(sdc_dq_i[19]), .T(sdc_dq_t[19]));
   IOBUF_SSTL2_II dq20  (.I(sdc_dq_o[20]), .IO(sdc_dq[20]), .O(sdc_dq_i[20]), .T(sdc_dq_t[20]));
   IOBUF_SSTL2_II dq21  (.I(sdc_dq_o[21]), .IO(sdc_dq[21]), .O(sdc_dq_i[21]), .T(sdc_dq_t[21]));
   IOBUF_SSTL2_II dq22  (.I(sdc_dq_o[22]), .IO(sdc_dq[22]), .O(sdc_dq_i[22]), .T(sdc_dq_t[22]));
   IOBUF_SSTL2_II dq23  (.I(sdc_dq_o[23]), .IO(sdc_dq[23]), .O(sdc_dq_i[23]), .T(sdc_dq_t[23]));
   IOBUF_SSTL2_II dq24  (.I(sdc_dq_o[24]), .IO(sdc_dq[24]), .O(sdc_dq_i[24]), .T(sdc_dq_t[24]));
   IOBUF_SSTL2_II dq25  (.I(sdc_dq_o[25]), .IO(sdc_dq[25]), .O(sdc_dq_i[25]), .T(sdc_dq_t[25]));
   IOBUF_SSTL2_II dq26  (.I(sdc_dq_o[26]), .IO(sdc_dq[26]), .O(sdc_dq_i[26]), .T(sdc_dq_t[26]));
   IOBUF_SSTL2_II dq27  (.I(sdc_dq_o[27]), .IO(sdc_dq[27]), .O(sdc_dq_i[27]), .T(sdc_dq_t[27]));
   IOBUF_SSTL2_II dq28  (.I(sdc_dq_o[28]), .IO(sdc_dq[28]), .O(sdc_dq_i[28]), .T(sdc_dq_t[28]));
   IOBUF_SSTL2_II dq29  (.I(sdc_dq_o[29]), .IO(sdc_dq[29]), .O(sdc_dq_i[29]), .T(sdc_dq_t[29]));
   IOBUF_SSTL2_II dq30  (.I(sdc_dq_o[30]), .IO(sdc_dq[30]), .O(sdc_dq_i[30]), .T(sdc_dq_t[30]));
   IOBUF_SSTL2_II dq31  (.I(sdc_dq_o[31]), .IO(sdc_dq[31]), .O(sdc_dq_i[31]), .T(sdc_dq_t[31]));
/*
   IOBUF_SSTL2_II dq32  (.I(sdc_dq_o[32]), .IO(sdc_dq[32]), .O(sdc_dq_i[32]), .T(sdc_dq_t[32]));
   IOBUF_SSTL2_II dq33  (.I(sdc_dq_o[33]), .IO(sdc_dq[33]), .O(sdc_dq_i[33]), .T(sdc_dq_t[33]));
   IOBUF_SSTL2_II dq34  (.I(sdc_dq_o[34]), .IO(sdc_dq[34]), .O(sdc_dq_i[34]), .T(sdc_dq_t[34]));
   IOBUF_SSTL2_II dq35  (.I(sdc_dq_o[35]), .IO(sdc_dq[35]), .O(sdc_dq_i[35]), .T(sdc_dq_t[35]));
   IOBUF_SSTL2_II dq36  (.I(sdc_dq_o[36]), .IO(sdc_dq[36]), .O(sdc_dq_i[36]), .T(sdc_dq_t[36]));
   IOBUF_SSTL2_II dq37  (.I(sdc_dq_o[37]), .IO(sdc_dq[37]), .O(sdc_dq_i[37]), .T(sdc_dq_t[37]));
   IOBUF_SSTL2_II dq38  (.I(sdc_dq_o[38]), .IO(sdc_dq[38]), .O(sdc_dq_i[38]), .T(sdc_dq_t[38]));
   IOBUF_SSTL2_II dq39  (.I(sdc_dq_o[39]), .IO(sdc_dq[39]), .O(sdc_dq_i[39]), .T(sdc_dq_t[39]));
   IOBUF_SSTL2_II dq40  (.I(sdc_dq_o[40]), .IO(sdc_dq[40]), .O(sdc_dq_i[40]), .T(sdc_dq_t[40]));
   IOBUF_SSTL2_II dq41  (.I(sdc_dq_o[41]), .IO(sdc_dq[41]), .O(sdc_dq_i[41]), .T(sdc_dq_t[41]));
   IOBUF_SSTL2_II dq42  (.I(sdc_dq_o[42]), .IO(sdc_dq[42]), .O(sdc_dq_i[42]), .T(sdc_dq_t[42]));
   IOBUF_SSTL2_II dq43  (.I(sdc_dq_o[43]), .IO(sdc_dq[43]), .O(sdc_dq_i[43]), .T(sdc_dq_t[43]));
   IOBUF_SSTL2_II dq44  (.I(sdc_dq_o[44]), .IO(sdc_dq[44]), .O(sdc_dq_i[44]), .T(sdc_dq_t[44]));
   IOBUF_SSTL2_II dq45  (.I(sdc_dq_o[45]), .IO(sdc_dq[45]), .O(sdc_dq_i[45]), .T(sdc_dq_t[45]));
   IOBUF_SSTL2_II dq46  (.I(sdc_dq_o[46]), .IO(sdc_dq[46]), .O(sdc_dq_i[46]), .T(sdc_dq_t[46]));
   IOBUF_SSTL2_II dq47  (.I(sdc_dq_o[47]), .IO(sdc_dq[47]), .O(sdc_dq_i[47]), .T(sdc_dq_t[47]));
   IOBUF_SSTL2_II dq48  (.I(sdc_dq_o[48]), .IO(sdc_dq[48]), .O(sdc_dq_i[48]), .T(sdc_dq_t[48]));
   IOBUF_SSTL2_II dq49  (.I(sdc_dq_o[49]), .IO(sdc_dq[49]), .O(sdc_dq_i[49]), .T(sdc_dq_t[49]));
   IOBUF_SSTL2_II dq50  (.I(sdc_dq_o[50]), .IO(sdc_dq[50]), .O(sdc_dq_i[50]), .T(sdc_dq_t[50]));
   IOBUF_SSTL2_II dq51  (.I(sdc_dq_o[51]), .IO(sdc_dq[51]), .O(sdc_dq_i[51]), .T(sdc_dq_t[51]));
   IOBUF_SSTL2_II dq52  (.I(sdc_dq_o[52]), .IO(sdc_dq[52]), .O(sdc_dq_i[52]), .T(sdc_dq_t[52]));
   IOBUF_SSTL2_II dq53  (.I(sdc_dq_o[53]), .IO(sdc_dq[53]), .O(sdc_dq_i[53]), .T(sdc_dq_t[53]));
   IOBUF_SSTL2_II dq54  (.I(sdc_dq_o[54]), .IO(sdc_dq[54]), .O(sdc_dq_i[54]), .T(sdc_dq_t[54]));
   IOBUF_SSTL2_II dq55  (.I(sdc_dq_o[55]), .IO(sdc_dq[55]), .O(sdc_dq_i[55]), .T(sdc_dq_t[55]));
   IOBUF_SSTL2_II dq56  (.I(sdc_dq_o[56]), .IO(sdc_dq[56]), .O(sdc_dq_i[56]), .T(sdc_dq_t[56]));
   IOBUF_SSTL2_II dq57  (.I(sdc_dq_o[57]), .IO(sdc_dq[57]), .O(sdc_dq_i[57]), .T(sdc_dq_t[57]));
   IOBUF_SSTL2_II dq58  (.I(sdc_dq_o[58]), .IO(sdc_dq[58]), .O(sdc_dq_i[58]), .T(sdc_dq_t[58]));
   IOBUF_SSTL2_II dq59  (.I(sdc_dq_o[59]), .IO(sdc_dq[59]), .O(sdc_dq_i[59]), .T(sdc_dq_t[59]));
   IOBUF_SSTL2_II dq60  (.I(sdc_dq_o[60]), .IO(sdc_dq[60]), .O(sdc_dq_i[60]), .T(sdc_dq_t[60]));
   IOBUF_SSTL2_II dq61  (.I(sdc_dq_o[61]), .IO(sdc_dq[61]), .O(sdc_dq_i[61]), .T(sdc_dq_t[61]));
   IOBUF_SSTL2_II dq62  (.I(sdc_dq_o[62]), .IO(sdc_dq[62]), .O(sdc_dq_i[62]), .T(sdc_dq_t[62]));
   IOBUF_SSTL2_II dq63  (.I(sdc_dq_o[63]), .IO(sdc_dq[63]), .O(sdc_dq_i[63]), .T(sdc_dq_t[63]));
*/
endmodule
