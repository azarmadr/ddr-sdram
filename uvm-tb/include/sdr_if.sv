always@(m_reg)begin
   req        <= 0;
   addr       <= 22'h80000;
   req_len    <= 2'b00;
   wr_rd      <= 0;
   wdata      <= 0;
   dt_mask    <= 0;
   sdr_en     <= 1;
   sdr_tras_d <= 4'b1111;
   sdr_trp_d  <= 4'b1000;
   sdr_trcd_d <= 4'b0011;
   sdr_trca_d <= 4'b1010;
   sdr_twr_d  <= 4'b0010;
   sdr_rfrsh  <= 12'h07f;
   sdr_rfmax  <= 2'b11;
   sdr_cas    <= m_reg[6:4];
//   sdr_sel    <= s;
end
