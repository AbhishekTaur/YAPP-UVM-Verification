/*-----------------------------------------------------------------
File name     : hbus_slave_driver.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:20 2009
Description   :
Notes         :
-------------------------------------------------------------------
Copyright 2009 (c) Cadence Design Systems
-----------------------------------------------------------------*/

`ifndef HBUS_SLAVE_DRIVER_SV
`define HBUS_SLAVE_DRIVER_SV

//------------------------------------------------------------------------------
//
// CLASS: hbus_slave_driver
//
//------------------------------------------------------------------------------
 
class hbus_slave_driver extends uvm_driver #(hbus_transaction);

  // The virtual interface used to drive and view HDL signals.
  virtual hbus_if vif;

  bit [7:0] max_pktsize_reg = 8'h3F;
  bit [7:0] router_enable_reg = 1'b1;
  bit [7:0] hbus_memory [32];

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(hbus_slave_driver)
     `uvm_field_int(max_pktsize_reg, UVM_DEFAULT)
     `uvm_field_int(router_enable_reg, UVM_DEFAULT)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    if (!hbus_vif_config::get(this, get_full_name(),"vif", vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: build_phase

  // UVM run_phase
  virtual task run_phase(uvm_phase phase);
    fork
      get_and_drive();
      reset_signals();
    join
  endtask : run_phase

  // Continually gets responses from the sequencer
  // and passes them to the driver.
  virtual protected task get_and_drive();
    @(negedge vif.reset);
    `uvm_info(get_type_name(),"Reset Dropped", UVM_MEDIUM)
    forever begin
      @(posedge vif.clock);
      // Get new item from the sequencer
      seq_item_port.get_next_item(rsp);
      // Drive the response
      send_response(rsp);
      // Communicate item done to the sequencer
      seq_item_port.item_done();
    end
  endtask : get_and_drive

  // Reset all slave signals
  virtual protected task reset_signals();
    forever begin
      @(posedge vif.reset);
      `uvm_info(get_type_name(),"Reset Observed", UVM_MEDIUM)
      vif.hdata      <= 'z;
      max_pktsize_reg = 8'h3F;
      router_enable_reg = 1'b1;
    end
  endtask : reset_signals

  // Get response and drive it into the DUT
  virtual protected task send_response(hbus_transaction resp);
    
      // wait for enable
      //@(posedge vif.clock iff vif.hen)
      @(posedge vif.hen)
      void'(this.begin_tr(resp, "HBUS_Slave_Response"));
      if (vif.hwr_rd == 0) begin  // READ
        resp.haddr = vif.haddr;
        resp.hwr_rd = HBUS_READ;
        @(posedge vif.clock)
        case (vif.haddr)
         'h00: vif.hdata = max_pktsize_reg;
         'h01: vif.hdata = router_enable_reg;
         default: begin
                  `uvm_info(get_type_name(), "Unmapped Register Address", UVM_MEDIUM)
                  vif.hdata = hbus_memory[vif.haddr];
                  end 
        endcase
        @(negedge vif.clock)
          resp.hdata = vif.hdata;
        @(posedge vif.clock iff !vif.hen)
          vif.hdata = 'z;
      end 
       else begin   // WRITE
        resp.haddr = vif.haddr;
        resp.hdata = vif.hdata;
        resp.hwr_rd = HBUS_WRITE;
        // Update contents of registers
        case (vif.haddr)
         'h00: max_pktsize_reg = vif.hdata;
         'h01: router_enable_reg = vif.hdata;
         default: begin
                  `uvm_info(get_type_name(), "Unmapped Register Address", UVM_MEDIUM)
                  hbus_memory[vif.haddr] = vif.hdata;
                  end 
        endcase
        @(negedge vif.clock);
      end
      `uvm_info(get_type_name(), $sformatf("Response Sent:\n%s",resp.sprint()), UVM_MEDIUM)
      this.end_tr(resp);
  endtask : send_response

endclass : hbus_slave_driver

`endif // HBUS_SLAVE_DRIVER_SV
