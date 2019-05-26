/*-----------------------------------------------------------------
File name     : yapp_if.sv
Developers    : Brian Dickinson
Created       : 01/04/11
Description   : YAPP interface
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

interface yapp_if (input clock, input reset );
timeunit 1ns;
timeprecision 100ps;

  // Actual Signals
  logic              in_data_vld;
  logic              in_suspend;
  logic       [7:0]  in_data;
  
endinterface : yapp_if

