/*-----------------------------------------------------------------
File name     : channel_tx_seqs.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:24 2009
Description   : This file implements several sequence kinds
Notes         : Each sequence implements a typical scenario or a
              : combination of existing scenarios.
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

`ifndef CHANNEL_TX_SEQ_LIB_SV
`define CHANNEL_TX_SEQ_LIB_SV

//------------------------------------------------------------------------------
//
// SEQUENCE: base channel sequence - base sequence with objections from which
// all sequences can be derived
//
//------------------------------------------------------------------------------
class chan_tx_base_seq extends uvm_sequence#(yapp_packet);

  // Required macro for sequences automation
  `uvm_object_utils(chan_tx_base_seq)

  string phase_name;
  uvm_phase phaseh;

  // Constructor
  function new(string name="chan_tx_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    starting_phase.raise_objection(this, get_type_name());
    phase_name = starting_phase.get_name();
    `uvm_info(get_type_name(), {"raise objection in phase", phase_name}, UVM_MEDIUM)
  endtask : pre_body

  task post_body();
    starting_phase.drop_objection(this, get_type_name());
    `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
  endtask : post_body

endclass : chan_tx_base_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: channel_tx_packet_seq
//
//------------------------------------------------------------------------------
 
class channel_tx_packet_seq extends chan_tx_base_seq;
  
  // Sequence data item
  yapp_packet packet;

  // Required macro for sequences automation
  `uvm_object_utils(channel_tx_packet_seq)

  // Constructor
  function new(string name="channel_tx_packet_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    begin
      `uvm_info(get_type_name(),"Executing ...", UVM_LOW)
      `uvm_do(packet)
    end
  endtask
  
endclass : channel_tx_packet_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: channel_tx_nested_seq
//
//------------------------------------------------------------------------------
 
class channel_tx_nested_seq extends chan_tx_base_seq;

  // Sequence that will be called in this sequence
  channel_tx_packet_seq channel_seq;

  // Required macro for sequences automation
  `uvm_object_utils(channel_tx_nested_seq)
  `uvm_declare_p_sequencer(channel_tx_sequencer)

  // Parameter for this sequence
  rand int itr;

  // Sequence Constraints
  constraint itr_size_ct { itr inside {[1:8]}; }

  // Constructor
  function new(string name="channel_tx_nested_seq");
    super.new(name);
  endfunction
  
  // Sequence body definition
  virtual task body();
    begin
      `uvm_info(get_type_name(), $sformatf("Executing %0d channel_tx_packet sequences",itr), UVM_LOW)
      void'(p_sequencer.get_config_int("channel_tx_nested_seq.itr", itr));
      for(int i = 0; i < itr; i++) begin
        `uvm_do(channel_seq)
      end
    end
  endtask
  
endclass : channel_tx_nested_seq

`endif // CHANNEL_TX_SEQ_LIB_SV
