#ifndef _SDC_MON
#define _SDC_MON

#include "tb/sdc/if.h"
#include "tb/sdc/pkt.h"
class mon_sdc: uvm_monitor{
   public:
      uvm_analysis_port<pkt_sdr> sdc_ap;
      UVM_COMPONENT_UTILS(mon_sdc);
      mon_sdc(uvm_component_name name):
	 uvm_monitor(name){}
      void         build_phase(uvm_phase& phase);
      virtual void run_phase  (uvm_phase& phase);

   protected:
      if_sdc  * vif;
      pkt_sdr   tr;
      void      check_rst();
      void      monitor(){
	 wait(vif->srst.posedge_event());
	 while(1){
	    wait(
		  vif->init_f.posedge_event() &
		  vif->req   .posedge_event());

	    this->begin_tr(tr);
	    tr.req_len = vif->req_len.  read();
	    tr.wr_rd   = vif->wr_rd.    read();
	    tr.addr    = vif->addr.     read();
	    tr.mode_reg= vif->m_reg.    read();

	    wait(
		  vif->wr_nxt.posedge_event() |
		  vif->rd_v  .posedge_event());

	    while(vif->wr_nxt || vif->rd_v){
	       (tr.wr_rd)?
		  tr.data.push_back(vif->rdata.read()):
		  tr.data.push_back(vif->wdata.read());
	       wait(vif->sclk.posedge_event());
	    }
	    sdc_ap.write(tr);
	 }
      }
};
void mon_sdc::build_phase(uvm_phase& phase){
   uvm_monitor::build_phase(phase);
   if(!uvm_config_db<if_sdc*>::get(this,"","vif",vif))
      UVM_FATAL("_nVIF","_failed_to_get_vif_for"+
	    get_full_name());
}
void mon_sdc::run_phase(uvm_phase& phase){
   while(1){
      std::vector<sc_process_handle> rp_h;
      rp_h.push_back( sc_spawn( sc_bind( 
		  &mon_sdc::monitor,  this)));
      rp_h.push_back( sc_spawn( sc_bind( 
		  &mon_sdc::check_rst,this)));
      sc_event_or_list terminated_rp;
      for(auto &rh: rp_h)
	 terminated_rp |= rh.terminated_event();
      wait(terminated_rp);
      for(auto &rh: rp_h)
	 rh.kill();
   }
}
void mon_sdc::check_rst(){
   wait(vif->srst.negedge_event());
}
#endif
