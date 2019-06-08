/*-----------------------------------------------------------------
File name     : yapp_pkg.sv
Developers    : Abhishek Taur
Created       : 05/26/19
Description   : Package for YAPP packet in lab01
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2019
-----------------------------------------------------------------*/

package yapp_pkg;

  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

  // include the YAPP packet definition
  `include "yapp.svh"

endpackage : yapp_pkg
