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

`ifndef UVM_REG_BUILT_IN_ALIASING_SEQ
`define UVM_REG_BUILT_IN_ALIASING_SEQ

/*
 /-----------------------------------------------------------------------------------------
 | SEQUENCE: uvm_reg_built_in_aliasing_seq
 |          <=+=+=+=+=+=+=+=+=+=+=+=+=+=+=>
 | It writes a random value to a register and reads all the other registers to make 
 | sure the write did not affect them. It does this for each and every register in the 
 | collection pattern and issue write followed by read. 
 | If user wants to avoid certain registers from getting written, they can filter out using
 |   a) Define attribute NO_WR_REG_TESTS or NO_RD_REG_TESTS for that register
 |   b) Use filtering available in base built-in-seq class
 \------------------------------------------------------------------------------------------
*/

class uvm_reg_built_in_aliasing_seq extends uvm_reg_built_in_base_seq;

  virtual function void setup();
    exclude_attributes=new[3](exclude_attributes);
    exclude_attributes[1]="NO_WR_REG_TESTS";
    exclude_attributes[2]="NO_RD_REG_TESTS";
    super.setup();
  endfunction

  virtual task main();
    uvm_status_e status;
    uvm_reg_data_t data;
    uvm_path_e wp = (path inside {UVM_FRONTDOOR_RD_BACKDOOR_WR, UVM_BACKDOOR_RD_BACKDOOR_WR})?
      UVM_BACKDOOR:UVM_FRONTDOOR;
    uvm_path_e rp = (path inside {UVM_BACKDOOR_RD_FRONTDOOR_WR, UVM_BACKDOOR_RD_BACKDOOR_WR})?
      UVM_BACKDOOR:UVM_FRONTDOOR;

    foreach(regs[i]) begin
      uvm_reg_map m[$];
      regs[i].get_maps(m);
      foreach(m[j]) begin
        void'(regs[i].randomize());
        regs[i].update(status, wp, m[j], .parent(this));
        `uvm_info("BUILT-IN-SEQ", $sformatf(
          "  Wrote %s Register. Value = %0x", regs[i].get_name(), regs[i].get()), UVM_HIGH)
        foreach(regs[j]) begin
          if(i!=j) begin
            regs[j].read(status, data, rp, m[j], .parent(this));
            `uvm_info("BUILT-IN-SEQ", $sformatf(
              "  Read %s Register. Value = %0x", regs[i].get_name(), data), UVM_HIGH)
          end
        end
      end
    end
  endtask

  `uvm_object_utils(uvm_reg_built_in_aliasing_seq)
  function new(string name="uvm_reg_built_in_aliasing_seq");
    super.new(name);
  endfunction
endclass : uvm_reg_built_in_aliasing_seq

`endif // UVM_REG_BUILT_IN_ALIASING_SEQ
