/*-----------------------------------------------------------------
File name     : channel_rx_driver.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:24 2009
Description   : This file implements the rx driver functionality
Notes         : 
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

`ifndef CHANNEL_RX_DRIVER_SV
`define CHANNEL_RX_DRIVER_SV

//------------------------------------------------------------------------------
//
// CLASS: channel_rx_driver
//
//------------------------------------------------------------------------------

class channel_rx_driver extends uvm_driver #(channel_resp);

  // The virtual interface used to drive and view HDL signals.
  virtual interface channel_if vif;
    
  // Count packet_responses sent
  int num_sent;

  // Instance ID for transaction recording
  static int instance_cnt=0;
  string instance_id;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils(channel_rx_driver)

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
    // Instance ID for transaction recording
    case (instance_cnt)
      0: instance_id = "Channel_0";
      1: instance_id = "Channel_1";
      2: instance_id = "Channel_2";
      default: instance_id = "Unknown_Channel";
    endcase
    instance_cnt++;
  endfunction : new

  // Additional class methods
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual protected task get_and_drive();
  extern virtual protected task reset_signals();
  extern virtual protected task send_response(channel_resp response);
  extern virtual function void report_phase(uvm_phase phase);

endclass : channel_rx_driver

  function void channel_rx_driver::build_phase(uvm_phase phase);
    if (!channel_vif_config::get(this, get_full_name(),"vif", vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: build_phase

  // UVM run_phase
  task channel_rx_driver::run_phase(uvm_phase phase);
    fork
      get_and_drive();
      reset_signals();
    join
  endtask : run_phase

  // Continually detects transfers
  task channel_rx_driver::get_and_drive();
    @(negedge vif.reset);
    `uvm_info(get_type_name(), "Reset Dropped", UVM_MEDIUM)
    forever begin
      // wait for data valid to get the next response
      @(posedge vif.clock iff vif.data_vld===1'b1);
      // Get new item from the sequencer
      seq_item_port.get_next_item(rsp);
      // Drive the response
      send_response(rsp);
      // Communicate item done to the sequencer
      seq_item_port.item_done();
    end
  endtask : get_and_drive

  // Reset all signals
  task channel_rx_driver::reset_signals();
    forever begin
      @(posedge vif.reset);
      `uvm_info(get_type_name(), "Reset Observed", UVM_MEDIUM)
      vif.suspend      <= 1'b1;
    end
  endtask : reset_signals

  // Response to a transfer from the DUT
  task channel_rx_driver::send_response(channel_resp response);
    `uvm_info(get_type_name(),
         $sformatf("%s RX Driving Response :\n%s", instance_id, response.sprint()),
         UVM_HIGH)

    // Begin Transaction Recording
    void'(this.begin_tr(response, {instance_id, "_Response"}));
    @(negedge vif.clock);
    repeat(response.resp_delay) begin
      // Raise suspend flag if it isn't already raised
      vif.suspend  <= 1;
      @(negedge vif.clock);
    end
    // Lower suspend flag
    vif.suspend  <= 0;

    // Wait until the end of the packet to complete transaction
    wait (!vif.data_vld)
    num_sent++;
    @(negedge vif.clock)
    vif.suspend <= 1'b1;
    // End Transaction Recording for this response
    this.end_tr(response);
 
  endtask : send_response

  // UVM report_phase
  function void channel_rx_driver::report_phase(uvm_phase phase);
  `uvm_info(get_type_name(), $sformatf("Report: %s RX Driver Sent %0d Responses",instance_id, num_sent), UVM_LOW)
  endfunction : report_phase

`endif // CHANNEL_RX_DRIVER_SV
