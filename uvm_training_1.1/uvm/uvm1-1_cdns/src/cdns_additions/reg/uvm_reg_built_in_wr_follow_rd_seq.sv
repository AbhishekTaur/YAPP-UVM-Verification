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

`ifndef UVM_REG_BUILT_IN_WR_FOLLOW_RD_SEQ
`define UVM_REG_BUILT_IN_WR_FOLLOW_RD_SEQ

/*
 /-----------------------------------------------------------------------------------------
 | SEQUENCE: uvm_reg_built_in_wr_follow_rd_seq
 |          <=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=>
 | This sequence is going to first write register and then immediately read that register
 | For writing, sequence has a flag to direct the value to be specific value, than random.
 | It is assumed that explicit predictor will handle checking of registers, when written
 | If user wants to avoid certain registers from getting written, they can filter out using
 |   a) Define attribute NO_WR_REG_TESTS or NO_RD_REG_TESTS for that register
 |   b) Use filtering available in base built-in-seq class
 \------------------------------------------------------------------------------------------
*/

class uvm_reg_built_in_wr_follow_rd_seq extends uvm_reg_built_in_base_seq;

  /*
  Variable: use_random_value
  User can chose to write controlled random value or fully directed value
  ~use_random_value~ = 1 -> sequence will randomize the register following its constraints
  ~use_random_value~ = 0 -> sequence will write ~directed_value~ [user defined] while writing
  */
  bit use_random_value=1;
  //Variable: directed_value
  uvm_reg_data_t directed_value=0;
  /*
  Variable: wr_rd_delay
  While doing wr-followed-by-rd (wr frontdoor and rd backdoor) sequence should 
  wait few cycles before it does a rd. This is to allow non-blocking write to
  complete before value is read backdoor.
  */
  time wr_rd_delay=0;
 
  virtual function void setup();
    bit urv;
    uvm_reg_data_t dv;
    time t;
    exclude_attributes=new[3](exclude_attributes);
    exclude_attributes[1]="NO_WR_REG_TESTS";
    exclude_attributes[2]="NO_RD_REG_TESTS";
    if(uvm_config_db#(bit)::get(uvm_root::get(), get_full_name(), "use_random_value", urv))
      use_random_value=urv;
    if(!urv && uvm_config_db#(uvm_reg_data_t)::get(uvm_root::get(), get_full_name(), "directed_value", dv))
      directed_value=dv;
    if(uvm_config_db#(time)::get(uvm_root::get(), get_full_name(), "wr_rd_delay", t))
      wr_rd_delay=t;
    super.setup();
  endfunction

  virtual task main();
    uvm_status_e status;
    uvm_reg_data_t data;
    uvm_path_e wp = (path inside {UVM_FRONTDOOR_RD_BACKDOOR_WR, UVM_BACKDOOR_RD_BACKDOOR_WR})?
      UVM_BACKDOOR:UVM_FRONTDOOR;
    uvm_path_e rp = (path inside {UVM_BACKDOOR_RD_FRONTDOOR_WR, UVM_BACKDOOR_RD_BACKDOOR_WR})?
      UVM_BACKDOOR:UVM_FRONTDOOR;
    // Introduce some delay if reading backdoor.
    if(rp==UVM_BACKDOOR && wr_rd_delay==0) wr_rd_delay=1;

    foreach(regs[i]) begin
      uvm_reg_map m[$];
      regs[i].get_maps(m);
      foreach(m[j]) begin
        if(use_random_value) begin
          void'(regs[i].randomize());
          regs[i].update(status, wp, m[j], .parent(this));
        end
        else
          regs[i].write(status, directed_value, wp, m[j], .parent(this));
        `uvm_info("BUILT-IN-SEQ", $sformatf("  Wrote %s Register. Value = %0x", regs[i].get_name(), regs[i].get()), UVM_HIGH)
        if(wr_rd_delay) #wr_rd_delay;
        regs[i].read(status, data, rp, m[j], .parent(this));
        `uvm_info("BUILT-IN-SEQ", $sformatf("  Read %s Register. Value = %0x", regs[i].get_name(), regs[i].get()), UVM_HIGH)
      end
    end
  endtask

  `uvm_object_utils(uvm_reg_built_in_wr_follow_rd_seq)
  function new(string name="uvm_reg_built_in_write_all_regs_seq");
    super.new(name);
  endfunction
endclass : uvm_reg_built_in_wr_follow_rd_seq

`endif // UVM_REG_BUILT_IN_WR_FOLLOW_RD_SEQ
