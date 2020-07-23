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
};
inline ostream& operator << (ostream& os, const pkt_sdr& p){
   os<<"_SDC_Packet"<<endl;
   os<<p.addr<<endl;
   if(p.wr_rd){
      os<<"read";
   } else {
      os<<"write";
   }
   for(uint32_t kv: p.data)   os<<kv<<" ";
   os<<endl;
   os<<"_Burst_type"<<p.req_len;
   return os;
}
//void rand_pkt(){
void pkt_gen(pkt_sdr* p, sc_uint<12> r){
   int l;
   p->addr   =rand();//should change later to accomodate
   p->req_len=rand();//testcases
   p->wr_rd  =rand();

   if(p->wr_rd){
      if (r.range(2,0) == 7)
	 l=2^(2+p->req_len);
      else{
	 int k;
	 l=1;
	 k=(p->req_len-(r.range(1,0))+1)%8;
	 if(r[0]) l*=2;
	 if(r[1]) l*=4;
	 l*=2^k;
      }
      for(int i=0;i<l;i++){
	 p->data.push_back(rand());
      }
   }
}
#endif
