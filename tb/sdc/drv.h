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
   sc_in<sc_bv<12> >   m_reg;
   sc_in<bool>         req_ack,  rd_v,   wr_nxt,  init_f;

   sc_port<sc_fifo_out_if<pkt*> > sdc_ap;

   void driver();
   void req_a();

   SC_CTOR(drv_sdc){
      SC_CTHREAD(driver, sclk.pos());
      reset_signal_is(srst,false);
      SC_THREAD(req_a);
      sensitive<<req_ack.pos();
      reset_signal_is(srst,false);
   }
};
void drv_sdc::driver(){
   wait();
   while(1){
      pkt_sdr* p = new(pkt_sdr);
      pkt_gen(p,m_reg->read());

      while(!init_f) wait (1,SC_NS);
      req->write(true);

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
void drv_sdc::req_a(){
   wait(1,SC_NS);
   while(1){
      wait();
      req->write(false);
   }
}
#endif
