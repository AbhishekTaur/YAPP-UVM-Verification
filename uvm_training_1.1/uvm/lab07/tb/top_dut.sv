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

  import yapp_pkt_pkg::*;

  // import the YAPP package
  import yapp_pkg::*;

  import channel_pkg::*;

  import hbus_pkg::*;

  // include the testbench and test class files
  `include "router_tb.sv"
  `include "router_test_lib.sv"

  // clock, reset are generated here for this DUT
  bit reset;
  bit clock;
  bit error; 

  // connection signals

  // YAPP Interface to the DUT
  yapp_if in0(clock, reset);

  hbus_if hbus_if0(clock, reset);

  channel_if channel_if0(clock, reset);

  channel_if channel_if1(clock, reset);

  channel_if channel_if2(clock, reset);

  yapp_router dut(
    .reset(reset),
    .clock(clock),
    .error(error),
    // YAPP interface signals connection
    .in_data(in0.in_data),
    .in_data_vld(in0.in_data_vld),
    .in_suspend(in0.in_suspend),
    // Output Channels
    //Channel 0   
    .data_0(channel_if0.data),
    .data_vld_0(channel_if0.data_vld),
    .suspend_0(channel_if0.suspend),
    //Channel 1   
    .data_1(channel_if1.data),
    .data_vld_1(channel_if1.data_vld),
    .suspend_1(channel_if1.suspend),
    //Channel 2   
    .data_2(channel_if2.data),  
    .data_vld_2(channel_if2.data_vld),
    .suspend_2(channel_if2.suspend),
    // Host Interface Signals
    .haddr(hbus_if0.haddr),
    .hdata(hbus_if0.hdata_w),
    .hen(hbus_if0.hen),
    .hwr_rd(hbus_if0.hwr_rd));

  initial begin
    yapp_vif_config::set(null,"*.route.env.agent.*","vif", in0);
    channel_vif_config::set(null,"*.route.channel_env0.*", "vif", channel_if0);
    channel_vif_config::set(null,"*.route.channel_env1.*", "vif", channel_if1);
    channel_vif_config::set(null,"*.route.channel_env2.*", "vif", channel_if2);
    hbus_vif_config::set(null,"*.route.hbus.*", "vif", hbus_if0);
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
