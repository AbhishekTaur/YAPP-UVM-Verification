module top;
  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

class mytest extends uvm_test;

  `uvm_component_utils(mytest)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction  

  task run();
    `uvm_info(get_type_name(), "UVM TEST INSTALL PASSED!", UVM_NONE)
    global_stop_request();
  endtask

endclass

initial
  begin
    run_test("mytest");
  end

endmodule : top
