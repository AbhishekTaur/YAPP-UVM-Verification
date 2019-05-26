/*-----------------------------------------------------------------
File name     : yapp_pkg.sv
Developers    : Brian Dickinson
Created       : 01/06/11
Description   : Package for YAPP packet in lab01
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011
-----------------------------------------------------------------*/

package yapp_pkg;

  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

  // include the YAPP packet definition
  `include "yapp_packet.sv" 

endpackage : yapp_pkg
