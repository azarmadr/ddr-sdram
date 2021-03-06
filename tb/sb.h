#ifndef _SDR_SB
#define _SDR_SB

#include <systemc>
#include <uvm>
#include <map>
#include <sstream>
#include "tb/sdc/agent.h"
using namespace uvm;

class sb_sdr: public uvm_scoreboard{
public:
   UVM_COMPONENT_UTILS(sb_sdr);
   uvm_analysis_imp<pkt_sdr, sb_sdr> pkt_export;
   
   sb_sdr(uvm_component_name name)
   : uvm_scoreboard(name),
     pkt_export("pkt_export",this){   }

   virtual void write(const pkt_sdr& tr){}

};

#endif
