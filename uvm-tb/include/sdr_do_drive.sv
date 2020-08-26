task sdr_driver::do_drive();
   wait(vif.srst);
   req.print();
   vif.m_reg  <=12'h037;
   repeat(3)   @(posedge vif.sclk);
   vif.sdr_en <=1;
   vif.sdr_sel<=req.sel;
   vif.req    <=1;
   vif.wr_rd  <=req.wr_rd;
   vif.req_len<=req.req_len;
   vif.addr   <=req.addr;
   wait(vif.init_f);
   wait(vif.wr_nxt|vif.rd_v);
   while(vif.wr_nxt)begin
      vif.wdata<=req.data.pop_back();
      @(posedge vif.sclk);
   end
   wait(!vif.rd_v);
endtask
