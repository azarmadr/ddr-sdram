#ifndef _SDR_ENV
#define _SDR_ENV

#include <systemc>
#include <uvm>
using namespace uvm;

//_forward_declerations
class if_sdc;
class agent_sdc;

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
