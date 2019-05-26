/*-----------------------------------------------------------------
File name     : router_env.sv
Developers    : Kathleen Meade
Created       : 01/04/11
Description   : This file implements the Module UVC env for lab09b.
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------//
// CLASS: router_env
//
//------------------------------------------------------------------------------

class router_env extends uvm_env;

  // Router Reference 
  router_reference reference;

  // Router Scoreboard
  router_scoreboard scoreboard;

  `uvm_component_utils_begin(router_env)
  `uvm_component_utils_end

  //UVM Constructor
  function new(input string name, input uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    scoreboard = router_scoreboard::type_id::create("scoreboard", this);
    reference = router_reference::type_id::create("reference", this);
  endfunction : build_phase

  // UVM connect_phase
  function void connect_phase(uvm_phase phase);
    reference.sb_add_out.connect(scoreboard.sb_yapp_in);
  endfunction : connect_phase

endclass : router_env
