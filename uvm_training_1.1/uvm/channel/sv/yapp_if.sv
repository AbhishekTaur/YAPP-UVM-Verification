/*-----------------------------------------------------------------
File name     : yapp_if.sv
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:24 2009
Description   :
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

interface yapp_if (input clock, input reset );

  // Actual Signals
  logic              data_vld;
  logic              suspend;
  logic       [7:0]  data;
  
  // Control flags
  bit                has_checks = 1;
  bit                has_coverage = 1;

endinterface : yapp_if

