/*-----------------------------------------------------------------
File name     : router_tb.sv
Developers    : Brian Dickinson
Created       : 01/04/11
Description   : This file implements the router testbench (tb) for lab07 
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

  //Channel environmnent UVCs
  channel_env chan0;
  channel_env chan1;
  channel_env chan2;

  // HBUS UVC
  hbus_env hbus;

  // Constructor
  function new (string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  // UVM build() phase
  function void build_phase(uvm_phase phase);
    set_config_int( "*", "recording_detail", 1);
    super.build_phase(phase);

    // YAPP UVC
    yapp = yapp_env::type_id::create("yapp", this);

    // Channel UVC - RX ONLY
    set_config_int("chan*", "has_rx", 1);
    set_config_int("chan*", "has_tx", 0);
    chan0 = channel_env::type_id::create("chan0", this);
    chan1 = channel_env::type_id::create("chan1", this);
    chan2 = channel_env::type_id::create("chan2", this);

    // HBUS UVC - 1 Master and 0 Slave
    set_config_int("hbus", "num_masters", 1);
    set_config_int("hbus", "num_slaves", 0);
    hbus = hbus_env::type_id::create("hbus", this);

  endfunction : build_phase

endclass : router_tb
