/*-----------------------------------------------------------------
File name     : hbus_master_sequencer.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:21 2009
Description   :
Notes         :
-------------------------------------------------------------------
Copyright 2009 (c) Cadence Design Systems
-----------------------------------------------------------------*/

`ifndef HBUS_MASTER_SEQUENCER_SV
`define HBUS_MASTER_SEQUENCER_SV

//------------------------------------------------------------------------------
//
// CLASS: hbus_master_sequencer
//
//------------------------------------------------------------------------------

class hbus_master_sequencer extends uvm_sequencer #(hbus_transaction);

  // Master Id
  int master_id;

  `uvm_component_utils(hbus_master_sequencer)

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : hbus_master_sequencer

`endif // HBUS_MASTER_SEQUENCER_SV

