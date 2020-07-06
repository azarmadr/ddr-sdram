#ifndef _SDC_MON
#define _SDC_MON

#include "sdc/pkt.h"
SC_MODULE(mon_sdc){
   sc_in<bool>        sclk,      srst,   req,     wr_rd;
   sc_in<sc_bv<2> >   req_len;
   sc_in<uint32_t>    wdata,     rdata;
   sc_in<sc_bv<23> >  addr;
   sc_in<bool>        req_ack,   rd_v,   wr_nxt,  init_f;

   sc_port<sc_fifo_out_if<pkt*> > sdc_ap;

   void monitor();

   SC_CTOR(mon_sdc){
      SC_CTHREAD(monitor, sclk.pos());
      reset_signal_is(srst,false);
   }
};

void mon_sdc::monitor(){
   wait();
   while(1){
      pkt_sdr* p = new(pkt_sdr);
      while(!init_f) wait (1,SC_NS);
      while(!req)    wait (1,SC_NS);
      p->req_len = req_len->read();
      p->wr_rd   = wr_rd->read();
      p-addr     = addr->read();

      (p->wr_rd)?
	 while(!rd_v)   wait (1,SC_NS):
	 while(!wr_nxt) wait (1,SC_NS);
      while(wr_nxt || rd_v){
	 (p->wr_rd)?
	    p->data.push_back(rdata->read()):
	    p->data.push_back(wdata->read());
	 wait();
      }
      sdc_ap.write(p);
   }
}
#endif
