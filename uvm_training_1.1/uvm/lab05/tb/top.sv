//top module (tests)
//
module top ();

  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

  // include the yapp svh file  
  import yapp_pkg::*;
  `include "yapp_test_lib.sv"

  initial begin
  // run the test
    run_test();
  end
  // code required for second part of lab02
  //uvm_config_wrapper::set(null, "<path>.run_phase",
  //                        "default_sequence",
  //                        yapp_5_packets::type_id::get());

endmodule : top
