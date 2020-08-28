task sdr_monitor::do_mon();
   wait(vif.init_f & vif.req);
   m_trans.wr_rd   <=vif.wr_rd  ;
   m_trans.req_len <=vif.req_len;
   m_trans.addr    <=vif.addr   ;
   m_trans.mode_reg<=vif.m_reg  ;
   m_trans.sel     <=vif.sdr_sel;
   wait(vif.wr_nxt|vif.rd_v);
   while(vif.rd_v||vif.wr_nxt)begin
      if(m_trans.wr_rd) m_trans.data.push_back(vif.rdata);
      else               m_trans.data.push_back(vif.wdata);
      @(posedge vif.sclk);
   end
endtask
