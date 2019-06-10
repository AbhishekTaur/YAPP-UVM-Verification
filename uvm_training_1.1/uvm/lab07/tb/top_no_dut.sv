/*-----------------------------------------------------------------
File name     : top_dut.sv
Developers    : Brian Dickinson
Created       : 01/06/09
Description   : This file is the supplied top module for lab06
              : DUT instantiation
              : REQUIRES MODIFICATION
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

module top;

  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

  // import UVC packages here
  import yapp_pkg::*;
  `include "router_tb.sv"
  `include "router_test_lib.sv"
  // clock, reset are generated here for this DUT
  bit reset;
  bit clock; 

  // YAPP Interface to the DUT
  yapp_if in0(clock, reset);

  initial begin
    yapp_vif_config::set(null, "*.route.env.*", "vif", in0);
    run_test();
  end

  // ADD YAPP Interface to the DUT

  initial begin
    $timeformat(-9, 0, " ns", 8);
    reset <= 1'b0;
    clock <= 1'b1;
    in0.in_suspend <= 1'b0;
    @(negedge clock)
      #1 reset <= 1'b1;
    @(negedge clock)
      #1 reset <= 1'b0;
  end

  //Generate Clock
  always
    #10 clock = ~clock;

endmodule
