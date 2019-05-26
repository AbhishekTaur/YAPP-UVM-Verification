/*-----------------------------------------------------------------
File name     : demo_top.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:24 2009 
Description   :
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

module demo_top;

  // UVM class library compiled in a package
  import uvm_pkg::*;

  // Bring in the rest of the library (macros and template classes)
  `include "uvm_macros.svh"

  // CHANNEL OVC Files
  `include "yapp_packet.sv"
  `include "channel.svh"
  `include "channel_tx_seqs.sv"
  `include "channel_rx_seqs.sv"
  `include "test_lib.sv"

  // clock, reset are generated here for this DUT
  reg reset;
  reg clock; 

  // channel Interface to the DUT
  channel_if ch0(clock, reset);

  initial begin
    channel_vif_config::set(null,"*.tb.chan0.*","vif", ch0);
    run_test();
  end

  initial begin
    reset <= 1'b1;
    clock <= 1'b1;
    #51 reset = 1'b0;
  end

  //Generate Clock
  always
    #50 clock = ~clock;

endmodule
