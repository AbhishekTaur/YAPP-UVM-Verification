/*-----------------------------------------------------------------
File name     : channel_tx_agent.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:24 2009
Description   : This file implements the tx agent
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

`ifndef CHANNEL_TX_AGENT_SV
`define CHANNEL_TX_AGENT_SV

//------------------------------------------------------------------------------
//
// CLASS: channel_tx_agent
//
//------------------------------------------------------------------------------

class channel_tx_agent extends uvm_agent;

  //  This field determines whether an agent is active or passive.
  protected uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  channel_monitor   monitor;      // THIS WILL BE A REFERENCE
  channel_tx_sequencer sequencer;
  channel_tx_driver    driver;
  
  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(channel_tx_agent)
    `uvm_field_object(monitor, UVM_REFERENCE)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Additional class methods
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

endclass : channel_tx_agent

  // UVM build_phase
  function void channel_tx_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Monitor Reference is assigned in the ENV
    if(is_active == UVM_ACTIVE) begin
      sequencer = channel_tx_sequencer::type_id::create("sequencer", this);
      driver = channel_tx_driver::type_id::create("driver", this);
    end
  endfunction : build_phase

  // UVM connect_phase
  function void channel_tx_agent::connect_phase(uvm_phase phase);
    if(is_active == UVM_ACTIVE) begin
      // Binds the driver to the sequencer using consumer-producer interface
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

`endif // CHANNEL_TX_AGENT_SV
