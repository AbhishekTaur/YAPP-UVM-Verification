/*-----------------------------------------------------------------
File name     : channel.svh
Developers    : Kathleen Meade
Created       : *****
Description   : This file imports all the files of the UVC.
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

typedef uvm_config_db#(virtual channel_if) channel_vif_config;

import yapp_pkt_pkg::*;
//`include "yapp_packet.sv"
`include "channel_resp.sv"

// Common monitor for this ENV
`include "channel_monitor.sv"

//`include "channel_tx_monitor.sv"
`include "channel_tx_sequencer.sv"
`include "channel_tx_driver.sv"
`include "channel_tx_agent.sv"
`include "channel_tx_seqs.sv"

//`include "channel_rx_monitor.sv"
`include "channel_rx_sequencer.sv"
`include "channel_rx_driver.sv"
`include "channel_rx_agent.sv"
`include "channel_rx_seqs.sv"

`include "channel_env.sv"

