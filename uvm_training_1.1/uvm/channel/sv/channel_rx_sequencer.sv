/*-----------------------------------------------------------------
File name     : channel_rx_sequencer.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:24 2009
Description   : This file declares the sequencer the s.
Notes         : 
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

`ifndef CHANNEL_RX_SEQUENCER_SV
`define CHANNEL_RX_SEQUENCER_SV

//------------------------------------------------------------------------------
//
// CLASS: channel_rx_sequencer
//
//------------------------------------------------------------------------------

class channel_rx_sequencer extends uvm_sequencer #(channel_resp);

   virtual interface channel_if vif;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils(channel_rx_sequencer)

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase()
  function void build_phase(uvm_phase phase);
    if (!channel_vif_config::get(this, get_full_name(),"vif", vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: build_phase

endclass : channel_rx_sequencer

`endif // CHANNEL_RX_SEQUENCER_SV

