#ifndef _PACKET_H
#define _PACKET_H

#include <vector>
#include "systemc.h"
struct pkt_sdr{
   sc_bv<23>         addr;
   vector<uint32_t>  data;
   sc_bv<2>          req_len;
   bool wr_rd;
}
inline void ostream& operator << (ostream& os, const pkt_sdr& p){
   os<<"_SDC_Packet"<<endl;
   os<<pkt.addr<<endl;
   if(pkt.wr_rd_n){
      os<<pkt.rdata<<endl;
   } else {
      os<<pkt.wdata<<endl;
   }
   os<<"_Burst_type"<<pkt.req_len;
   return os;
}
void pkt_gen(pkt* p, sc_bv<12> r){
   int l;
   p->addr   =rand();//should change later to accomodate
   p->req_len=rand();//testcases
   p->wr_rd  =rand();

   if(p->wr_rd){
      if (r.range(2,0) == "111")
	 l=2^(2+p->req_len);
      else{
	 int k;
	 l=1;
	 k=(p->req_len - (int)r.range(1,0)+1)%8;
	 if(r(0)) l*=2;
	 if(r(1)) l*=4;
	 l*=2^k;
      }
      for(int i=0;i<l;i++){
	 p->data.push_back(rand());
      };
   }
}
#endif
