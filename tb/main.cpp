#include <stdio.h>
#include <iostream>
#include <sys/times.h>
#include <sys/stat.h>

#include "systemc.h"		// SystemC global header
#include "verilated_vcd_sc.h"  // Tracing

#include "VSDC_TOP.h"
#include "sdr_tb.h"

int sc_main(int argc, char* argv[]){
   Verilated::randReset(2);
   Verilated::debug(0);

   sc_clock mclk("m-clk", 10, SC_NS);

   //_Sdc_interface
   if_sdc* vif = new if_sdc("vif");

   //_Dut
   VSDC_TOP* top = new VSDC_TOP("top");
   //_host_if
   top->mclk    (mclk);
   top->s_resetn(vif->srst);
   top->sdr_req (vif->req);
   top->sdr_req_adr(vif->addr);
   top->sdr_req_len(vif->req_len);
   top->sdr_req_wr_n(vif->wr_rd);
   top->sdr_req_ack(vif->req_ack);
   top->sdr_rd_valid(vif->rd_v);
   top->sdr_wr_next(vif->wr_nxt);
   top->sdr_wr_data(vif->wdata);
   top->sdr_wr_en_n(vif->dt_mask);
   top->sdr_rd_data(vif->rdata);
   top->sdr_init_done(vif->init_f);
   top->sdr_en();///
   top->sdr_mode_reg(vif->m_reg);
   top->sdr_tras_d(vif->m_reg);///
   top->sdr_trp_d();
   top->sdr_trcd_d();
   top->sdr_cas();
   top->sdr_trca_d();
   top->sdr_twr_d();
   top->sdr_rfrsh();
   top->sdr_rfmax();
   //_sdram_if
   top->sdc_clk(vif->sclk);
   top->sdc_ad(vif->sclk);///
   top->sdc_ba(vif->sclk);///
   top->sdc_dq(vif->sclk);///
   top->sdc_dqs(vif->sclk);///
   top->sdc_rasb(vif->sclk);///
   top->sdc_casb(vif->sclk);///
   top->sdc_web(vif->sclk);///
   top->sdc_cke(vif->sclk);///
   top->sdc_csb(vif->sclk);///

   //_tb
   sdr_tb* tb = new sdr_tb("tb");
   tb->connect_if(vif);
}
