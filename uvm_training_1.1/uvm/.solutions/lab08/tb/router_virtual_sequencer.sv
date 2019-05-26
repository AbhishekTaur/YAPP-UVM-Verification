/*-----------------------------------------------------------------
File name     : router_virtual_sequencer.sv
Developers    : Kathleen Meade
Created       : 01/04/11
Description   : Virtual sequencer for router lab08
Notes         :
-------------------------------------------------------------------
Copyright 2011 (c) Cadence Design Systems
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: router_virtual_sequencer
//
//------------------------------------------------------------------------------

class router_virtual_sequencer extends uvm_sequencer;

   hbus_master_sequencer hbus_seqr;
   yapp_tx_sequencer     yapp_seqr;
   // handle for channel sequencer is optional as the
   // channel sequencer has only one sequence choice

  `uvm_component_utils(router_virtual_sequencer)

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : router_virtual_sequencer

