agent_name = sdr

driver_inc              = sdr_do_drive.sv   inline
monitor_inc             = sdr_do_monitor.sv inline
if_inc_inside_interface = sdr_if.sv inline
trans_inc_inside_class  = tx_bl.sv inline
agent_seq_inc           = sdr_seq.sv inline

agent_factory_set       = sdr_default_seq sdr_fmt_seq

trans_item = sdr_tx
trans_var  = rand bit [22:0] addr;
trans_var  = rand bit [31:0] data [$];
trans_var  = rand bit [ 1:0] req_len;
trans_var  = rand bit [ 3:0] dt_mask;
trans_var  = rand bit [11:0] mode_reg;
trans_var  = rand bit sel;
trans_var  = rand bit wr_rd;
trans_var  = constraint _dt_mask { dt_mask == 4'b0; }
trans_var  = constraint _dt_sz_r { wr_rd -> data.size==0; }
trans_var  = constraint _dt_sz_w { (!wr_rd) -> data.size==bl(mode_reg[2:0], req_len); }

if_port  = logic sclk;
if_port  = logic mclk;
if_port  = logic srst;
if_port  = logic req;
if_port  = logic wr_rd;
if_port  = logic req_ack;
if_port  = logic rd_v;
if_port  = logic wr_nxt;
if_port  = logic init_f;
if_port  = logic sdr_en;
if_port  = logic sdr_sel;
if_port  = logic [31:0] wdata;
if_port  = logic [31:0] rdata;
if_port  = logic [ 3:0] sdr_twr_d;
if_port  = logic [ 3:0] sdr_tras_d;
if_port  = logic [ 3:0] sdr_trp_d;
if_port  = logic [ 3:0] sdr_trcd_d;
if_port  = logic [ 3:0] sdr_trca_d;
if_port  = logic [ 2:0] sdr_cas;
if_port  = logic [11:0] sdr_rfrsh;
if_port  = logic [ 2:0] sdr_rfmax;
if_port  = logic [ 1:0] req_len;
if_port  = logic [ 3:0] dt_mask;
if_port  = logic [11:0] m_reg;
if_port  = logic [22:0] addr;
if_clock = mclk
if_reset = srst
