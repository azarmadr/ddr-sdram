logic clock=0;
logic reset;

always #2.5 clock = ~clock;

initial begin
   reset=0;
   #75 reset=1;
end

assign sdr_if_0.mclk = clock;
assign sdr_if_0.srst = reset;
