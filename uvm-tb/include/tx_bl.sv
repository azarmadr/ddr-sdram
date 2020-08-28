function int bl(bit[2:0] mode_reg, bit [1:0] len);
   bit [1:0] tbl; bit [7:0] xbl;
   if (mode_reg == 3'b111) begin
      if      (len == 2'b00) return 4;
      else if (len == 2'b01) return 8;
      else if (len == 2'b10) return 16;
      else                   return 32;
   end
   else if(mode_reg[2] == 0)  begin
      tbl = mode_reg[1:0];
      xbl = 8'h02;
      xbl <<= (len+1);
      xbl >>= tbl;
      xbl *= 2**tbl;
      return xbl;
   end
endfunction
