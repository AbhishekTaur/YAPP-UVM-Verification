/*-----------------------------------------------------------------
File name     : yapp_tx_monitor_labb.sv
Developers    : Brian Dickinson
Created       : 01/04/11
Description   : This file implements the TX monitor for LabB Coverage
              : The monitor monitors the activity of its interface bus.
              : It collects packets.
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: yapp_tx_monitor
//
//------------------------------------------------------------------------------
typedef enum bit {COV_ENABLE, COV_DISABLE} cover_e;

class yapp_tx_monitor extends uvm_monitor;

  // Collected Data handle
  yapp_packet packet_collected;

  // Count packets collected
  int num_pkt_col;

  // Config property for coverage enable
  cover_e coverage_control = COV_ENABLE;
  // inter-packet clock delay count
  int cov_delay;

  virtual interface yapp_if vif;

  // analysis port for lab09*
  uvm_analysis_port#(yapp_packet) item_collected_port;

  // component macro
  `uvm_component_utils_begin(yapp_tx_monitor)
    `uvm_field_int(num_pkt_col, UVM_ALL_ON)
    `uvm_field_enum(cover_e, coverage_control, UVM_ALL_ON)
  `uvm_component_utils_end

  // Coverage for labB
  covergroup collected_pkts_cg;
    //option.per_instance=1;

    REQ1_length: coverpoint packet_collected.length {
      bins MIN = {1};
      bins BABY = {[2:10]};
      bins TEENY = {[11:40]};
      bins GROWNUP = {[41:62]}; 
      bins MAX = {63}; 
    }

    REQ2_addr : coverpoint packet_collected.addr {
      bins addr[] = {[0:2]};
      bins illegal = {3};
    }

    bad_parity: coverpoint packet_collected.parity {
      bins bad = {BAD_PARITY};
      bins good = default;
    }

    zero_delay : coverpoint cov_delay {
      bins ZERO = {1};
      bins MORE = default;  
    }

    REQ3_cross_addr_length: cross REQ1_length, REQ2_addr;
  
    REQ3_cross_addr_bad_parity: cross  REQ2_addr, bad_parity;
    REQ4_zero_delay: cross REQ1_length, REQ2_addr, zero_delay;

  endgroup: collected_pkts_cg 

  // component constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port",this);
    if (coverage_control == COV_ENABLE)
     `uvm_info(get_type_name(),"YAPP MONITOR COVERAGE CREATED" , UVM_LOW)
      collected_pkts_cg = new();
      collected_pkts_cg.set_inst_name({get_full_name(), ".monitor_pkt"});
  endfunction : new

  function void build_phase(uvm_phase phase);
    if (!yapp_vif_config::get(this, get_full_name(),"vif", vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: build_phase

  // start_of_simulation
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation();
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

  // UVM run() phase
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Inside the run() phase", UVM_MEDIUM)

    // Look for packets after reset
    @(negedge vif.reset)
    `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)
    fork
      forever collect_packet();
      zero_delay_btw_pkt();
    join
  endtask : run_phase

  // Calculate number of clock delays for coverage
  task zero_delay_btw_pkt();
    forever begin
      @(posedge vif.clock iff (!vif.in_data_vld))
      cov_delay = 0;
      while(!vif.in_data_vld) begin
        cov_delay++;
        @(posedge vif.clock);
      end
    end
  endtask: zero_delay_btw_pkt 

  // Collect Packets
  task collect_packet();
      //Monitor looks at the bus on posedge (Driver uses negedge)
      @(posedge vif.in_data_vld);

      @(posedge vif.clock iff (!vif.in_suspend))

      // Create collected packet instance
      packet_collected = yapp_packet::type_id::create("packet_collected", this);

      // Begin transaction recording
      void'(this.begin_tr(packet_collected, "Monitor_YAPP_Packet"));

      `uvm_info(get_type_name(), "Collecting a packet", UVM_HIGH)
      // Collect Header {Length, Addr}
      { packet_collected.length, packet_collected.addr }  = vif.in_data;
      packet_collected.payload = new[packet_collected.length]; // Allocate the payload
      // Collect the Payload
      foreach (packet_collected.payload [i]) begin
         @(posedge vif.clock iff (!vif.in_suspend))
         packet_collected.payload[i] = vif.in_data;
      end

      // Collect Parity and Compute Parity Type
       @(posedge vif.clock iff !vif.in_suspend)
         packet_collected.parity = vif.in_data;
       packet_collected.parity_type = (packet_collected.parity == packet_collected.calc_parity()) ? GOOD_PARITY : BAD_PARITY;
      // End transaction recording
      this.end_tr(packet_collected);
      `uvm_info(get_type_name(), $sformatf("Packet Collected :\n%s", packet_collected.sprint()), UVM_LOW)
      // write collected packet to analysis port
      item_collected_port.write(packet_collected);
      // trigger coverage
      if (coverage_control == COV_ENABLE) begin
        `uvm_info(get_type_name(),"YAPP MONITOR COVERAGE SAMPLE" , UVM_LOW)
        collected_pkts_cg.sample();
      end
      num_pkt_col++;
  endtask : collect_packet

  // UVM report_phase
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: YAPP Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
  endfunction : report_phase

endclass : yapp_tx_monitor
