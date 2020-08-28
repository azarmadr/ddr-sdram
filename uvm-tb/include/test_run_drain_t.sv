virtual function void end_of_elaboration_phase (uvm_phase phase);
  super.end_of_elaboration_phase (phase);
  uvm_top.set_timeout (90000ns);
endfunction 
function void phase_ready_to_end (uvm_phase phase);
   if(phase.is(uvm_run_phase::get)) begin
      phase.raise_objection(this, "Test Not Yet Ready To End");
      fork begin
         `uvm_info("PRTE", "Phase Ready Testing", UVM_LOW);
         phase.phase_done.set_drain_time(this,1000);
         phase.drop_objection(this, "Test Ready to End");
      end join_none
   end
endfunction: phase_ready_to_end
