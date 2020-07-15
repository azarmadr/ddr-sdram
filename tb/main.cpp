#include <stdio.h>
#include <iostream>
#include <sys/times.h>
#include <sys/stat.h>

#include "systemc.h"		// SystemC global header
#include "verilated_vcd_sc.h"  // Tracing

#include "VSDC_TOP.h"
#include "VMT48LC1M16A1.h"
#include "sdr_tb.h"

int sc_main(int argc, char* argv[]){
   Verilated::randReset(2);
   Verilated::debug(0);

   sc_clock mclk("m-clk", 10, SC_NS);

   //_Sdc_interface
   if_sdc* vif = new if_sdc("vif");

   //_Mem_interface
   mem_ifc* mif = new mem_ifc("mif");
//   mif->sdc_clk(vif->sclk);

   //_Dut
   VSDC_TOP* top = new VSDC_TOP("top");
   //_host_if
   top->mclk         (mclk);
   top->s_resetn     (vif->srst);
   top->sdr_req      (vif->req);
   top->sdr_req_adr  (vif->addr);
   top->sdr_req_len  (vif->req_len);
   top->sdr_req_wr_n (vif->wr_rd);
   top->sdr_req_ack  (vif->req_ack);
   top->sdr_rd_valid (vif->rd_v);
   top->sdr_wr_next  (vif->wr_nxt);
   top->sdr_wr_data  (vif->wdata);
   top->sdr_wr_en_n  (vif->dt_mask);
   top->sdr_rd_data  (vif->rdata);
   top->sdr_init_done(vif->init_f);
   top->sdr_en       (vif->sdr_en);
   top->sdr_mode_reg (vif->m_reg);
   top->sdr_tras_d   (vif->sdr_tras_d);
   top->sdr_trp_d    (vif->sdr_trp_d);
   top->sdr_trcd_d   (vif->sdr_trcd_d);
   top->sdr_cas      (vif->sdr_cas);
   top->sdr_trca_d   (vif->sdr_trca_d);
   top->sdr_twr_d    (vif->sdr_twr_d);
   top->sdr_rfrsh    (vif->sdr_rfrsh);
   top->sdr_rfmax    (vif->sdr_rfmax);
   //_sdram_if
   top->sdc_clk (vif->sclk);
   top->sdc_ad  (mif->sdc_ad);
   top->sdc_ba  (mif->sdc_ba);
   top->sdc_dq  (mif->sdc_dq);
   top->sdc_dqs (mif->sdc_dqs);
   top->sdc_rasb(mif->sdc_rasb);
   top->sdc_casb(mif->sdc_casb);
   top->sdc_web (mif->sdc_web);
   top->sdc_cke (mif->sdc_cke);
   top->sdc_csb (mif->sdc_csb);

   //_memory_1mb_2banks_16
   VMT48LC1M16A1* sdram0 = new VMT48LC1M16A1("sdram0");
   //_mem_if
   sdram0->Ba   (mif->sdc_ba);
   sdram0->Clk  (vif->sdc_clk);
   sdram0->Cke  (mif->sdc_cke);
   sdram0->Cs_n (~mif->sdc_csb);
   sdram0->Ras_n(mif->sdc_rasb);
   sdram0->Cas_n(mif->sdc_casb);
   sdram0->We_n (mif->sdc_web);
   sdram0->Dqm  (mif->sdc_dqm.range    (1,0));
   sdram0->Dq   (mif->sdc_dq.range     (15,0));
   sdram0->Addr (mif->sdc_ad);
   //_tb
   sdr_tb* tb = new sdr_tb("tb");
   tb->connect_if(vif);
}
