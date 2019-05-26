/*-----------------------------------------------------------------
File name     : top_dut.sv
Developers    : Brian Dickinson
Created       : 01/04/11
Description   : This file is the top module for lab06
              : DUT instantiation
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

module top;

  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

  // import the YAPP package
  import yapp_pkg::*;

  // include the testbench and test class files
  `include "router_tb.sv"
  `include "router_test_lib.sv"

  // clock, reset are generated here for this DUT
  bit reset;
  bit clock; 

  // connection signals

  // YAPP Interface to the DUT
  yapp_if in0(clock, reset);

  yapp_router dut(
    .reset(reset),
    .clock(clock),
    .error(),
    // YAPP interface signals connection
    .in_data(in0.in_data),
    .in_data_vld(in0.in_data_vld),
    .in_suspend(in0.in_suspend),
    // Output Channels
    //Channel 0   
    .data_0(),
    .data_vld_0(),
    .suspend_0(1'b0),
    //Channel 1   
    .data_1(),
    .data_vld_1(),
    .suspend_1(1'b0),
    //Channel 2   
    .data_2(),  
    .data_vld_2(),
    .suspend_2(1'b0),
    // Host Interface Signals
    .haddr(),
    .hdata(),
    .hen(),
    .hwr_rd());

  initial begin
    yapp_vif_config::set(null,"*.tb.yapp.tx_agent.*","vif", in0);
    run_test();
  end

  initial begin
    $timeformat(-9, 0, " ns", 8);
    reset <= 1'b0;
    clock <= 1'b1;
    @(negedge clock)
      #1 reset <= 1'b1;
    @(negedge clock)
      #1 reset <= 1'b0;
  end

  //Generate Clock
  always
    #10 clock = ~clock;

endmodule
