/*-----------------------------------------------------------------
File name     : hbus.svh
Developers    : Kathleen Meade
Created       : Sun Feb 15 11:02:21 2009
Description   :
Notes         :
-------------------------------------------------------------------
Copyright 2009 (c) Cadence Design Systems
-----------------------------------------------------------------*/

`ifndef HBUS_SVH
`define HBUS_SVH

typedef uvm_config_db#(virtual hbus_if) hbus_vif_config;

`include "hbus_transaction.sv"

`include "hbus_monitor.sv"

`include "hbus_master_sequencer.sv"
`include "hbus_master_driver.sv"
`include "hbus_master_agent.sv"
`include "hbus_master_seqs.sv"

`include "hbus_slave_sequencer.sv"
`include "hbus_slave_driver.sv"
`include "hbus_slave_agent.sv"
`include "hbus_slave_seqs.sv"

`include "hbus_env.sv"

`endif // HBUS_SVH
