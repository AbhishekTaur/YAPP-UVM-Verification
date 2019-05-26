// IVB checksum: 894493805
/*-----------------------------------------------------------------
File name     : channel_rx_agent.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:24 2009
Description   : This file implements the rx agent
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

`ifndef CHANNEL_RX_AGENT_SV
`define CHANNEL_RX_AGENT_SV

//------------------------------------------------------------------------------
//
// CLASS: channel_rx_agent
//
//------------------------------------------------------------------------------

class channel_rx_agent extends uvm_agent;
 
  // This field determines whether an agent is active or passive.
  protected uvm_active_passive_enum is_active = UVM_ACTIVE;

  channel_monitor   monitor;     // THIS WILL BE A REFERENCE 
  channel_rx_sequencer sequencer;
  channel_rx_driver    driver;
  
  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(channel_rx_agent)
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

endclass : channel_rx_agent

  // UVM build_phase
  function void channel_rx_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    //Monitor reference is assigned in the ENV
    if(is_active == UVM_ACTIVE) begin
      sequencer = channel_rx_sequencer::type_id::create("sequencer", this);
      driver = channel_rx_driver::type_id::create("driver", this);
    end
  endfunction : build_phase

  // UVM connect() phase
  function void channel_rx_agent::connect_phase(uvm_phase phase);
    if(is_active == UVM_ACTIVE) begin
      // Binds the driver to the sequencer using port interfaces
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

`endif // CHANNEL_RX_AGENT_SV
