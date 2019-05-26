/*-----------------------------------------------------------------
File name     : yapp_tx_agent.sv
Developers    : Kathleen Meade
Created       : 01/04/11
Description   : This file implements the TX agent for lab02.
Notes         : 
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: yapp_tx_agent
//
//------------------------------------------------------------------------------

class yapp_tx_agent extends uvm_agent;

  //  This field determines whether an agent is active or passive.
  protected uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  yapp_tx_monitor   monitor;
  yapp_tx_sequencer sequencer;
  yapp_tx_driver    driver;
  
  // component macro
  `uvm_component_utils_begin(yapp_tx_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase() method
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = new("monitor", this);
    if(is_active == UVM_ACTIVE) begin
      sequencer = new("sequencer", this);
      driver = new("driver", this);
    end
  endfunction : build_phase

  // UVM connect_phase() method
  function void connect_phase(uvm_phase phase);
    if(is_active == UVM_ACTIVE) 
      // Connect the driver and the sequencer 
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction : connect_phase

  // start_of_simulation_phase added for lab03
  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH);
  endfunction : start_of_simulation_phase

endclass : yapp_tx_agent

