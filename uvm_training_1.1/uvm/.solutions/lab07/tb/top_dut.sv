/*-----------------------------------------------------------------
File name     : top_dut.sv
Developers    : Brian Dickinson
Created       : 01/04/11
Description   : This file is the top module for lab07
              : DUT instantiation without wrapper
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

module top;

  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

  // import the YAPP packet package
  import yapp_pkt_pkg::*;
  
  // import the YAPP UVC package
  import yapp_pkg::*;

  // import the HBUS UVC package
  import hbus_pkg::*;

  // import the Channel UVC package
  import channel_pkg::*;

  // include testbench and test library files
  `include "router_tb.sv"
  `include "router_test_lib.sv"

  // clock, reset are generated here for this DUT
  bit reset;
  bit clock; 

  // connection signals
  logic error;

  // YAPP Interface to the DUT
  yapp_if in0(clock, reset);

  // Channel Interfaces to the DUT
  channel_if ch0(clock, reset);
  channel_if ch1(clock, reset);
  channel_if ch2(clock, reset);

  // HBUS Interface to the DUT
  hbus_if hif(clock, reset);

  yapp_router dut(
    .reset,
    .clock,
    .error,
    // YAPP interface signals connection
    .in_data(in0.in_data),
    .in_data_vld(in0.in_data_vld),
    .in_suspend(in0.in_suspend),
    // Output Channels
    //Channel 0   
    .data_0(ch0.data),
    .data_vld_0(ch0.data_vld),
    .suspend_0(ch0.suspend),
    //Channel 1   
    .data_1(ch1.data),
    .data_vld_1(ch1.data_vld),
    .suspend_1(ch1.suspend),
    //Channel 2   
    .data_2(ch2.data),
    .data_vld_2(ch2.data_vld),
    .suspend_2(ch2.suspend),
    // Host Interface Signals
    .haddr(hif.haddr),
    .hdata(hif.hdata_w),
    .hen(hif.hen),
    .hwr_rd(hif.hwr_rd));

  initial begin
    yapp_vif_config::set(null,"*.tb.yapp.tx_agent.*","vif", in0);
    hbus_vif_config::set(null,"*.tb.hbus.*","vif", hif);
    channel_vif_config::set(null,"*.tb.chan0.*","vif", ch0);
    channel_vif_config::set(null,"*.tb.chan1.*","vif", ch1);
    channel_vif_config::set(null,"*.tb.chan2.*","vif", ch2);
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
