//top module (tests)
//
module top ();

  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

  // include the yapp svh file  
  import yapp_pkg::*;

  // define an environment handle
  yapp_env env;
 
  initial begin
  // create an environment instance
    env = new("env", null);
  end

  initial begin
    uvm_config_wrapper::set(null, "env.agent.sequencer.run_phase",
                                   "default_sequence",
                                   yapp_5_packets::type_id::get());
  // run the test
    run_test();
  end
  // code required for second part of lab02
  //uvm_config_wrapper::set(null, "<path>.run_phase",
  //                        "default_sequence",
  //                        yapp_5_packets::type_id::get());

endmodule : top
