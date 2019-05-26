/*-----------------------------------------------------------------
File name     : channel_env.sv
Developers    : Kathleen Meade
Created       : 01/04/11
Description   : This file implements the Channel UVC env.
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

`ifndef CHANNEL_ENV_SV
`define CHANNEL_ENV_SV

//------------------------------------------------------------------------------
//
// CLASS: channel_env
//
//------------------------------------------------------------------------------

class channel_env extends uvm_env;

  // The following two bits are used to control whether checks and coverage are
  // done both in the bus monitor class and the interface.
  bit checks_enable = 1; 
  bit coverage_enable = 1;

  // Configuration parameter
  bit has_tx = 0;
  bit has_rx = 0;

  // Components of the environment
  channel_tx_agent tx_agent;
  channel_rx_agent rx_agent;
  channel_monitor monitor;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(channel_env)
    `uvm_field_int(has_tx, UVM_ALL_ON)
    `uvm_field_int(has_rx, UVM_ALL_ON)
    `uvm_field_int(checks_enable, UVM_ALL_ON)
    `uvm_field_int(coverage_enable, UVM_ALL_ON)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Additional class methods
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

endclass : channel_env

  // UVM build_phase
  function void channel_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Build the tx/rx agents
    if (has_tx == 1)
      tx_agent = channel_tx_agent::type_id::create("tx_agent", this);
    if (has_rx == 1)
      rx_agent = channel_rx_agent::type_id::create("rx_agent", this);
    // Build ONE monitor for this PTP interface
    monitor = channel_monitor::type_id::create("monitor", this);
  endfunction : build_phase

  // UVM connect() phase
  function void channel_env::connect_phase(uvm_phase phase);
    super.connect();
    // Connect the Agent monitors to the common Env monitor
    if (has_tx == 1)
      tx_agent.monitor = monitor;
    if (has_rx == 1)
      rx_agent.monitor = monitor;
  endfunction : connect_phase

`endif // CHANNEL_ENV_SV
