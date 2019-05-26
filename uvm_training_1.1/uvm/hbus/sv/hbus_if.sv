/*-----------------------------------------------------------------
File name     : hbus_if.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:21 2009
Description   :
Notes         :
-------------------------------------------------------------------
Copyright 2009 (c) Cadence Design Systems
-----------------------------------------------------------------*/

/***************************************************************************
  FILE : hbus_if.sv
 ***************************************************************************/
`ifndef HBUS_IF_SV
`define HBUS_IF_SV

interface hbus_if (input clock, input reset);

  // Control flags
  bit                has_checks = 1;
  bit                has_coverage = 1;

  // Actual Signals
  logic            hen;
  logic            hwr_rd;
  logic      [7:0] haddr;
  logic      [7:0] hdata;

  // For bi-directional bus on the DUT
  wire [7:0] hdata_w;

  assign hdata_w = hdata;

  // Coverage and assertions to be implemented here.
`ifndef IFV
import uvm_pkg::*;
`include "uvm_macros.svh"
`endif

  /************************************************************************
   Add assertion checks as required. See assertion examples below.
   ************************************************************************/
   
// SVA default clocking
wire uvm_assert_clk = clock & has_checks;
default clocking master_clk @(negedge uvm_assert_clk);
endclocking

// SVA default reset
default disable iff (reset);

  // Address must not be X or Z during Address Phase
  assertAddrUnknown:assert property (
     ($onehot(hen) |-> !$isunknown(haddr))) else
     `uvm_error("HBUS Interface","Address went to X or Z during Address Phase")
 
  // If write cycle, then enable must be 1
  input_write_then_enabled : assert property (
     (hwr_rd |-> hen)) else 
     `uvm_error("HBUS Interface","Write enable asserted when not enabled")

  // If read cycle, then enable must be two cycles long
  input_read_then_enable_2_cycles : assert property (
     ($rose(hen) && !hwr_rd |=> hen)) else
     `uvm_error("HBUS Interface","Enable not 2 cycles long for read")
  
  // If read cycle, then address must remain stable 1 clock cycle
  input_read_then_address_stable : assert property (
     ($rose(hen) && !hwr_rd |=> $stable(haddr))) else
     `uvm_error("HBUS Interface","Address not stable during read")

endinterface : hbus_if

`endif //HBUS_IF_SV

