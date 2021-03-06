#ifndef _SDR_SEQ
#define _SDR_SEQ

#include <systemc>
#include <uvm>
#include <sstream>

#include "tb/sdc/agent.h"
#include "tb/sdc/seq.h"

class sdc3bl8_rw_s: public sdc_base_s{
public:
   sdc3bl8_rw_s(const std::string& name = "sdc3bl8_rw_s")
   : sdc_base_s(name) {
      seq = sdc3bl8_s::type_id::create();
   }
   UVM_OBJECT_UTILS(sdc3bl8_rw_s);

   sdc3bl8_s* seq{nullptr};
   bool wr;
   std::map<unsigned int, sc_uint<23> > addr_k;

   virtual void body(){
      std::ostringstream msg;
      msg<< get_sequence_path()
         << "_starting__";
      UVM_INFO(get_type_name(), msg.str(), UVM_HIGH);

      for(int i=0;i<4;i++)
         addr_k[i] = rand();
      for(int i;i<3;i++){
         wr ^= 1;
         for(auto const &pair: addr_k){
            seq->len      = pair.first;
	    seq->mode_reg = 0x037;
            seq->addr     = pair.second;
            seq->wr       = wr;
            seq->start(m_sequencer);
         }
      }
      sdc3bl8_s::type_id::destroy(seq);
      UVM_INFO(get_type_name(), "_sequence_fin", UVM_HIGH);
   }
};
#endif
