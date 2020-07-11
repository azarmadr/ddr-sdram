#ifndef _SDR_TB
#define _SDR_TB

#include "sdc/agent.h"
SC_MODULE(sdr_tb){
   if_sdc*    vif;
   agent_sdc  sdc_a;

   void connect_if(if_sdc * vif);

   SC_CTOR(sdr_tb):
      sdc_a("sdc_a")
   {
      sdc_a.connect_if(vif);
   }
}
void sdr_tb::connect_if(if_sdc * vif){
   this.vif=vif;
}
#endif
