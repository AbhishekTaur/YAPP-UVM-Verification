/*-----------------------------------------------------------------
File name     : channel_monitor.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:24 2009
Description   : This file implements the monitor.
              : It monitors the activity of the channel IF bus.
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

`ifndef CHANNEL_MONITOR_SV
`define CHANNEL_MONITOR_SV

//------------------------------------------------------------------------------
//
// CLASS: channel_monitor
//
//------------------------------------------------------------------------------

//class channel_monitor #(parameter int max=63)extends uvm_monitor;
class channel_monitor extends uvm_monitor;

  // Virtual Interface for monitoring DUT signals
  virtual interface channel_if vif;

  // Collected Data
  yapp_packet   packet_collected;
  channel_resp  response;

  // Count packets and responses collected
  int num_pkt_col;
  int num_rsp_col;

  // Instance ID for transaction recording
  static int instance_cnt=0;
  string instance_id;
 
  // The following two bits are used to control whether checks and coverage are
  // done in the monitor
  bit checks_enable = 1;
  bit coverage_enable = 1;

  // TLM ports used to connect the monitor to the scoreboard
  uvm_analysis_port #(yapp_packet) item_collected_port;
  uvm_analysis_port #(channel_resp) resp_collected_port;

  // Events needed to trigger covergroups
  //CHANGE to .sample(): event cov_packet, cov_response;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(channel_monitor)
//    `uvm_field_int(instance_cnt, UVM_ALL_ON)
    `uvm_field_string(instance_id, UVM_ALL_ON)
    `uvm_field_int(checks_enable, UVM_ALL_ON)
    `uvm_field_int(coverage_enable, UVM_ALL_ON)
  `uvm_component_utils_end

  // packet collected covergroup
  //covergroup cover_packet @cov_packet;
  covergroup cover_packet;
    option.per_instance = 1;
//    packet_addr : coverpoint packet_collected.addr {
//                    bins ADDR[]  = {0,1,2};
//                    bins illegal = default;
//                   }
    packet_length : coverpoint packet_collected.length { 
                     bins ONE =    { 1 };
                     bins SMALL =  { [2:10] };
                     bins MEDIUM = { [11:20] };
                     bins LARGE =  { [20:62] };
                     bins MAX =    { 63 };
                     //bins LARGE =  { [20:max-1] };
                     //bins MAX =    { max };
                     bins illegal = default;
                    }
    packet_parity_type : coverpoint packet_collected.parity_type;
  endgroup : cover_packet

  // Response collected covergroup
  //covergroup cover_response @cov_response;
  covergroup cover_response;
    option.per_instance = 1;
    response_delay : coverpoint response.resp_delay {
                     bins ZERO = {0};
                     bins ONE = {1};
                     bins SMALL =  { [2:10] };
                     bins LARGE = { [11:$] };
                     }
  endgroup : cover_response

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
    // Create the covergroup if coverage is enabled
    void'(get_config_int("coverage_enable", coverage_enable));
    if (coverage_enable) begin
      cover_packet = new();
      cover_response = new();
      cover_packet.set_inst_name({get_full_name(), ".cover_packet"});
      cover_response.set_inst_name({get_full_name(), ".cover_response"});
    end
    // Create the TLM port
    item_collected_port = new("item_collected_port", this);
    resp_collected_port = new("resp_collected_port", this);
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
  extern virtual task collect_packet();
  extern virtual task collect_response();
  extern function void perform_coverage();
  extern virtual function void report_phase(uvm_phase phase);

endclass : channel_monitor

// UVM build_phase()
function void channel_monitor::build_phase(uvm_phase phase);
  if (!channel_vif_config::get(this, get_full_name(),"vif", vif))
    `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
endfunction: build_phase

// UVM run_phase() 
task channel_monitor::run_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "Inside the run() phase", UVM_MEDIUM)

  // Look for packets after reset
  @(negedge vif.reset)
  `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)
    forever begin
     fork
      collect_packet();
      collect_response();
     join
     if (coverage_enable) perform_coverage();
    end
  endtask : run_phase

  // Collect yapp_packets
  task channel_monitor::collect_packet();
      // Create separate collected packet instance for every collected packet
      packet_collected = yapp_packet::type_id::create("packet_collected", this);

      //Monitor looks at the bus on posedge (Driver uses negedge)
      //@(posedge vif.data_vld);
      @(posedge vif.clock iff (vif.data_vld && !vif.suspend));

      // Wait for suspend deasserted
      //@(posedge vif.clock iff (!vif.suspend))

      // Begin transaction recording
      void'(this.begin_tr(packet_collected, {instance_id, "_Packet"}));

      @(posedge vif.clock iff (!vif.suspend))
      `uvm_info(get_type_name(), "Collecting a packet", UVM_HIGH)
      // Collect Header {Length, Addr}
      { packet_collected.length, packet_collected.addr }  = vif.data;
      packet_collected.payload = new[packet_collected.length]; // Allocate the payload
      // Collect the Payload
      for (int i=0; i< packet_collected.length; i++) begin
         @(posedge vif.clock iff (!vif.suspend))
         packet_collected.payload[i] = vif.data;
      end

      // Collect Parity and Compute Parity Type
       //@(posedge vif.clock iff !vif.suspend)
       @(posedge vif.clock)
         packet_collected.parity = vif.data;
       packet_collected.parity_type = (packet_collected.parity == packet_collected.calc_parity()) ? GOOD_PARITY : BAD_PARITY;
       `uvm_info(get_type_name(), $sformatf("Parity Type: %s  Parity : %h  Computed Parity: %h", packet_collected.parity_type.name(), packet_collected.parity, packet_collected.calc_parity()), UVM_FULL)
      // End transaction recording
      this.end_tr(packet_collected);
      `uvm_info(get_type_name(), $sformatf("%s Packet collected :\n%s", instance_id, packet_collected.sprint()), UVM_LOW)
      // Send packet to scoreboard via TLM write()
      item_collected_port.write(packet_collected);
      num_pkt_col++;
  endtask : collect_packet

  // Collect Channel Responses
  task channel_monitor::collect_response();
    begin
      // Create response instance
      response = channel_resp::type_id::create("response", this);

      @(posedge vif.clock iff vif.data_vld == 1);
      // Begin transaction recording
      void'(this.begin_tr(response, {instance_id, "_Response"}));
      response.resp_delay = 0;
      do @(posedge vif.clock)
        if (vif.suspend == 1) response.resp_delay++;
      while (vif.data_vld == 1);
      if (response.resp_delay != 0) response.resp_delay--;
      // End transaction recording for this response
      this.end_tr(response);
      `uvm_info(get_type_name(), $sformatf("%s Response Collected :\n%s",instance_id, response.sprint()), UVM_HIGH)
      // Send response to scoreboard via TLM write()
      resp_collected_port.write(response);
      //@(posedge vif.clock iff (vif.data_vld == 0));
      num_rsp_col++;
    end
  endtask : collect_response
  
  // Triggers coverage events
  function void channel_monitor::perform_coverage();
    cover_packet.sample();
    cover_response.sample();
  endfunction : perform_coverage

  // UVM report_phase() phase
  function void channel_monitor::report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: %s Monitor Collected %0d Packets and %0d Responses", instance_id, num_pkt_col, num_rsp_col), UVM_LOW)
  endfunction : report_phase

`endif // CHANNEL_MONITOR_SV
