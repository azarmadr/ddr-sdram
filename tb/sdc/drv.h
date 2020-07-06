#ifndef _SDC_DRV
#define _SDC_DRV

#include "sdc/pkt.h"
SC_MODULE(drv_sdc){
   sc_in<bool>         sclk,     srst;
   sc_out<bool>        req,      wr_rd;
   sc_out<sc_bv<2> >   req_len;
   sc_out<sc_bv<23> >  addr;
   sc_out<uint32_t>    wdata;
   sc_in<uint32_t>     rdata;
   sc_in<bool>         req_ack,  rd_v,   wr_nxt,  init_f;

   int len;
   sc_bv<12> m_reg;
   sc_port<sc_fifo_out_if<pkt*> > sdc_ap;

   void driver();

   SC_CTOR(drv_sdc){
      SC_CTHREAD(driver, sclk.pos());
      reset_signal_is(srst,false);
   }
};

void drv_sdc::driver(){
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
   }
}
#endif
