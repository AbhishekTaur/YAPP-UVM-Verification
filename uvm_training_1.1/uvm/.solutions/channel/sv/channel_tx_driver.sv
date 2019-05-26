/*-----------------------------------------------------------------
File name     : channel_tx_driver.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:24 2009
Description   : This files implements the tx driver functionality.
Notes         : 
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

`ifndef CHANNEL_TX_DRIVER_SV
`define CHANNEL_TX_DRIVER_SV
//------------------------------------------------------------------------------
//
// CLASS: channel_tx_driver
//
//------------------------------------------------------------------------------

class channel_tx_driver extends uvm_driver #(yapp_packet);

  // The virtual interface used to drive and view HDL signals.
  virtual interface channel_if vif;
 
  // Count packets sent
  int num_sent;

  // Instance ID for transaction recording
  static int instance_cnt=0;
  string instance_id;

  // Provide implmentations of virtual methods such as get_type_name and create
  `uvm_component_utils(channel_tx_driver)

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
  extern virtual protected task send_to_dut(yapp_packet packet);
  extern virtual function void report_phase(uvm_phase phase);

endclass : channel_tx_driver

  function void channel_tx_driver::build_phase(uvm_phase phase);
    if (!channel_vif_config::get(this, get_full_name(),"vif", vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: build_phase


  // UVM run_phase
  task channel_tx_driver::run_phase(uvm_phase phase);
    fork
      get_and_drive();
      reset_signals();
    join
  endtask : run_phase

  // Gets packets from the sequencer and passes them to the driver. 
  task channel_tx_driver::get_and_drive();
    @(negedge vif.reset);
    `uvm_info(get_type_name(), "Reset dropped", UVM_MEDIUM)
    forever begin
      // Get new item from the sequencer
      seq_item_port.get_next_item(req);
      // Drive the item
      send_to_dut(req);
      // Communicate item done to the sequencer
      seq_item_port.item_done();
    end
  endtask : get_and_drive

  // Reset all tx signals
  task channel_tx_driver::reset_signals();
    forever begin
      @(posedge vif.reset);
       `uvm_info(get_type_name(), "Reset observed", UVM_MEDIUM)
      vif.data           <=  'hz;
      vif.data_vld       <= 1'b0;
      disable send_to_dut;
    end
  endtask : reset_signals

  // Gets a packet and drive it into the DUT
  task channel_tx_driver::send_to_dut(yapp_packet packet);
    `uvm_info(get_type_name(), $sformatf("%s Packet to Send:\n%s", instance_id, packet.sprint()),UVM_HIGH)

    // Begin Transaction recording
    void'(this.begin_tr(packet, {instance_id,"_Packet"}));

    // Wait for packet delay
    repeat(packet.packet_delay)
      @(negedge vif.clock);

    // Start to send packet. DON'T wait for suspend on Channel side
    vif.data_vld <= 1'b1;

    // Wait for suspend to drop before sending data
    @(negedge vif.clock iff (!vif.suspend));  

    // Drive the Header {Length, Addr}
    vif.data <= { packet.length, packet.addr };

    // Drive Payload
    for (int i=0; i<packet.payload.size(); i++) begin
      @(negedge vif.clock iff (!vif.suspend))
      vif.data <= packet.payload[i];
    end
    // Drive Parity and reset Valid
    @(negedge vif.clock iff (!vif.suspend))
    vif.data_vld <= 1'b0;
    vif.data  <= packet.parity;

    @(negedge  vif.clock)
      vif.data  <= 8'bz;
    num_sent++;

    // End transaction recording
    this.end_tr(packet);

    `uvm_info(get_type_name(), $sformatf("%s Packet %0d Sent ...\n%s", instance_id, num_sent, packet.sprint()), UVM_MEDIUM)
    `uvm_info(get_type_name(), $sformatf("Parity Type: %s  Parity : %h  Computed Parity: %h", packet.parity_type.name(), packet.parity, packet.calc_parity()), UVM_FULL)
  endtask : send_to_dut

  // UVM report_phase
  function void channel_tx_driver::report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: %s TX Driver Sent %0d Packets", instance_id, num_sent), UVM_LOW)
  endfunction : report_phase

`endif // CHANNEL_TX_DRIVER_SV
