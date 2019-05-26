/*-----------------------------------------------------------------
File name     : router_test_lib.sv
Developers    : Brian Dickinson
Created       : 01/04/11
Description   : This file implements the test classes for lab06
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

class base_test extends uvm_test;

  // component macro
  `uvm_component_utils(base_test)

  // Components of the environment
  router_tb tb;

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase()
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tb = router_tb::type_id::create("tb",this);
  endfunction : build_phase
  
  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH);
  endfunction : start_of_simulation_phase

  task run_phase(uvm_phase phase);
    phase.phase_done.set_drain_time(this, 200ns);
  endtask : run_phase

  function void check_phase(uvm_phase phase);
    // configuration checker
    check_config_usage();
  endfunction

endclass : base_test

class test2 extends base_test;

  // component macro
  `uvm_component_utils(test2)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : test2


class short_packet_test extends base_test;

  // component macro
  `uvm_component_utils(short_packet_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
   yapp_packet::type_id::set_type_override(short_yapp_packet::get_type()); 
    uvm_config_wrapper::set(this, "tb.yapp.tx_agent.sequencer.run_phase",
                            "default_sequence",
                            yapp_5_packets::type_id::get());
   super.build_phase(phase);
  endfunction : build_phase

endclass : short_packet_test

class set_config_test extends base_test;

  // component macro
  `uvm_component_utils(set_config_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
   set_config_int("*tx_agent","is_active",UVM_PASSIVE);
   super.build_phase(phase);
  endfunction : build_phase

endclass : set_config_test

class incr_payload_test extends base_test;

  // component macro
  `uvm_component_utils(incr_payload_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
   yapp_packet::type_id::set_type_override(short_yapp_packet::get_type()); 
    uvm_config_wrapper::set(this, "tb.yapp.tx_agent.sequencer.run_phase",
                            "default_sequence",
                            yapp_incr_payload_seq::type_id::get());
   super.build_phase(phase);
  endfunction : build_phase

endclass : incr_payload_test

class exhaustive_seq_test extends base_test;

  // component macro
  `uvm_component_utils(exhaustive_seq_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
   yapp_packet::type_id::set_type_override(short_yapp_packet::get_type());
   uvm_config_wrapper::set(this, "tb.yapp.tx_agent.sequencer.run_phase",
                           "default_sequence",
                           yapp_exhaustive_seq::type_id::get());
   super.build_phase(phase);
  endfunction : build_phase

endclass : exhaustive_seq_test

class short_yapp_012 extends base_test;

  // component macro
  `uvm_component_utils(short_yapp_012)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
   yapp_packet::type_id::set_type_override(short_yapp_packet::get_type()); 
    uvm_config_wrapper::set(this, "tb.yapp.tx_agent.sequencer.run_phase",
                            "default_sequence",
                            yapp_012_seq::type_id::get());
   super.build_phase(phase);
  endfunction : build_phase

endclass : short_yapp_012

