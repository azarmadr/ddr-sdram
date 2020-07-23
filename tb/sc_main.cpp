#include <stdio.h>
#include <iostream>
#include <sys/times.h>
#include <sys/stat.h>

#include "systemc.h"
#include "verilated.h"
#include "verilated_vcd_sc.h"

#include "Vsdc_agent.h"
#include "sdr_tb.h"

int sc_main(int argc, char* argv[]){
   Verilated::randReset(2);
   Verilated::debug(0);

   //sc_set_time_resolution(100, SC_PS);
   sc_get_time_resolution();
   sc_clock mclk("m-clk", 5, SC_NS);

   //_Sdc_interface
   if_sdc* vif = new if_sdc("vif");

   //_Dut
   Vsdc_agent* top = new Vsdc_agent("top");
   //_host_if
   top->mclk         (mclk);
   top->s_resetn     (vif->srst);
   top->sdc_req      (vif->req);
   top->sdc_en       (vif->sdr_en);
   top->sdc_req_wr_n (vif->wr_rd);
   top->sdc_sel      (vif->sdc_sel);
   top->sdc_tras_d   (vif->sdr_tras_d);
   top->sdc_trp_d    (vif->sdr_trp_d);
   top->sdc_trcd_d   (vif->sdr_trcd_d);
   top->sdc_cas      (vif->sdr_cas);
   top->sdc_trca_d   (vif->sdr_trca_d);
   top->sdc_twr_d    (vif->sdr_twr_d);
   top->sdc_rfmax    (vif->sdr_rfmax);
   top->sdc_req_adr  (vif->addr);
   top->sdc_req_len  (vif->req_len);
   top->sdc_req_ack  (vif->req_ack);
   top->sdc_rd_valid (vif->rd_v);
   top->sdc_wr_next  (vif->wr_nxt);
   top->sdc_wr_data  (vif->wdata);
   top->sdc_wr_en_n  (vif->dt_mask);
   top->sdc_rd_data  (vif->rdata);
   top->sdc_init_done(vif->init_f);
   top->sdc_mode_reg (vif->m_reg);
   top->sdc_rfrsh    (vif->sdr_rfrsh);
   //_sdram_if
   top->sdc_clk (vif->sclk);

   //_tb
   sdr_tb* tb = new sdr_tb("tb");
   tb->connect_if(vif);
   
   Verilated::traceEverOn(true);

   vif->srst = 0;
   sc_start(20,SC_NS);

   cout << "Enabling waves...\n";
   VerilatedVcdSc* tfp = new VerilatedVcdSc;
   top->trace (tfp, 99);
   tfp->open ("./vl.vcd");

   for(int i;i<999;i++){//while(!sb_t->done){
      tfp->flush();

      vif->srst= 1;
      sc_start(1,SC_NS);
   }

   top->final();
   tfp->close();

   delete top;
   top = NULL;

   return 0;

}
