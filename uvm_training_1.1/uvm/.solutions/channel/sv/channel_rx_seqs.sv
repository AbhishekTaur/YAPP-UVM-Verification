/*-----------------------------------------------------------------
File name     : channel_rx_seqs.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:24 2009
Description   : This file implements several sequence kinds
Notes         : Each sequence implements a typical scenario or a
              : combination of existing scenarios.
              : Cadence recommends defining reusable sequences in 
              : this directory and project-specific sequences in the
              : project directory ("examples").
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

`ifndef CHANNEL_RX_SEQ_LIB_SV
`define CHANNEL_RX_SEQ_LIB_SV

//------------------------------------------------------------------------------
//
// DO NOT raise objections for the receiving channel sequences as these are
// executed in a forever loop
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// SEQUENCE: channel_rx_resp_seq
//------------------------------------------------------------------------------
class channel_rx_resp_seq extends uvm_sequence#(channel_resp);

  // Required macro for sequences automation
  `uvm_object_utils(channel_rx_resp_seq)
  `uvm_declare_p_sequencer(channel_rx_sequencer) 
  // Constructor
  function new(string name="channel_rx_resp_seq");
    super.new(name);
  endfunction
  
  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(),"Executing channel_rx_resp_seq (forever)", UVM_LOW)
    // Allocate once
    `uvm_create(req)
    forever begin
      // wait for data valid to get the next response
       @(posedge p_sequencer.vif.clock iff p_sequencer.vif.data_vld == 1'b1);
       // Randomize and send many times
       `uvm_rand_send(req)
    end
  endtask : body
  
endclass : channel_rx_resp_seq
 
//------------------------------------------------------------------------------
// SEQUENCE: channel_rx_long_resp_seq
//------------------------------------------------------------------------------
class channel_rx_long_resp_seq extends uvm_sequence#(channel_resp);

  // Required macro for sequences automation
  `uvm_object_utils(channel_rx_long_resp_seq)
  `uvm_declare_p_sequencer(channel_rx_sequencer) 
  
  // Constructor
  function new(string name="channel_rx_long_resp_seq");
    super.new(name);
  endfunction
  
  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(),"Executing (forever)", UVM_LOW)
    // Allocate once
    `uvm_create(req)
    req.default_delay.constraint_mode(0);
    forever begin
      // wait for data valid to get the next response
       @(posedge p_sequencer.vif.clock iff p_sequencer.vif.data_vld == 1'b1);
       // Randomize and send many times
       `uvm_rand_send_with(req, {resp_delay inside {[0:65]};})
       //`uvm_rand_send(req)
    end
  endtask : body
  
endclass : channel_rx_long_resp_seq
 
`endif // CHANNEL_RX_SEQ_LIB_SV
