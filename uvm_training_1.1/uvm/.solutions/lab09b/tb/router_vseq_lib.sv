/*-----------------------------------------------------------------
File name     : router_vseq_lib.sv
Developers    : Kathleen Meade
Created       : 01/06/09
Description   : Virtual sequence library for the router virtual
              : sequencer in lab09
Notes         :
-------------------------------------------------------------------
Copyright 2009 (c) Cadence Design Systems
-----------------------------------------------------------------*/

//----------------------------------------------------------------------------
// SEQUENCE: router_simple_vseq
//----------------------------------------------------------------------------
class router_simple_vseq extends uvm_sequence;
  
  `uvm_sequence_utils(router_simple_vseq, router_virtual_sequencer)    

  // Generic YAPP packets sequences
  yapp_simple_seq yapp_simple_seq;
  yapp_012_seq    yapp_addr_seq;

  // HBUS sequences
  hbus_small_packet_seq     hbus_small_pkt_seq;
  hbus_read_seq             hbus_rd_seq;     
  hbus_set_default_regs_seq hbus_large_pkt_seq;

  function new(string name="router_simple_vseq");
    super.new(name);
  endfunction
 
  virtual task body();
    uvm_test_done.raise_objection(this, get_type_name());
    `uvm_info("router_simple_vseq", "Executing sequence router_simple_vseq", UVM_LOW )
    // Configure for small packets
    `uvm_do_on(hbus_small_pkt_seq, p_sequencer.hbus_seqr)
    // Read the YAPP MAXPKTSIZE register (address 0)
    //`uvm_do_on_with(hbus_rd_seq, p_sequencer.hbus_seqr, {hbus_rd_seq.address == 0;})
    // send 6 consecutive packets to addresses 0,1,2, cycling the address
    `uvm_do_on(yapp_addr_seq, p_sequencer.yapp_seqr)
    `uvm_do_on(yapp_addr_seq, p_sequencer.yapp_seqr)
    // Configure for large packets (default)
    `uvm_do_on(hbus_large_pkt_seq, p_sequencer.hbus_seqr)
    // Read the YAPP MAXPKTSIZE register (address 0)
    `uvm_do_on_with(hbus_rd_seq, p_sequencer.hbus_seqr, {hbus_rd_seq.address == 0;})
    // Send 5 random packets
    `uvm_do_on_with(yapp_simple_seq, p_sequencer.yapp_seqr, {yapp_simple_seq.count == 5;})
    uvm_test_done.drop_objection(this, get_type_name());
  endtask

endclass : router_simple_vseq

