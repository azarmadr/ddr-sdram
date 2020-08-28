task sdr_driver::do_drive();
   wait(vif.srst);
   `uvm_info(get_type_name(), "_", UVM_LOW)
   req.print();

   fork
   begin
      vif.m_reg  <=req.mode_reg;
      repeat(2)   @(posedge vif.sclk);
      vif.sdr_en <=1;
      vif.sdr_sel<=req.sel;
      vif.req    <=1;
      vif.wr_rd  <=req.wr_rd;
      vif.req_len<=req.req_len;
      vif.addr   <=req.addr;
      wait(vif.init_f);
      wait(vif.req_ack);
      @(negedge vif.sclk);
      vif.req    <=0;
   end
   begin
      if(req.wr_rd)begin
         wait(!vif.rd_v);
         wait( vif.rd_v);
      end
      else begin 
         wait(vif.wr_nxt);
         while(vif.wr_nxt)begin
            @(posedge vif.sclk);
            vif.wdata<=req.data.pop_back();
         end
         @(posedge vif.sclk);
      end
   end
   join
endtask
