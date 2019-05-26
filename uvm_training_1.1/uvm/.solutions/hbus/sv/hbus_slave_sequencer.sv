/*-----------------------------------------------------------------
File name     : hbus_slave_sequencer.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:20 2009
Description   :
Notes         :
-------------------------------------------------------------------
Copyright 2009 (c) Cadence Design Systems
-----------------------------------------------------------------*/

`ifndef HBUS_SLAVE_SEQUENCER_SV
`define HBUS_SLAVE_SEQUENCER_SV

//------------------------------------------------------------------------------
//
// CLASS: hbus_slave_sequencer
//
//------------------------------------------------------------------------------

class hbus_slave_sequencer extends uvm_sequencer #(hbus_transaction);

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils(hbus_slave_sequencer)

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : hbus_slave_sequencer

`endif // HBUS_SLAVE_SEQUENCER_SV
