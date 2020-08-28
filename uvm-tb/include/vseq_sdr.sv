class top_fmt_seq extends top_default_seq;
   `uvm_object_utils(top_fmt_seq)

   bit         m_sel;
   bit [11:0]  m_mode_reg;
   bit [22:0]  m_addr_dict[4];

   function new(string name = "");
      super.new(name);
      m_sel      = 1;
      m_mode_reg = 12'h037;
   endfunction : new

   task body();
      `uvm_info(get_type_name(), "_Formatted_top_seq_starting", UVM_HIGH)
      repeat (m_seq_count)begin
         std::randomize(m_addr_dict);
         if (m_sdr_agent.m_config.is_active == UVM_ACTIVE)
         begin
            sdr_fmt_seq seq;
            seq = sdr_fmt_seq ::type_id::create("seq");

            seq.m_mode_reg=m_mode_reg;
            seq.m_sel=m_sel;

            foreach(m_addr_dict[i])begin
               seq.m_wr_rd=0;
               repeat(3)begin
                  seq.m_wr_rd^=1;
                  seq.m_req_len=i;
                  seq.m_addr=m_addr_dict[i];
                  seq.set_item_context(this, m_sdr_agent.m_sequencer);
                  if ( !seq.randomize() )
                     `uvm_error(get_type_name(), "_Fmt_seq_randomize_failure")
                  seq.m_config = m_sdr_agent.m_config;
                  seq.set_starting_phase( get_starting_phase() );
                  seq.start(m_sdr_agent.m_sequencer, this);
               end
            end
         end
      end

      `uvm_info(get_type_name(), "Default sequence completed", UVM_HIGH)
   endtask : body

endclass : top_fmt_seq
