#ifndef _SDC_DRV
#define _SDC_DRV

#include "tb/sdc/pkt.h"
#include "tb/sdc/if.h"
class drv_sdc: public uvm_driver<pkt_sdr>{
   public:
      UVM_COMPONENT_UTILS(drv_sdc);
      drv_sdc(uvm_component_name name):
         uvm_driver<pkt_sdr>(name){}
      void         build_phase(uvm_phase& phase);
      virtual void run_phase  (uvm_phase& phase);
   protected:
      void init_sdr();
      void driver();
      void check_rst();
      void run();
      if_sdc* vif;
};
void drv_sdc::build_phase(uvm_phase& phase){
   uvm_driver<pkt_sdr>::build_phase(phase);
   if(!uvm_config_db<if_sdc*>::get(this,"","vif",vif))
      UVM_FATAL("_nVIF","_failed_to_get_vif_for"+
            get_full_name());
}
void drv_sdc::run_phase(uvm_phase& phase){
   sc_spawn(sc_bind(&drv_sdc::run,this),"run");
}
void drv_sdc::run(){
   while(1){
      std::vector<sc_process_handle> rp_h;
      rp_h.push_back( sc_spawn( sc_bind(
                  &drv_sdc::driver,   this)));
      rp_h.push_back( sc_spawn( sc_bind(
                  &drv_sdc::check_rst,this)));
      sc_event_or_list terminated_rp;
      for(auto &rh: rp_h)
         terminated_rp |= rh.terminated_event();
      wait(terminated_rp);
      for(auto &rh: rp_h)
         rh.kill();
   }
}
void drv_sdc::init_sdr(){
   while(1){
      wait(vif->m_reg.default_event());//value_changed_event());
      vif->addr       = 0x80000;
      vif->req_len    = 0b00;
      vif->wr_rd      = 0;
      vif->wdata      = 0x0;
      vif->dt_mask    = 0x0;
      vif->sdr_en     = 0;
      vif->sdr_tras_d = "1111";
      vif->sdr_trp_d  = "1000";
      vif->sdr_trcd_d = "0011";
      vif->sdr_trca_d = "1010";
      vif->sdr_twr_d  = "0010";
      vif->sdr_rfrsh  = 0x07f;
      vif->sdr_rfmax  = 0b11;
      sc_bv<3> t;
      t = vif->m_reg.read().range(6,4);
      vif->sdr_cas= (uint32_t)(sc_uint<3>)t;
   }
}
void drv_sdc::check_rst(){
   wait(vif->srst.negedge_event());
}
void drv_sdc::driver(){
   wait(vif->srst.posedge_event());
   while(1){
      wait(vif->sclk.posedge_event());
      pkt_sdr req,rsp;
      this->seq_item_port.get_next_item(req);
      rsp = req;
      rsp.set_id_info(req);

      vif->m_reg  .write(rsp.mode_reg);
      vif->sdc_sel.write(rsp.sel);
      wait(vif->sclk.posedge_event());
      vif->sdr_en .write(1);
      vif->wr_rd  .write(rsp.wr_rd);
      vif->req_len.write(rsp.req_len);
      vif->addr   .write(rsp.addr);
      wait(vif->init_f.posedge_event());
      wait(
            vif->wr_nxt.posedge_event()|
            vif->rd_v  .posedge_event());
      while(vif->wr_nxt || vif->rd_v){
         if(!rsp.wr_rd){
            vif->wdata.write(rsp.data.back());
            rsp.data.pop_back();
         }
         wait(vif->sclk.posedge_event());
      }
      this->seq_item_port.item_done();
      this->seq_item_port.put_response(rsp);
   }
}
#endif
