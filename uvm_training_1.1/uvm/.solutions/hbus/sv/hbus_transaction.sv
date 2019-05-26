/*-----------------------------------------------------------------
File name     : hbus_transaction.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:21 2009
Description   :
Notes         :
-------------------------------------------------------------------
Copyright 2009 (c) Cadence Design Systems
-----------------------------------------------------------------*/

`ifndef HBUS_TRANSACTION_SV
`define HBUS_TRANSACTION_SV

//------------------------------------------------------------------------------
//
// hbus transaction enums, parameters, and events
//
//------------------------------------------------------------------------------

typedef enum bit { HBUS_READ, HBUS_WRITE } hbus_read_write_enum;

//------------------------------------------------------------------------------
//
// CLASS: hbus_transaction
//
//------------------------------------------------------------------------------

class hbus_transaction extends uvm_sequence_item;     

  rand bit [7:0]            haddr;
  rand bit [7:0]            hdata;
  rand hbus_read_write_enum hwr_rd;
  rand int unsigned         wait_between_cycle;
 
  constraint c_wait { wait_between_cycle >0; wait_between_cycle <= 3 ; }
  constraint c_addr_range { haddr >=0; haddr < 32 ; }

  `uvm_object_utils_begin(hbus_transaction)
    `uvm_field_int(haddr, UVM_DEFAULT)
    `uvm_field_int(hdata, UVM_DEFAULT)
    `uvm_field_enum(hbus_read_write_enum, hwr_rd, UVM_DEFAULT)
    `uvm_field_int(wait_between_cycle, UVM_DEFAULT | UVM_NOPACK | UVM_NOCOMPARE)
  `uvm_object_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name = "hbus_transaction");
    super.new(name);
  endfunction : new

endclass : hbus_transaction

`endif // HBUS_TRANSACTION_SV
