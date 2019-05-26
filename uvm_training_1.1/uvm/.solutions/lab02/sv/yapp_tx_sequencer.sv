/*-----------------------------------------------------------------
File name     : yapp_tx_sequencer.sv
Developers    : Kathleen Meade, Brian Dickinson
Created       : 01/04/11
Description   : This file declares the simple sequencer for the YAPP TX for lab02.
Notes         : 
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: yapp_tx_sequencer
//
//------------------------------------------------------------------------------

class yapp_tx_sequencer extends uvm_sequencer #(yapp_packet);

  `uvm_component_utils(yapp_tx_sequencer)

  function new(string name, uvm_component parent);   
    super.new(name, parent);     // important!!
  endfunction

endclass : yapp_tx_sequencer


