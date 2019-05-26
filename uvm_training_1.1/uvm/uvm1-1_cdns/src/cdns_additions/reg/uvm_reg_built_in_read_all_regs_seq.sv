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

`ifndef UVM_REG_BUILT_IN_READ_ALL_REGS_SEQ
`define UVM_REG_BUILT_IN_READ_ALL_REGS_SEQ

/*
 /-----------------------------------------------------------------------------------------
 | SEQUENCE: uvm_reg_built_in_read_all_regs_seq
 |          <=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+>
 | This sequence is going to read all registers.
 | It is assumed that explicit predictor will handle checking of registers, when read
 | If user wants to avoid certain registers from getting read, they can filter out using
 |   a) Define attribute NO_RD_REG_TESTS for that register
 |   b) Use filtering available in base built-in-seq class
 \------------------------------------------------------------------------------------------
*/

class uvm_reg_built_in_read_all_regs_seq extends uvm_reg_built_in_base_seq;
 
  virtual function void setup();
    exclude_attributes=new[2](exclude_attributes);
    exclude_attributes[1]="NO_RD_REG_TESTS";
    super.setup();
  endfunction

  virtual task main();
    uvm_status_e status;
    bit [63:0] data;
    uvm_path_e p = (path==UVM_BACKDOOR_RD_BACKDOOR_WR)?UVM_BACKDOOR:UVM_FRONTDOOR;

    foreach(regs[i]) begin
      uvm_reg_map m[$];
      regs[i].get_maps(m);
      foreach(m[j]) begin
        regs[i].read(status, data, p, m[j], .parent(this));
        `uvm_info("BUILT-IN-SEQ", $sformatf("  Read %s Register. Value = %0x", regs[i].get_name(), data), UVM_HIGH)
      end
    end
  endtask

  `uvm_object_utils(uvm_reg_built_in_read_all_regs_seq)
  function new(string name="uvm_reg_built_in_read_all_regs_seq");
    super.new(name);
  endfunction
endclass : uvm_reg_built_in_read_all_regs_seq

`endif // UVM_REG_BUILT_IN_READ_ALL_REGS_SEQ
