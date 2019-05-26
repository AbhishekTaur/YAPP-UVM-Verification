/*-----------------------------------------------------------------
File name     : yapp.svh
Developers    : Brian Dickinson
Created       : 01/04/11
Description   : This file imports the files of the simple YAPP UVC for lab06.
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011
-----------------------------------------------------------------*/

typedef uvm_config_db#(virtual yapp_if) yapp_vif_config;
`include "yapp_packet.sv"
`include "yapp_tx_monitor.sv"
`include "yapp_tx_sequencer.sv"
`include "yapp_tx_seqs.sv"
`include "yapp_tx_driver.sv"
`include "yapp_tx_agent.sv"
`include "yapp_env.sv"

