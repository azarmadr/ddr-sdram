#ifndef _SDC_AGENT
#define _SDC_AGENT

#include "sdc/mon.h"
#include "sdc/drv.h"
SC_MODULE(agent_sdc){
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
