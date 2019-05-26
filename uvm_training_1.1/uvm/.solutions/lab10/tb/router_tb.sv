/*-----------------------------------------------------------------
File name     : router_tb.sv
Developers    : Brian Dickinson
Created       : 01/04/11
Description   : This file implements the router testbench (tb) for lab09a 
              : Scoreboard, but no Router Monitor 
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: router_tb
//
//------------------------------------------------------------------------------

class router_tb extends uvm_env;

  // component macro
  `uvm_component_utils(router_tb)

  // yapp environment
  yapp_env yapp;

  //Channel environmnent UVCs
  channel_env chan0;
  channel_env chan1;
  channel_env chan2;

  // HBUS UVC
  hbus_env hbus;

  // Virtual Sequencer
  router_virtual_sequencer virtual_sequencer;

  // Router Scoreboard
  router_fifo_scoreboard router_sb;

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // YAPP UVC
    yapp = yapp_env::type_id::create("yapp", this);

    // Channel UVC - RX ONLY
    set_config_int("chan*", "has_tx", 0);
    set_config_int("chan*", "has_rx", 1);
    chan0 = channel_env::type_id::create("chan0", this);
    chan1 = channel_env::type_id::create("chan1", this);
    chan2 = channel_env::type_id::create("chan2", this);

    // HBUS UVC - 1 Master and 1 Slave
    set_config_int("hbus", "num_masters", 1);
    set_config_int("hbus", "num_slaves", 0);
    hbus = hbus_env::type_id::create("hbus", this);

   // virtual sequencer
   virtual_sequencer = router_virtual_sequencer::type_id::create("virtual_sequencer", this);

  // router scoreboard
  router_sb = router_fifo_scoreboard::type_id::create("router_sb", this);

  endfunction : build_phase

  // UVM connect_phase
  function void connect_phase(uvm_phase phase);

    // Virtual Sequencer Connections
    virtual_sequencer.hbus_seqr = hbus.masters[0].sequencer;
    virtual_sequencer.yapp_seqr = yapp.tx_agent.sequencer;

    // Connect the TLM ports from the YAPP and Channel UVCs to the scoreboard
    yapp.tx_agent.monitor.item_collected_port.connect(router_sb.yapp_fifo.analysis_export);
    chan0.rx_agent.monitor.item_collected_port.connect(router_sb.chan0_fifo.analysis_export);
    chan1.rx_agent.monitor.item_collected_port.connect(router_sb.chan1_fifo.analysis_export);
    chan2.rx_agent.monitor.item_collected_port.connect(router_sb.chan2_fifo.analysis_export);
    hbus.masters[0].monitor.item_collected_port.connect(router_sb.hbus_fifo.analysis_export);

  endfunction : connect_phase

endclass : router_tb
