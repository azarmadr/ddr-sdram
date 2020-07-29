#ifndef _SDR_TB
#define _SDR_TB

#include "tb/sb.h"
#include "tb/env.h"
#include "tb/sdr_seq.h"
#include "tb/sdc/agent.h"
#include "tb/sdc/seq.h"

class sdr_tb: uvm_env{
public:
   env_sdr* sdr_e;
   sb_sdr*  sdr_sb;

   UVM_COMPONENT_UTILS(sdr_tb);
   sdr_tb(uvm_component_name name)
   : uvm_env(name), sdr_e(0), sdr_sb(0) {}

   virtual void build_phase(uvm_phase& phase){
      uvm_env::build_phase(phase);

      sdr_e  = env_sdr::type_id::create("sdr_e" ,this);
      sdr_sb = sb_sdr ::type_id::create("sdr_sb",this);

      assert(sdr_sb && sdr_e);
   }
   void connect_phase(uvm_phase& phase){
      sdr_e->sdc->mon->sdc_ap.connect(
	    sdr_sb->pkt_export);
   }
   void end_of_elaboration_phase(uvm_phase& phase){}
};
#endif
