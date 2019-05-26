/*-----------------------------------------------------------------
File name     : demo_top.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:20 2009
Description   :
Notes         :
-------------------------------------------------------------------
Copyright 2009 (c) Cadence Design Systems
-----------------------------------------------------------------*/

`timescale 1ns/1ns

module demo_top;

  // UVM class library compiled in a package
  import uvm_pkg::*;

  // Bring in the rest of the library (macros and template classes)
  `include "uvm_macros.svh"

  import hbus_pkg::*;
  `include "demo_tb.sv"
  `include "test_lib.sv"
  
  bit reset, clock;

  hbus_if hif(clock, reset);
  
  initial begin
    hbus_vif_config::set(null,"*.tb.hbus.*","vif", hif);
    run_test();
  end

  initial begin
    reset <= 1'b1;
    clock <= 1'b1;
    #51 reset = 1'b0;
  end

  //Generate Clock
  always
    #5 clock = ~clock;

endmodule
