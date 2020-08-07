#ifndef _SDR_ENV
#define _SDR_ENV

#include <systemc>
#include <uvm>
#include "tb/sb.h"
#include "tb/sdc/agent.h"
using namespace uvm;

class env_sdr: public uvm_env{
public:
   UVM_COMPONENT_UTILS(env_sdr);
   agent_sdc* sdc;
   sb_sdr*    sdr_sb;

   env_sdr(uvm_component_name name):
      uvm_env(name), sdc(0), sdr_sb(0)  {}

   void build_phase(uvm_phase& phase){
      sdc    = agent_sdc::type_id::create("sdc",     this);
      sdr_sb = sb_sdr   ::type_id::create("sdr_sb",  this);
      assert(sdr_sb && sdc);
   }
   void connect_phase(uvm_phase& phase){
      sdc->mon->sdc_ap.connect(
	    sdr_sb->pkt_export);
   }
   void end_of_elaboration_phase(uvm_phase& phase){}
};
#endif
