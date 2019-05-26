/*-----------------------------------------------------------------
File name     : test_lib.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:24 2009
Description   : This file implements two kinds of test in the testbench.
Notes         : A test file verifies one or more cases in the test plan. 
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

`include "demo_tb.sv"

//----------------------------------------------------------------
//
// TEST: demo_base_test - Base test
//
//----------------------------------------------------------------
class demo_base_test extends uvm_test;

  `uvm_component_utils(demo_base_test)

  demo_tb tb;

  function new(string name = "demo_base_test", 
    uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Enable transaction recording for everything
    set_config_int("*", "recording_detail", UVM_FULL);
    // Create the testbench
    tb = demo_tb::type_id::create("tb", this);
  endfunction : build_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction

endclass : demo_base_test

//----------------------------------------------------------------
//
// TEST: default_sequence_test - sets the default sequences 
//
//----------------------------------------------------------------
class default_sequence_test extends demo_base_test;

  `uvm_component_utils(default_sequence_test)

  function new(string name = "default_sequence_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    // Set the default sequences for the tx and rx 
    uvm_config_wrapper::set(this, "tb.chan0.tx_agent.sequencer.run_phase",
                            "default_sequence",
                            channel_tx_nested_seq::type_id::get());

    uvm_config_wrapper::set(this, "tb.chan0.rx_agent.sequencer.run_phase",
                            "default_sequence",
                            channel_rx_resp_seq::type_id::get());
    // Create the testbench
    super.build_phase(phase);
  endfunction : build_phase

endclass : default_sequence_test

//----------------------------------------------------------------
//
// TEST: tx_topology : creates TX agent topology print
//
//----------------------------------------------------------------
class tx_topology extends demo_base_test;

  `uvm_component_utils(tx_topology)

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    // Set the topology configuration
    set_config_int("tb.chan0", "has_tx", 1);
    super.build_phase(phase);
  endfunction : build_phase

endclass : tx_topology

//----------------------------------------------------------------
//
// TEST: rx_topology : creates RX agent topology print
//
//----------------------------------------------------------------
class rx_topology extends demo_base_test;

  `uvm_component_utils(rx_topology)

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    // Set the topology configuration
    set_config_int("tb.chan0", "has_rx", 1);
    super.build_phase(phase);
  endfunction : build_phase

endclass : rx_topology
