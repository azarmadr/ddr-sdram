#ifndef _SDR_TB
#define _SDR_TB

#include "sdc/agent.h"
SC_MODULE(sdr_tb){
   if_sdc* vif;

   sc_port<sc_fifo_in_if<if_sdc*> >   sdc_if_f;
   sc_port<sc_fifo_out_if<if_sdc*> >  drv_if_f;
   sc_port<sc_fifo_out_if<if_sdc*> >  mon_if_f;

   drv_sdc drv;
   mon_sdc mon;

   SC_CTOR(agent_sdc):
      drv("drv"),
      mon("mon"){
	 sdc_if_f->read (vif);
	 drv_if_f->write(vif);
	 mon_if_f->write(vif);
      }
}
#endif
