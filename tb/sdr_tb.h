#ifndef _SDR_TB
#define _SDR_TB

#include "sdc/agent.h"
//#include "mem/ifc.h"
SC_MODULE(sdr_tb){
   if_sdc*    vif;
   agent_sdc  sdc_a;

   void connect_if(if_sdc * _vif){
      vif=_vif;
   }

   SC_CTOR (sdr_tb):
      sdc_a("sdc_a")
   {
      sdc_a.mon.connect_if(vif);
      sdc_a.drv.connect_if(vif);
   }
};
#endif
