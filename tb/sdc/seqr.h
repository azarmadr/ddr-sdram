#ifndef _SDC_SEQR
#define _SDC_SEQR

#include <systemc>
#include <uvm>

class sdc_sequencer: public uvm_sequencer<pkt_sdr>{
public:
   UVM_COMPONENT_UTILS(sdc_sequencer);
   sdc_sequencer(uvm_component_name name)
   :uvm_sequencer<pkt_sdr>(name) {}
}
#endif
