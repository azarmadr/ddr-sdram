#ifndef _SEQLIB_H
#define _SEQLIB_H

#include <uvm>
#include <systemc>

#include "sdc/pkt.h"
class sdc_base_s: public uvm_sequence<pkt_sdr>{
public:
   sdc_base_s(const std::string& name="sdc_base_s")
   : uvm_sequence<pkt_sdr>(name){
      set_automatic_phase_objection(1);
   }
   UVM_OBJECT_UTILS(sdc_base_s);
};
class sdc3bl8_s: public sdc_base_s{
public:
   sc_uint<23> addr;
   sc_uint<2 > len;
   bool        wr;
   pkt_sdr* req{nullptr};
   pkt_sdr* rsp{nullptr};

   sdc3bl8_s(const std::string& name="sdc3bl8_s")
   : uvm_sequence<pkt_sdr>(name), addr(0), len(0){
      req = pkt_sdr::type_id::create();
      rsp = pkt_sdr::type_id::create();
   }
   UVM_OBJECT_UTILS(sdc3bl8_s);
   virtual void body(){
      req->addr     = addr;
      req->req_len  = len;
      req->mode_reg = 0x023;
      req->sel      = 1;
      req->wr_rd    = wr;
      req->data     = pkt_gen(wr, 0x023, len);
      
      start_item  (req);
      finish_item (req);
      get_response(rsp);

      UVM_INFO(get_type_name(), rsp.convert2string(), UVM_HIGH);      
   }
   ~sdc3bl8_s(){
      pkt_sdr::type_id::destroy(req);
      pkt_sdr::type_id::destroy(rsp);
   }
};

#endif
