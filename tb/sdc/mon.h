#ifndef _SDC_MON
#define _SDC_MON

#include "sdc/if.h"
#include "sdc/pkt.h"
SC_MODULE(mon_sdc){
   if_sdc* vif;

   sc_port<sc_fifo_out_if<pkt*> >    sdc_ap;
   sc_port<sc_fifo_in_if<if_sdc*> >  sdc_if_f;

   void monitor();

   SC_CTOR(mon_sdc){
      sdc_if_f->read(vif);
      SC_CTHREAD(monitor, vif->sclk.pos());
      reset_signal_is(vif->srst,false);
   }
};

void mon_sdc::monitor(){
   wait();
   while(1){
      pkt_sdr* p = new(pkt_sdr);
      while(!vif->init_f) wait (1,SC_NS);
      while(!vif->req)    wait (1,SC_NS);
      p->req_len = vif->req_len.  read();
      p->wr_rd   = vif->wr_rd.    read();
      p->addr    = vif->addr.     read();

      (p->wr_rd)?
	 while(!vif->rd_v)   wait (1,SC_NS):
	 while(!vif->wr_nxt) wait (1,SC_NS);
      while(vif->wr_nxt || vif->rd_v){
	 (p->wr_rd)?
	    p->data.push_back(vif->rdata.read()):
	    p->data.push_back(vif->wdata.read());
	 wait();
      }
      sdc_ap.write(p);
   }
}
#endif
