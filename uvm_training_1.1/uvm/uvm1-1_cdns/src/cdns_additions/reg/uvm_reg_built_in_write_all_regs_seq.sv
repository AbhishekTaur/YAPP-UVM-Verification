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

`ifndef UVM_REG_BUILT_IN_WRITE_ALL_REGS_SEQ
`define UVM_REG_BUILT_IN_WRITE_ALL_REGS_SEQ

/*
 /-----------------------------------------------------------------------------------------
 | SEQUENCE: uvm_reg_built_in_write_all_regs_seq
 |          <=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=>
 | This sequence is going to write all registers with random value. Sequence has a flag to
 | direct the value to be specific value, than random.
 | It is assumed that explicit predictor will handle checking of registers, when written
 | If user wants to avoid certain registers from getting written, they can filter out using
 |   a) Define attribute NO_WR_REG_TESTS for that register
 |   b) Use filtering available in base built-in-seq class
 \------------------------------------------------------------------------------------------
*/

class uvm_reg_built_in_write_all_regs_seq extends uvm_reg_built_in_base_seq;

  /*
  Variable: use_random_value
  User can chose to write controlled random value or fully directed value
  ~use_random_value~ = 1 -> sequence will randomize the register following its constraints
  ~use_random_value~ = 0 -> sequence will write ~directed_value~ [user defined] while writing
  */
  bit use_random_value=1;
  //Variable: directed_value
  uvm_reg_data_t directed_value=0;
 
  virtual function void setup();
    bit urv;
    uvm_reg_data_t dv;
    exclude_attributes=new[2](exclude_attributes);
    exclude_attributes[1]="NO_WR_REG_TESTS";
    if(uvm_config_db#(bit)::get(uvm_root::get(), get_full_name(), "use_random_value", urv))
      use_random_value=urv;
    if(!urv && uvm_config_db#(uvm_reg_data_t)::get(uvm_root::get(), get_full_name(), "directed_value", dv))
      directed_value=dv;
    super.setup();
  endfunction

  virtual task main();
    uvm_status_e status;
    uvm_path_e p = (path==UVM_BACKDOOR_RD_BACKDOOR_WR)?UVM_BACKDOOR:UVM_FRONTDOOR;

    foreach(regs[i]) begin
      uvm_reg_map m[$];
      regs[i].get_maps(m);
      foreach(m[j]) begin
        if(use_random_value) begin
          void'(regs[i].randomize());
          regs[i].update(status, p, m[j], .parent(this));
        end
        else
          regs[i].write(status, directed_value, p, m[j], .parent(this));
        `uvm_info("BUILT-IN-SEQ", $sformatf("  Wrote %s Register. Value = %0x", 
          regs[i].get_name(), regs[i].get()), UVM_HIGH)
      end
    end
  endtask

  `uvm_object_utils(uvm_reg_built_in_write_all_regs_seq)
  function new(string name="uvm_reg_built_in_write_all_regs_seq");
    super.new(name);
  endfunction
endclass : uvm_reg_built_in_write_all_regs_seq

`endif // UVM_REG_BUILT_IN_WRITE_ALL_REGS_SEQ
