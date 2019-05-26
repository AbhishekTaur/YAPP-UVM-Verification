/*-----------------------------------------------------------------
File name     : hbus_env.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:21 2009
Description   :
Notes         :
-------------------------------------------------------------------
Copyright 2009 (c) Cadence Design Systems
-----------------------------------------------------------------*/

`ifndef HBUS_ENV_SV
`define HBUS_ENV_SV

//------------------------------------------------------------------------------
//
// CLASS: hbus_env
//
//------------------------------------------------------------------------------

class hbus_env extends uvm_env;

  // Control properties
  protected int unsigned num_masters = 0;
  protected int unsigned num_slaves = 0;

  // The following two bits are used to control whether checks and coverage are
  // done both in the bus monitor class and the interface.
  bit checks_enable = 1; 
  bit coverage_enable = 1;

  // Components of the environment
  hbus_master_agent masters[];
  hbus_slave_agent  slaves[];
  hbus_monitor      bus_monitor;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(hbus_env)
    `uvm_field_int(num_masters, UVM_ALL_ON)
    `uvm_field_int(num_slaves, UVM_ALL_ON)
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

endclass : hbus_env

  // UVM build_phase
  function void hbus_env::build_phase(uvm_phase phase);
    string inst_name;
    super.build_phase(phase);
    // Create the common monitor
    bus_monitor = hbus_monitor::type_id::create("monitor", this);
    masters = new[num_masters];
    foreach(masters [i]) begin
      $sformat(inst_name, "masters[%0d]", i);
      masters[i] = hbus_master_agent::type_id::create(inst_name, this);
    end
    slaves = new[num_slaves];
    foreach(slaves [i]) begin
      $sformat(inst_name, "slaves[%0d]", i);
      slaves[i]  = hbus_slave_agent::type_id::create(inst_name, this);
    end
  endfunction : build_phase

  // UVM connect_phase
  function void hbus_env::connect_phase(uvm_phase phase);
    foreach(masters [i]) begin
      masters[i].set_master_id(i);
      masters[i].monitor = bus_monitor;
    end
    foreach(slaves [i]) 
      slaves[i].monitor = bus_monitor;
  endfunction : connect_phase

`endif // HBUS_ENV_SV

