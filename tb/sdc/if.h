#ifndef _SDC_IF
#define _SDC_IF

#include "systemc.h"
class if_sdc{
   public:
      sc_signal<bool>        sclk,   srst,   req,         wr_rd,      
	 req_ack,     rd_v,  wr_nxt, init_f, sdr_en;
      sc_signal<uint32_t>    wdata,  rdata,  sdr_tras_d,  sdr_trp_d,  sdr_trcd_d,
	 sdr_cas,            sdr_trca_d,     sdr_twr_d,   sdr_rfrsh,  sdr_rfmax;
      sc_signal<sc_bv<2> >   req_len;
      sc_signal<sc_bv<4> >   dt_mask;
      sc_signal<sc_bv<12> >  m_reg;
      sc_signal<sc_bv<23> >  addr;

      if_sdc(){}
}
#endif
