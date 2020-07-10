#ifndef _SDC_DRV
#define _SDC_DRV

#include "sdc/pkt.h"
#include "sdc/if.h"
SC_MODULE(drv_sdc){
   if_sdc* vif;

   //sc_port<sc_fifo_out_if<pkt*> > sdc_drv_f; //for testcases

   void driver();
   void req_a();
   void connect_if(if_sdc * vif);

   SC_CTOR(drv_sdc){
      sdc_if_f->read(vif);
      SC_CTHREAD(driver, vif->sclk.pos());
      reset_signal_is(vif->srst,false);
      SC_THREAD(req_a);
      sensitive<<vif->req_ack.pos();
      reset_signal_is(vif->srst,false);
   }
};
void drv_sdc::driver(){
   wait();
   while(1){
      pkt_sdr* p = new(pkt_sdr);
      pkt_gen(p,vif->m_reg.read());

      while(!vif->init_f) wait (1,SC_NS);
      vif->req.write(true);
      (p->wr_rd)?
	 while(!vif->rd_v)   wait (1,SC_NS):
	 while(!vif->wr_nxt) wait (1,SC_NS);

      while(vif->wr_nxt || vif->rd_v){
	 (p->wr_rd)?
	    vif->wdata.write(p->data.pop_back ()):
	    vif->rdata.read (p->data.push_back());
	 wait();
      }
   }
}
void drv_sdc::req_a(){
   wait(1,SC_NS);
   while(1){
      wait();
      vif->req.write(false);
   }
}
void drv_sdc::connect_if(if_sdc *vif){
   this.vif=vif;
}
#endif
