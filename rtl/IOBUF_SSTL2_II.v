





module IOBUF_SSTL2_II (I, IO, O, T);

input I;
inout IO;
output O;
input T;

wire O, IO, I, T;

assign O = T ? IO : 1'bz;
assign   IO = I;

endmodule
