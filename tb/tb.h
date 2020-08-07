#ifndef _SDR_TB
#define _SDR_TB

#include "tb/env.h"
#include "tb/sdr_seq.h"
#include "tb/sdc/agent.h"
#include "tb/sdc/seq.h"

class sdr_base_t:public uvm_test{
public:
   UVM_COMPONENT_UTILS(sdr_base_t);

   uvm_table_printer* printer{nullptr};
   env_sdr*           env    {nullptr};

   sdr_base_t(uvm_component_name name = "sdr_base_t")
   : uvm_test(name){}

   virtual void build_phase(uvm_phase& phase){
      uvm_test::build_phase(phase);

      env = env_sdr::type_id::create("env" ,this);
      assert(env);
      printer = new uvm_table_printer();
   }
   void end_of_elaboration_phase(uvm_phase& phase){
      UVM_INFO(get_type_name(), "_Topology__" +
            this->sprint(printer), UVM_LOW);
   }
   void run_phase(uvm_phase& phase){
      sc_time drain_time = sc_time(50.0, SC_NS);
      phase.get_objection()->set_drain_time(this,drain_time);
   }
   void extract_phase(uvm_phase& phase){}
   void report_phase (uvm_phase& phase){}
   void final_phase  (uvm_phase& phase){
      delete printer;
   }
};
class sdc3bl8_rw_t: public sdr_base_t{
public:
   UVM_COMPONENT_UTILS(sdc3bl8_rw_t);
   sdc3bl8_rw_s* seq;

   sdc3bl8_rw_t (uvm_component_name name = "sdc3bl8_rw_t"):
      sdr_base_t(name)
   {}
   virtual void build_phase(uvm_phase& phase){
      uvm_config_db<uvm_object_wrapper*>::set(this,
            "env.sdc.seqr.run_phase","default_sequence",
            sdc3bl8_rw_s::type_id::get());/*
      uvm_config_db<uvm_object_wrapper*>::set(this,
            "env.sdc.seqr.main_phase","default_sequence",
            sdc3bl8_rw_s::type_id::get());*/
      sdr_base_t::build_phase(phase);
   }/*
   void run_phase(uvm_phase& phase){
      sdr_base_t::run_phase(phase);
      seq = sdc3bl8_rw_s::type_id::create("seq");
      seq->start(env->sdc->seqr);
      seq->wait_for_sequence_state(UVM_FINISHED);
   }*/
};
#endif
