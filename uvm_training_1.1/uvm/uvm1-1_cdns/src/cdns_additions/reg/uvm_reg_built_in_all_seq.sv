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

`ifndef UVM_REG_BUILT_IN_ALL_SEQ
`define UVM_REG_BUILT_IN_ALL_SEQ

/*
 /-----------------------------------------------------------------------------------------
 | SEQUENCE: uvm_reg_built_in_write_all_regs_seq
 |           =========================
 | This sequence is going to start all built-in sequences one-by-one
 | If user wants to avoid certain registers from getting written, they can filter out
 | by defining attribute NO_REG_TESTS for that register. If registers are to be excluded for 
 | individual sequences, user can define indiviual attributes for that sequence
 |    a) NO_REG_TESTS    : Filter register from all built-in sequences
 |    b) NO_WR_REG_TESTS : Filter register from write-all-regs sequence
 |    c) NO_RD_REG_TESTS : Filter register from read-all-regs sequence
 |    d)   (b) or (c)    : Filter register from wr-follow-by-rd sequence
 \------------------------------------------------------------------------------------------
*/

class uvm_reg_built_in_all_seq extends uvm_reg_built_in_base_seq;
  
  uvm_reg_built_in_write_all_regs_seq wr_all;
  uvm_reg_built_in_read_all_regs_seq rd_all;
  uvm_reg_built_in_wr_follow_rd_seq wr_rd;
  uvm_reg_built_in_aliasing_seq alias_seq;

  // Raise in pre_body so the objection is only raised for root sequences.
  // There is no need to raise for sub-sequences since the root sequence
  // will encapsulate the sub-sequence. 
  virtual task pre_body();
    if (starting_phase!=null) begin
      `uvm_info(get_type_name(), $sformatf("%s pre_body() raising %s objection", 
	    get_sequence_path(), starting_phase.get_name()), UVM_MEDIUM);
      starting_phase.raise_objection(this);
    end
  endtask

  virtual task body();
    `uvm_info("BUILT-IN-SEQ", "Starting all built in sequences", UVM_FULL)
    `uvm_do(rd_all)
    `uvm_info("BUILT-IN-SEQ", "Completed read-all registers sequence", UVM_FULL)
    `uvm_do(wr_all)
    `uvm_info("BUILT-IN-SEQ", "Completed write-all registers sequence", UVM_FULL)
    `uvm_do(wr_rd)
    `uvm_info("BUILT-IN-SEQ", "Completed write-read registers sequence", UVM_FULL)
    `uvm_do(alias_seq)
    `uvm_info("BUILT-IN-SEQ", "Completed aliasing-sequence", UVM_FULL)
  endtask

  virtual task main();
  endtask

  // Drop the objection in the post_body so the objection is removed when
  // the root sequence is complete. 
  virtual task post_body();
    if (starting_phase!=null) begin
      `uvm_info(get_type_name(),
        $sformatf("%s post_body() dropping %s objection", get_sequence_path(),
        starting_phase.get_name()), UVM_MEDIUM);
      starting_phase.drop_objection(this);
    end
  endtask

  `uvm_object_utils(uvm_reg_built_in_all_seq)
  function new(string name="uvm_reg_built_in_all_seq");
    super.new(name);
  endfunction
endclass : uvm_reg_built_in_all_seq

`endif // UVM_REG_BUILT_IN_ALL_SEQ
