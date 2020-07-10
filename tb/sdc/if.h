#ifndef _SDC_IF
#define _SDC_IF

#include "systemc.h"
class if_sdc{
   public:
      sc_signal<bool>        sclk,     srst,   req,  wr_rd,  req_ack,  rd_v,  wr_nxt,  init_f;
      sc_signal<uint32_t>    wdata,    rdata;
      sc_signal<sc_bv<2> >   req_len;
      sc_signal<sc_bv<12> >  m_reg;
      sc_signal<sc_bv<23> >  addr;

      if_sdc(){}
}
#endif
