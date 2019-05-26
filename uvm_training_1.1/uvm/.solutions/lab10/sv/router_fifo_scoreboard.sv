/*-----------------------------------------------------------------
File name     : router_scoreboard.sv
Developers    : Kathleen Meade
Created       : 01/04/11
Description   : This file implements the router scoreboard for lab09.
              : 
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: router_scoreboard
//
//------------------------------------------------------------------------------
class router_fifo_scoreboard extends uvm_scoreboard;

   uvm_tlm_analysis_fifo #(yapp_packet) yapp_fifo, chan0_fifo, chan1_fifo, chan2_fifo;
   uvm_tlm_analysis_fifo #(hbus_transaction) hbus_fifo;

   uvm_blocking_get_port #(yapp_packet) sb_yapp_in;
   uvm_blocking_get_port #(yapp_packet) sb_chan0_in;
   uvm_blocking_get_port #(yapp_packet) sb_chan1_in;
   uvm_blocking_get_port #(yapp_packet) sb_chan2_in;
   uvm_blocking_get_port #(hbus_transaction) sb_hbus_in;
   
   // Scoreboard Statistics
   int packets_in = 0;
   int packets_ch [2:0];
   int compare_ch [2:0];
   int miscompare_ch [2:0];
   int packets_dropped   = 0;
   int packets_valid     = 0;
   int jumbo_packets     = 0;
   int bad_addr_packets  = 0;
   int disabled_packets  = 0;

   // Router registers
   bit [7:0] max_pktsize_reg = 8'h3F;
   bit [7:0] router_enable_reg = 1'b1;


   // Constructor
   function new(string name="", uvm_component parent=null);
     super.new(name, parent);
     sb_yapp_in = new("sb_yapp_in", this);
     sb_chan0_in = new("sb_chan0_in", this);
     sb_chan1_in = new("sb_chan1_in", this);
     sb_chan2_in = new("sb_chan2_in", this);
     sb_hbus_in = new("sb_hbus_in", this);
     yapp_fifo = new("yapp_fifo", this);
     chan0_fifo = new("chan0_fifo", this);
     chan1_fifo = new("chan1_fifo", this);
     chan2_fifo = new("chan2_fifo", this);
     hbus_fifo = new("hbus_fifo", this);
   endfunction
      
   `uvm_component_utils(router_fifo_scoreboard)
   
   function void connect_phase(uvm_phase phase);
     sb_yapp_in.connect(yapp_fifo.blocking_get_export);
     sb_chan0_in.connect(chan0_fifo.blocking_get_export);
     sb_chan1_in.connect(chan1_fifo.blocking_get_export);
     sb_chan2_in.connect(chan2_fifo.blocking_get_export);
     sb_hbus_in.connect(hbus_fifo.blocking_get_export);
   endfunction

   task run_phase(uvm_phase phase);
     fork
       check_packet();
       update_regr();
     join
   endtask 

   task update_regr();
     hbus_transaction hb;
     forever begin
       // get transaction from hbus
       sb_hbus_in.get(hb);
       `uvm_info(get_type_name(), $sformatf("Scoreboard: Received HBUS Transaction: \n%s", hb.sprint()), UVM_MEDIUM)
       // capture the max_pktsize_reg and router_enable_reg
       // values whenever a hbus transaction is written
       if (hb.hwr_rd == HBUS_WRITE)
         case (hb.haddr)
           'h00 : max_pktsize_reg = hb.hdata;
           'h01 : router_enable_reg = hb.hdata;
         endcase
     end 
   endtask
     
   task check_packet();
     yapp_packet yapp_pkt, chan_pkt;
     bit valid;
     logic [1:0] paddr;
     forever begin
       do begin
         // get packet from yapp
         sb_yapp_in.get(yapp_pkt);
         `uvm_info(get_type_name(), $sformatf("Scoreboard: Packet got from yapp analysis fifo %s",yapp_pkt.sprint()), UVM_MEDIUM)
         packets_in++;
         // check validity
         valid = 1'b1;
         if (yapp_pkt.addr == 3) begin
           bad_addr_packets++;
           packets_dropped++;
           `uvm_info(get_type_name(), "Scoreboard: YAPP Packet Dropped [BAD ADDRESS]", UVM_LOW)
           valid = 1'b0;
         end
         else if ((router_enable_reg == 1) && (yapp_pkt.length > max_pktsize_reg))begin
           jumbo_packets++;
           packets_dropped++;
           `uvm_info(get_type_name(), "Scoreboard: YAPP Packet Dropped [OVERSIZED]", UVM_LOW)
           valid = 1'b0;
         end
         else if (router_enable_reg == 0) begin
           disabled_packets++;
           packets_dropped++;
           `uvm_info(get_type_name(), "Scoreboard: YAPP Packet Dropped [DISABLED]", UVM_LOW)
           valid = 1'b0;
         end
       end
       while (valid == 1'b0);
       packets_valid++;
       packets_ch[yapp_pkt.addr]++;
       // get packet from channel
       case (yapp_pkt.addr)
         0 : sb_chan0_in.get(chan_pkt);
         1 : sb_chan1_in.get(chan_pkt);
         2 : sb_chan2_in.get(chan_pkt);
       endcase
       `uvm_info(get_type_name(), "Scoreboard: Packet got from chan analysis fifo", UVM_LOW)
       // compare packets
       if( chan_pkt.compare(yapp_pkt)) begin
          paddr = chan_pkt.addr;
          `uvm_info(get_type_name(), $sformatf("Scoreboard Compare Match: Channel_%0d", paddr), UVM_LOW)
          `uvm_info(get_type_name(), $sformatf("Scoreboard Matched Packet: \n%s", chan_pkt.sprint()), UVM_MEDIUM)
          compare_ch[paddr]++;
       end
       else begin
          `uvm_warning(get_type_name(), $sformatf("Scoreboard Error [MISCOMPARE]: Received Channel Packet:\n%s\nExpected YAPP Packet:\n%s", chan_pkt.sprint(), yapp_pkt.sprint()))
           miscompare_ch[paddr]++;
       end
     end // forever
   endtask : check_packet 

// UVM check_phase
function void check_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "Scoreboard: Checking Router Scoreboard", UVM_LOW)
  if (yapp_fifo.is_empty() && chan0_fifo.is_empty() && chan1_fifo.is_empty() && chan2_fifo.is_empty())
   `uvm_info(get_type_name(), "Check:\n\n   Router Scoreboard Empty!\n", UVM_LOW)
  else
  `uvm_warning(get_type_name(), $sformatf( { "Check:\n\nWARNING: Router Scoreboard FIFO's NOT Empty:\n", 
    "     YAPP : %0d     Chan0 : %0d     Chan1 : %0d     Chan2 : %0d" } , 
    yapp_fifo.size(), chan0_fifo.size(), chan1_fifo.size(), chan2_fifo.size()))
endfunction : check_phase

// UVM report() phase
function void report_phase(uvm_phase phase);
  `uvm_info(get_type_name(), $sformatf( { "Report:\n\n   Scoreboard: Packet Statistics \n     " , 
    "     Packets In:\t%0d\n" , 
    "     Packets Dropped:\t%0d\n" , 
    "       - Address 3 packets:\t%0d\n" ,
    "       - Oversized packets:\t%0d\n" ,
    "       - Disabled packets:\t%0d\n" ,
    "     Packets Valid:\t%0d\n\n" , 
    "     Channel 0 Total: %0d  Pass: %0d  Miscompare: %0d\n" , 
    "     Channel 1 Total: %0d  Pass: %0d  Miscompare: %0d\n" , 
    "     Channel 2 Total: %0d  Pass: %0d  Miscompare: %0d\n\n" }, 
    packets_in, packets_dropped, bad_addr_packets, jumbo_packets, disabled_packets, packets_valid,
    packets_ch[0], compare_ch[0], miscompare_ch[0], 
    packets_ch[1], compare_ch[1], miscompare_ch[1], 
    packets_ch[2], compare_ch[2], miscompare_ch[2]), UVM_LOW)
endfunction : report_phase

endclass : router_fifo_scoreboard
       
