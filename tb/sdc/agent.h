#ifndef _SDC_AGENT
#define _SDC_AGENT

#include "sdc/mon.h"
#include "sdc/drv.h"
SC_MODULE(agent_sdc){
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
