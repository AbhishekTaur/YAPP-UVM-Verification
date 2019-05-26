/*-----------------------------------------------------------------
File name     : router_tb.sv
Developers    : Brian Dickinson
Created       : 01/04/11
Description   : This file implements the router testbench (tb) for lab06 
              :  
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: router_tb
//
//------------------------------------------------------------------------------

class router_tb extends uvm_env;

  // component macro
  `uvm_component_utils(router_tb)

  // yapp environment
  yapp_env yapp;

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase
  function void build_phase(uvm_phase phase);
    set_config_int( "*", "recording_detail", 1);
    super.build_phase(phase);
    yapp = yapp_env::type_id::create("yapp", this);
  endfunction : build_phase

endclass : router_tb
