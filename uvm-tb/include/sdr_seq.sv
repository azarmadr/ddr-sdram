class sdr_fmt_seq extends sdr_default_seq;
   `uvm_object_utils(sdr_fmt_seq)

   bit [11:0]  m_mode_reg;
   bit         m_sel,     m_wr_rd;
   bit [ 1:0]  m_req_len;
   bit [22:0]  m_addr;

   function new(string name = "sdr_fmt_seq");
      super.new(name);
      m_addr     = 23'h03000;
      m_req_len  = 2'b0;
      m_sel      = 1;
      m_mode_reg = 12'h037;
      m_wr_rd    = $random;
   endfunction
   task body();
      `uvm_info(get_type_name(), "_Formatted_seq_starting", UVM_HIGH)

      req = sdr_tx::type_id::create("req");
      start_item(req); 
      if ( !req.randomize() with {
         addr     == m_addr;
         mode_reg == m_mode_reg;
         sel      == m_sel;
         wr_rd    == m_wr_rd;
         req_len  == m_req_len;
      })
         `uvm_error(get_type_name(), "_Fmt_seq_randomize_failure")
      finish_item(req); 

      `uvm_info(get_type_name(), "_Formatted_seq_completed", UVM_HIGH)
   endtask
endclass
