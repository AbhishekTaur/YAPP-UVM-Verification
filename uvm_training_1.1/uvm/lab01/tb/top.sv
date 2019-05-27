/*-----------------------------------------------------------------
File name     : lab01 top.sv
Developers    : Abhishek Taur
Created       : 05/26/19
Description   : This file is the top module for lab01
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2019
-----------------------------------------------------------------*/

module top;
  
  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

  // import the YAPP package
  import yapp_pkg::*;

  yapp_packet packet;
  yapp_packet copy_packet;
  yapp_packet clone_packet;

  string name;

  initial begin
  // construct the packet for copy
  copy_packet = new("copy_packet");

  for (int i=0; i<5; i++) begin
    // allocate each packet
    packet = new("packet");
    $display("\nPACKET %0d", i);
    assert(packet.randomize());
    packet.print(uvm_default_tree_printer);
    packet.print(uvm_default_table_printer);
    packet.print(uvm_default_line_printer);
  end

  $display("\nCOPY");
  // copy usage
  copy_packet.copy(packet);
  copy_packet.print();

  $display("CLONE");
  // clone usage
  $cast(clone_packet, packet.clone()); 
  clone_packet.print();

end

endmodule : top