#ifndef _SDR_ENV
#define _SDR_ENV

#include <systemc>
#include <uvm>
#include "tb/sdc/agent.h"
using namespace uvm;

class env_sdr: uvm_env{
public:
   agent_sdc* sdc;
   UVM_COMPONENT_UTILS(env_sdr);
   env_sdr(uvm_component_name name):
      uvm_env(name)
   {}

   void build_phase(uvm_phase& phase){
      sdc = agent_sdc::type_id::create("sdc", this);
   }
};
#endif
