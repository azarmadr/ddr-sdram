#ifndef _PACKET_H
#define _PACKET_H

#include <uvm>
#include <vector>
#include <systemc>
class pkt_sdr: public uvm_sequence_item{
public:
   sc_uint<23>            addr;
   std::vector<uint32_t>  data;
   sc_uint<2>             req_len;
   sc_uint<12>            mode_reg;
   bool                   sel,wr_rd;

   UVM_OBJECT_UTILS(pkt_sdr);
   pkt_sdr(const std::string name = "pkt sdr")
      :uvm_sequence_item(name){
      addr    = 0x080000;
      data    = {};
      wr_rd   = 0;
      req_len = 0;
   inline bool operator == (const pkt_sdr& rhs) const{
      return(req_len == rhs.req_len && addr == rhs.addr && data == rhs.data);
   }
   std::string convert2string() const;
};
std::string convert2string() const{
   std::ostreamstring msg;
   msg<<get_sequence_path()
      <<"addr  : "<< addr
      <<"len   : "<< req_len
      <<"mode  : "<< mode_reg
      <<"wr/rd : "<<(wr_rd ? "READ"  : "WRITE")
      <<"rate  : "<<(sel   ? "SDRAM" : "DDR")
      <<"data  : "<< data.size()<<endl;

   for(auto d: rsp->data) msg
      <<d <<"  ";
   return msg.str();
}
std::vector<uint32_t> pkt_gen(bool wr, sc_uint<12> r, unsigned int len){
   int l;
   std::vector<uint32_t> data;
   if(wr) return
   if (r.range(2,0) == 7)
      l=2^(2+len);
   else{
      int k;
      l=1;
      k=(len-(r.range(1,0))+1)%8;
      if(r[0]) l*=2;
      if(r[1]) l*=4;
      l*=2^k;
   }
   for(int i=0;i<l;i++){
      data.push_back(rand());
   }
   return data;
}
#endif
