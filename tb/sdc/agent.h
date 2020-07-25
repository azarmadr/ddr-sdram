#ifndef _SDC_AGENT
#define _SDC_AGENT

#include "sdc/mon.h"
#include "sdc/drv.h"
#include "sdc/seqr.h"
class agent_sdc: uvm_agent{
public:
   //if_sdc  vif;
   drv_sdc drv;
   mon_sdc mon;

   //void connect_if(if_sdc* _vif);

   SC_CTOR(agent_sdc):
      drv("drv"),
      mon("mon")
   {
   }
};
#endif
