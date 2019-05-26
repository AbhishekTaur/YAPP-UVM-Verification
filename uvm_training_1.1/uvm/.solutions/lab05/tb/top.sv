/*-----------------------------------------------------------------
File name     : top.sv
Developers    : Brian Dickinson
Created       : 01/06/09
Description   : This file is the top module
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009
-----------------------------------------------------------------*/

module top;
  
  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

  // import the YAPP package
  import yapp_pkg::*;

  // include the tst library file
  `include "yapp_test_lib.sv"

  initial
    run_test();

endmodule : top
