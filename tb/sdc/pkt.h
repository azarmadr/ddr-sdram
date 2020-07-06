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
#endif
