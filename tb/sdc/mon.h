#ifndef _SDC_MON
#define _SDC_MON

#include "sdc/if.h"
#include "sdc/pkt.h"
SC_MODULE(mon_sdc){
   if_sdc *vif;

   //sc_port<sc_fifo_out_if<pkt_sdr*> >    sdc_ap;

   void monitor();
   void connect_if(if_sdc * vip){
      vif=vip;
   }

   SC_CTOR(mon_sdc){
      SC_THREAD(monitor);
   }
};

void mon_sdc::monitor(){
   vif->sync();
   for(int i=3;i>0;i--){
      pkt_sdr* p = new(pkt_sdr);
      wait(vif->init_f.posedge_event());
      wait(vif->req   .posedge_event());
      p->req_len = vif->req_len.  read();
      p->wr_rd   = vif->wr_rd.    read();
      p->addr    = vif->addr.     read();

      if(p->wr_rd) wait(vif->rd_v  .posedge_event());
      else         wait(vif->wr_nxt.posedge_event());

      while(vif->wr_nxt || vif->rd_v){
	 (p->wr_rd)?
	    p->data.push_back(vif->rdata.read()):
	    p->data.push_back(vif->wdata.read());
	 vif->sync();
      }
      //sdc_ap->write(p);
   }
}
#endif
