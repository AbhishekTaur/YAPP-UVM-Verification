// 
// -------------------------------------------------------------
//    Copyright 2011 Cadence.
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------

// should be package|class

  `include "cdns_additions/cdns_recording.svh"
  `include "cdns_additions/cdns_tcl.svh"

  // This file generate access permissions for backdoor access optimization
  `include "cdns_additions/reg/uvm_reg_generate_access_file_seq.sv"
  // Predictor extended
  `include "cdns_additions/reg/uvm_reg_predictor_ext.sv"
  // Base built-in-seq
  `include "cdns_additions/reg/uvm_reg_built_in_base_seq.sv"
  // Built-in-seq to read all registers inside a model
  `include "cdns_additions/reg/uvm_reg_built_in_read_all_regs_seq.sv"
  // Built-in-seq to write all registers inside a model
  `include "cdns_additions/reg/uvm_reg_built_in_write_all_regs_seq.sv"
  // Built-in-seq to do write-followed-by-read on all registers inside a model
  `include "cdns_additions/reg/uvm_reg_built_in_wr_follow_rd_seq.sv"
  // Built-in-seq to do aliasing on all registers inside a model
  `include "cdns_additions/reg/uvm_reg_built_in_aliasing_seq.sv"
  // Built-in-seq calls all built-in-sequences
  `include "cdns_additions/reg/uvm_reg_built_in_all_seq.sv"
