/*-----------------------------------------------------------------
File name     : yapp_packet.sv
Developers    : Abhishek Taur
Created       : 05/26/19
Description   : This file declares the UVC packet for lab01 and others.
              : It is used by both the YAPP and Channel UVCs
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2019
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// yapp packet enums, parameters, and events
//
//------------------------------------------------------------------------------
typedef enum bit { BAD_PARITY, GOOD_PARITY } parity_t;
 
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
  rand parity_t parity_type;
  rand int packet_delay;

  // UVM macros for built-in automation - These declarations enable automation
  // of the data_item fields 
  `uvm_object_utils_begin(yapp_packet)
    `uvm_field_int(length,       UVM_ALL_ON)
    `uvm_field_int(addr,         UVM_ALL_ON)
    `uvm_field_array_int(payload, UVM_ALL_ON)
    `uvm_field_int(parity,      UVM_ALL_ON + UVM_BIN)
    `uvm_field_enum(parity_t, parity_type, UVM_ALL_ON)
    `uvm_field_int(packet_delay, UVM_ALL_ON | UVM_DEC | UVM_NOCOMPARE)
  `uvm_object_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name = "yapp_packet");
    super.new(name);
  endfunction : new

  // Default Constraints
  constraint default_length { length > 0; length < 64; }
  constraint payload_size   { length == payload.size(); }
  constraint default_delay  { packet_delay >= 0; packet_delay < 20; }

  // Constrain for mostly GOOD_PARITY packets
  constraint default_parity { parity_type dist {BAD_PARITY := 1, GOOD_PARITY := 5}; }
  // Constraint address - Only 0, 1, 2 are valid addresses
  constraint default_addr  { addr != 'b11; }
 
  // Calculates correct parity over the header and payload
  function bit [7:0] calc_parity();
    calc_parity = {length, addr};
    for (int i=0; i<length; i++)
      calc_parity = calc_parity ^ payload[i];
  endfunction : calc_parity

  // sets parity field according to parity_type
  function void set_parity();
    parity = calc_parity();
    if (parity_type == BAD_PARITY)
      parity++;
  endfunction : set_parity

  // post_randomize() - sets parity
  function void post_randomize();
    set_parity();
  endfunction : post_randomize

endclass : yapp_packet


class short_yapp_packet extends yapp_packet;
  
  `uvm_object_utils(short_yapp_packet)

  // Constructor - required syntax for UVM automation and utilities
  function new (string name = "short_yapp_packet");
    super.new(name);
  endfunction : new

  constraint short_packet_length { length < 15; }
  constraint short_packet_address { addr != 'b11; }

endclass : short_yapp_packet