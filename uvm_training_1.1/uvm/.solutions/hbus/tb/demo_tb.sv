/*-----------------------------------------------------------------
File name     : demo_tb.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:20 2009
Description   :
Notes         :
-------------------------------------------------------------------
Copyright 2009 (c) Cadence Design Systems
-----------------------------------------------------------------*/

`ifndef DEMO_TB_SV
`define DEMO_TB_SV


//------------------------------------------------------------------------------
//
// CLASS: hbus_demo_tb
//
//------------------------------------------------------------------------------

class demo_tb extends uvm_env;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils(demo_tb)

  // hbus environment
  hbus_env hbus;

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  // Additional class methods
  extern virtual function void build_phase(uvm_phase phase);

endclass : demo_tb

  // UVM build() phase
  function void demo_tb::build_phase(uvm_phase phase);
    super.build_phase(phase);
    set_config_int("hbus", "num_masters", 1);
    set_config_int("hbus", "num_slaves", 1);
    hbus = hbus_env::type_id::create("hbus", this);
  endfunction : build_phase

`endif // DEMO_TB_SV
