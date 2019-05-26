/*-----------------------------------------------------------------
File name     : yapp_tx_monitor.sv
Developers    : Brian Dickinson
Created       : 01/04/11
Description   : This file implements the TX monitor for lab04.
              : The monitor monitors the activity of its interface bus.
              : It collects both packets and responses.
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: yapp_tx_monitor
//
//------------------------------------------------------------------------------

class yapp_tx_monitor extends uvm_monitor;

  // component macro
  `uvm_component_utils(yapp_tx_monitor)

  // component constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH);
  endfunction : start_of_simulation_phase
 

  // UVM run_phase()
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Inside the run_phase", UVM_MEDIUM);
  endtask : run_phase

endclass : yapp_tx_monitor
