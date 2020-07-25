#ifndef _SDC_SEQR
#define _SDC_SEQR

#include <systemc>
#include <uvm>

class seqr_sdc: public uvm_sequencer<pkt_sdr>{
public:
   UVM_COMPONENT_UTILS(seqr_sdc);
   seqr_sdc(uvm_component_name name)
   :uvm_sequencer<pkt_sdr>(name) {}
}
#endif
