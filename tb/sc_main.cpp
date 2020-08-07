#include <stdio.h>
#include <iostream>
#include <sys/times.h>
#include <sys/stat.h>

#include "tb/tb.h"
#include "verilated.h"
#include "verilated_vcd_sc.h"

#include "Vsdc_agent.h"

class stim : public sc_module
{
 public:
  sc_out<bool> reset;

  SC_HAS_PROCESS(stim);

  stim(sc_module_name nm)
  : sc_module(nm), reset("reset")
  {
    SC_THREAD(run_reset);
  }

  void run_reset()
  {
    reset.write(1);
    wait(SC_ZERO_TIME);
    reset.write(0);
    wait(20.0, SC_NS);
    reset.write(1);
  }
};

int sc_main(int argc, char* argv[]){
   uvm_set_verbosity_level(uvm::UVM_FULL);

   Verilated::debug(0);

   sc_clock mclk("m-clk", 5, SC_NS);

   //_Sdc_interface
   if_sdc* vif = new if_sdc("vif");
   uvm::uvm_config_db<if_sdc*>::set(uvm::uvm_root::get(),"*","vif",vif);

   //_Dut
   Vsdc_agent* top = new Vsdc_agent("top");
   //_host_if
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
   top->mclk    (mclk);

   stim tb_stim("tb_stim");
   tb_stim.reset.bind(vif->srst);

   Verilated::traceEverOn(true);

   //sc_trace_file* tf = sc_core::sc_create_vcd_trace_file("traces_sc");
   //sc_trace(tf, vif->srst, "srst");

   VerilatedVcdSc* tfp = new VerilatedVcdSc;
   top->trace (tfp, 99);
   tfp->open ("./vl.vcd");

   uvm::run_test("sdc3bl8_rw_t");

   top->final();
   tfp->flush();
   tfp->close();

   delete top;
   top = NULL;

   return 0;
}
