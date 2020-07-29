#ifndef _SDC_AGENT
#define _SDC_AGENT

#include "tb/sdc/mon.h"
#include "tb/sdc/drv.h"
#include "tb/sdc/seqr.h"

class agent_sdc: uvm_agent{
public:
   //if_sdc  vif;
   drv_sdc*   drv;
   mon_sdc*   mon;
   seqr_sdc*  seqr;

   UVM_COMPONENT_UTILS(agent_sdc);
   agent_sdc(uvm_component_name name):
      uvm_agent(name),
      drv(0), mon(0), seqr(0)
   {}
   void build_phase(uvm_phase& phase){
      uvm_agent::build_phase(phase);
      mon = mon_sdc::type_id::create("mon",this);
      assert(mon);
      if(get_is_active()==UVM_ACTIVE){
	 drv  =  drv_sdc::type_id::create("drv",    this);
	 seqr =  seqr_sdc::type_id::create("seqr",  this);
	 assert(drv && seqr);
      }
   }
   void connect_phase(uvm_phase& phase){
      if(get_is_active()==UVM_ACTIVE)
	 drv->seq_item_port.connect(seqr->seq_item_export);
   }
};
#endif
