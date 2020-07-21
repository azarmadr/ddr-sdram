#ifndef _SDC_DRV
#define _SDC_DRV

#include "sdc/pkt.h"
#include "sdc/if.h"
SC_MODULE(drv_sdc){
   if_sdc *vif;
   sc_process_handle drv_h;
   //sc_port<sc_fifo_out_if<pkt*> > sdc_drv_f; //for testcases
   SC_CTOR(drv_sdc){
      SC_THREAD(driver);
      drv_h = sc_get_current_process_handle();
      SC_THREAD(req_a);
   }

   void driver();
   void req_a();
   void reset_sdr();
   void check_rst();
   void init_sdr(sc_bv<12> mode_reg,bool sel);
   void connect_if(if_sdc * vip){
      vif=vip;
   }
};
void drv_sdc::reset_sdr(){
   vif->sync();
   vif->srst = 0;
   wait(vif->sclk.posedge_event());
   wait(vif->sclk.posedge_event());
   vif->srst = 1;
}
void drv_sdc::check_rst(){
   while(1){
      wait(vif->srst.negedge_event());
      drv_h.reset();
      drv_h.suspend();
      wait(vif->srst.posedge_event());
      drv_h.resume();
   }
}
void drv_sdc::driver(){
   vif->sync();
   init_sdr("0x023",1);
   vif->sync();
   vif->srst.write(1);
   sc_bv<3> tcas = vif->m_reg.read().range(6,4);
   //vif->sdr_cas.write(
   for(int i=3;i>0;i--){
      pkt_sdr* p = new(pkt_sdr);
      pkt_gen(p,vif->m_reg.read());

      wait(vif->init_f.posedge_event());
      vif->req.write(true);
      if(p->wr_rd) while (!vif->rd_v)   wait (1,SC_NS);
      else         while (!vif->wr_nxt) wait (1,SC_NS);

      while(vif->wr_nxt || vif->rd_v){
	 if(p->wr_rd)
	    p->data.push_back(vif->rdata.read());
	 else{
	    vif->wdata.write(p->data.back());
	    p->data.pop_back();
	 }
	 vif->sync();
      }
   }
}
void drv_sdc::req_a(){
   wait(1,SC_NS);
   while(1){
      wait(vif->req_ack.posedge_event());
      vif->req.write(false);
   }
}
void drv_sdc::init_sdr(sc_bv<12> mode_reg,bool sel){
   vif->srst.write        (false);
   vif->req.write         (false);
   vif->addr.write        ("0x80000");
   vif->req_len.write     ("00");
   vif->wr_rd.write       (0);
   vif->wdata.write       (0);
   vif->dt_mask.write     ("0");
   vif->sdr_en.write      ("1");
   vif->m_reg.write       (mode_reg);
   vif->sdr_tras_d.write  (0b1111);
   vif->sdr_trp_d.write   (0b1000);
   vif->sdr_trcd_d.write  (0b0011);
   vif->sdr_trca_d.write  (0b1010);
   vif->sdr_twr_d.write   (0b0010);
   vif->sdc_sel.write     (sel);
   vif->sdr_rfrsh.write   (0x07f);
   vif->sdr_rfmax.write   (0b11);
}
#endif
