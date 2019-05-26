/*-----------------------------------------------------------------
File name     : lab02 top.sv
Developers    : Brian Dickinson
Created       : 01/04/11
Description   : This file is the top module for lab02
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011
-----------------------------------------------------------------*/

module top;
  
  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

  // import the yapp UVC
  import yapp_pkg::*;

  yapp_env yapp;

  initial
    yapp = new("yapp", null);
    
  initial begin
    uvm_config_wrapper::set(null, "yapp.tx_agent.sequencer.run_phase",
                                   "default_sequence",
                                   yapp_5_packets::type_id::get());

    run_test();
    end


endmodule : top
