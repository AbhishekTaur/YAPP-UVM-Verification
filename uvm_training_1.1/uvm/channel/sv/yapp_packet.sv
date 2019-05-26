/*-----------------------------------------------------------------
File name     : yapp_packet.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:24 2009
Description   :  This file declares the OVC packet. It is
              :  used by both tx and rx.
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

`ifndef YAPP_PACKET_SV
`define YAPP_PACKET_SV

//------------------------------------------------------------------------------
//
// yapp packet enums, parameters, and events
//
//------------------------------------------------------------------------------
typedef enum bit { BAD_PARITY, GOOD_PARITY } parity_e;
 
//------------------------------------------------------------------------------
//
// CLASS: yapp_packet
//
//------------------------------------------------------------------------------

class yapp_packet extends uvm_sequence_item;     

  // Physical Data
  rand bit [5:0]  length;
  rand bit [1:0]  addr;
  rand bit [7:0]  payload [];
  bit      [7:0]  parity;      // calculated in post_randomize()

  // Control Knobs
  rand parity_e parity_type;
  rand int packet_delay;

  // Default Constraints
  constraint default_length { length > 0; length < 64; }
  constraint payload_size   { length == payload.size(); }
  constraint default_delay  { packet_delay >= 0; packet_delay < 10; }
  // DEMO ONLY
  constraint short_payload { length < 20; }

  // Constrain for mostly GOOD_PARITY packets
  constraint default_parity { parity_type dist {BAD_PARITY := 1, GOOD_PARITY := 25}; }
  // Constraint address - Only 0, 1, 2 are valid addresses
  constraint default_addr  { addr != 'b11; }
 
  // UVM macros for built-in automation - These declarations enable automation
  // of the data_item fields and implement create() and get_type_name()
  `uvm_object_utils_begin(yapp_packet)
    `uvm_field_int(length,       UVM_ALL_ON)
    `uvm_field_int(addr,         UVM_ALL_ON)
    `uvm_field_array_int(payload, UVM_ALL_ON)
    `uvm_field_int(parity,      UVM_ALL_ON)
    `uvm_field_enum(parity_e, parity_type, UVM_ALL_ON)
    `uvm_field_int(packet_delay, UVM_ALL_ON | UVM_DEC | UVM_NOCOMPARE)
  `uvm_object_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name = "yapp_packet");
    super.new(name);
  endfunction : new

  // This method calculates the parity over the header and payload
  function bit [7:0] calc_parity();
    calc_parity = {length, addr};
    //foreach(payload[i])
    for (int i=0; i<length; i++)
      calc_parity = calc_parity ^ payload[i];
  endfunction : calc_parity

  // post_randomize() - calculates parity
  function void post_randomize();
    if (parity_type == GOOD_PARITY)
         parity = calc_parity();
    else do
      parity = $urandom;
    while( parity == calc_parity());
  endfunction : post_randomize

endclass : yapp_packet

`endif // YAPP_PACKET_SV

