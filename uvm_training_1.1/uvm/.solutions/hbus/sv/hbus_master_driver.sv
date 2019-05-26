/*-----------------------------------------------------------------
File name     : hbus_master_driver.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:20 2009
Description   :
Notes         :
-------------------------------------------------------------------
Copyright 2009 (c) Cadence Design Systems
-----------------------------------------------------------------*/

`ifndef HBUS_MASTER_DRIVER_SV
`define HBUS_MASTER_DRIVER_SV

//------------------------------------------------------------------------------
//
// CLASS: hbus_master_driver
//
//------------------------------------------------------------------------------

class hbus_master_driver extends uvm_driver #(hbus_transaction);

  // The virtual interface used to drive and view HDL signals.
  virtual hbus_if vif;

  // Master Id
  int master_id;

  // Control signal for the hbus driver
  //      if==0, delay between cycle is fixed to 1
  //      if==1, delay is based on value of wait_between_cycle
  bit random_delay = 0;

  // Provide implmentations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(hbus_master_driver)
    `uvm_field_int(random_delay, UVM_DEFAULT)
    `uvm_field_int(master_id, UVM_DEFAULT)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    if (!hbus_vif_config::get(this, get_full_name(),"vif", vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: build_phase

  // run_phase
  virtual task run_phase(uvm_phase phase);
    fork
      get_and_drive();
      reset_signals();
    join
  endtask : run_phase

  // Gets transaction from the sequencer and passes it to the driver.  
  virtual protected task get_and_drive();
    @(negedge vif.reset);
    `uvm_info(get_type_name(),"Reset Dropped", UVM_MEDIUM)
    forever begin
      //@(posedge vif.clock);
      @(negedge vif.clock);
      // Get new item from the sequencer
      seq_item_port.get_next_item(req);
      // Drive the data item
      `uvm_info(get_type_name(), $sformatf("Driving transaction :\n%s",req.sprint()), UVM_MEDIUM)
      drive_transaction(req);
      // Communicate item done to the sequencer
      seq_item_port.item_done();
    end
  endtask : get_and_drive

  // Reset all master signals
  virtual protected task reset_signals();
    forever begin
      @(posedge vif.reset);
      `uvm_info(get_type_name(),"Reset Observed", UVM_MEDIUM)
      vif.hen     <= 'b0;
      vif.hdata   <= 'hz;
      vif.haddr   <= 'hz;
      vif.hwr_rd  <= 'b0;
    end
  endtask : reset_signals

  // Gets a transaction and drive it into the DUT
  virtual protected task drive_transaction (hbus_transaction transaction);
    if (random_delay == 1 && transaction.wait_between_cycle > 0) begin
      repeat(transaction.wait_between_cycle) @(negedge vif.clock);
    end
    else @(negedge vif.clock);  // fixed delay of 1
    void'(this.begin_tr(transaction, "HBUS_Master_Transaction"));

    vif.hen   <= 1'b1;
    vif.haddr <= transaction.haddr;
    
    if (transaction.hwr_rd == HBUS_WRITE) begin  // WRITE protocol
      vif.hwr_rd <= 1'b1; 
      vif.hdata  <= transaction.hdata;
      @(negedge vif.clock);
      vif.hwr_rd <= 1'b0; 
      vif.hdata  <= 'z;
    end 
    else begin  // READ protocol
      vif.hwr_rd <= 1'b0; 
      @(posedge vif.clock);
      #0 vif.hdata  <= vif.hdata_w;
      @(posedge vif.clock);
      transaction.hdata = vif.hdata_w;
      @(negedge vif.clock);
    end 
    vif.hen   <= 1'b0;
    //vif.haddr <= 8'hDD; // dummy address
    //vif.haddr <= 8'h00; // dummy address
    @(posedge vif.clock);
    vif.hdata  <= 'hz;
    // finish transaction recording
    this.end_tr(transaction);
  endtask : drive_transaction

endclass : hbus_master_driver

`endif // HBUS_MASTER_DRIVER_SV

