#ifndef _SDC_IF
#define _SDC_IF

#include <systemc>
#include <uvm>
using namespace uvm;
using namespace sc_dt;
using namespace sc_core;
class if_sdc : public sc_module{
   public:
      SC_HAS_PROCESS(if_sdc);

      if_sdc(sc_module_name name):
	 sc_module(name),           sclk("sclk"),              srst("srst"),
	 req("req"),                wr_rd("wr_rd"),            req_ack("req_ack"),
	 rd_v("rd_v"),              wr_nxt("wr_nxt"),          init_f("init_f"),
	 sdr_en("sdr_en"),          sdc_sel("sdc_sel"),        wdata("wdata"),
	 rdata("rdata"),            sdr_twr_d("sdr_twr_d"),    sdr_tras_d("sdr_tras_d"),
	 sdr_trp_d("sdr_trp_d"),    sdr_trcd_d("sdr_trcd_d"),
	 sdr_trca_d("sdr_trca_d"),  sdr_cas("sdr_cas"),
	 sdr_rfrsh("sdr_rfrsh"),    sdr_rfmax("sdr_rfmax"),    req_len("req_len"),
	 dt_mask("dt_mask"),        m_reg("m_reg"),            addr("addr")
      {
	 SC_THREAD(req_ack_done);
	 SC_THREAD(init_sdr);
	 sensitive << m_reg.default_event();
	 SC_THREAD(sync);
	 sensitive
	    << sclk.default_event()	    << srst.default_event()
	    << req.default_event()	    << wr_rd.default_event()
	    << req_ack.default_event()	    << rd_v.default_event()
	    << wr_nxt.default_event()	    << init_f.default_event()
	    << sdr_en.default_event()	    << sdc_sel.default_event()
	    << wdata.default_event()	    << rdata.default_event()
	    << sdr_twr_d.default_event()    << sdr_tras_d.default_event()
	    << sdr_trp_d.default_event()    << sdr_trcd_d.default_event()
	    << sdr_trca_d.default_event()   << sdr_cas.default_event()
	    << sdr_rfrsh.default_event()    << sdr_rfmax.default_event()
	    << req_len.default_event()	    << dt_mask.default_event()
	    << m_reg.default_event()	    << addr.default_event();
      }

      sc_signal<bool>        sclk,   srst,   req,         wr_rd,      
	 req_ack,     rd_v,  wr_nxt, init_f, sdr_en,      sdc_sel;
      sc_signal<uint32_t>    wdata,  rdata,  sdr_twr_d,   sdr_tras_d,  sdr_trp_d,
	 sdr_trcd_d,         sdr_trca_d,     sdr_cas,     sdr_rfrsh,   sdr_rfmax;
      sc_signal<sc_bv<2> >   req_len;
      sc_signal<sc_bv<4> >   dt_mask;
      sc_signal<sc_bv<12> >  m_reg;
      sc_signal<sc_bv<23> >  addr;

      void sync(){
	 wait(SC_ZERO_TIME);
      }
      void req_ack_done(){
	 while(1){
	    wait(req_ack.posedge_event());
	    req = 0;
	 }
      }
      void init_sdr(){
	 req        = 0;
	 addr       = 0x80000;
	 req_len    = 0;
	 wr_rd      = 0;
	 wdata      = 0x0;
	 dt_mask    = 0x0;
	 sdr_en     = 0;
	 sdr_tras_d = 0b1111;
	 sdr_trp_d  = 0b1000;
	 sdr_trcd_d = 0b0011;
	 sdr_trca_d = 0b1010;
	 sdr_twr_d  = 0b0010;
	 sdr_rfrsh  = 0x07f;
	 sdr_rfmax  = 0b11;
	 m_reg.read(sdr_cas).range(6,4);
      }
};
#endif
