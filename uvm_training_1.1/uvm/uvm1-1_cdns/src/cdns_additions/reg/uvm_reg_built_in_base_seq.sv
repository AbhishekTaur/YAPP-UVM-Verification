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

`ifndef UVM_REG_BUILT_IN_BASE_SEQ
`define UVM_REG_BUILT_IN_BASE_SEQ

/*
  Type: uvm_reg_addr_range_t
  This typedef can be used to define an address range from ~min~ to ~max~
*/
typedef struct {
  uvm_reg_addr_t min;
  uvm_reg_addr_t max;
} uvm_reg_addr_range_t;

/*
  Type: uvm_built_in_path_e
  This typedef can be used to define transfer paths in built-in-seq
  UVM_FRONTDOOR_RD_FRONTDOOR_WR  -> All transfers frontdoor
  UVM_FRONTDOOR_RD_BACKDOOR_WR   -> All reads frontdoor and writes backdoor
  UVM_BACKDOOR_RD_FRONTDOOR_WR   -> All reads backdoor and writes frontdoor
  UVM_BACKDOOR_RD_BACKDOOR_WR    -> All transfers backdoor
*/
typedef enum int {
  UVM_FRONTDOOR_RD_FRONTDOOR_WR,
  UVM_FRONTDOOR_RD_BACKDOOR_WR,
  UVM_BACKDOOR_RD_FRONTDOOR_WR,
  UVM_BACKDOOR_RD_BACKDOOR_WR
} uvm_built_in_path_e;

/*
  Type: uvm_built_in_conditions_e
  This typedef can be used to define conditions to filter out registers
  UVM_HAS_RESET_SET             -> Select all registers having HARD reset value set
  UVM_ALL_RW_REGISTERS          -> Select all read-write registers
  UVM_ALL_RO_REGISTERS          -> Select all read-only registers
  UVM_ALL_WO_REGISTERS          -> Select all write-only registers
  UVM_ALL_RW_REGISTERS          -> Filter all read-write registers
  UVM_ALL_RO_REGISTERS          -> Filter all read-only registers
  UVM_ALL_WO_REGISTERS          -> Filter all write-only registers
*/
typedef enum int {
  UVM_HAS_RESET_SET,
  UVM_SELECT_RW_REGISTERS,
  UVM_SELECT_RO_REGISTERS,
  UVM_SELECT_WO_REGISTERS,
  UVM_FILTER_RW_REGISTERS,
  UVM_FILTER_RO_REGISTERS,
  UVM_FILTER_WO_REGISTERS
} uvm_built_in_conditions_e;


/*
 /-------------------------------------------------------------------------------------------
 | SEQUENCE: uvm_reg_built_in_base_seq
 |           =========================
 | Base sequence class is going to collect all registers inside model
 | If user wants to avoid certain registers from getting accessed, they can filter out using
 |   a) Define attribute "NO_REG_TESTS" for that register
 |   b) add name in 'exclude_names' array
 |   c) add address in 'exclude_addresses' array
 |   d) define a range of addresses to be excluded using 'exclude_ranges'
 |   e) define a condition to select / filter register
 | User can set access (cmbinations of backdoor or frontdoor) paths using 'path' variable
 \-------------------------------------------------------------------------------------------
*/

virtual class uvm_reg_built_in_base_seq extends uvm_sequence;

  // The top register model class instance pointer
  uvm_reg_block                 model;
  // All maps inside model
  uvm_reg_map                   maps[$];
  // Hook to make sequence work front-door or back-door
  uvm_built_in_path_e           path=UVM_FRONTDOOR_RD_FRONTDOOR_WR;
  // All registers
  uvm_reg                       regs[$];
  // Filtered registers
  protected uvm_reg             fregs[$];
  /* 
    Variable: conditions
    This variable can be used to filter registers using pre-defined conditions.
  */
  uvm_built_in_conditions_e     conditions[];
  /* 
    Variable: exclude_names
    All registers with given rel-names, inside ~exclude_names~ array would get filtered. 
    Wildcard '.*?' supported [uvm pattern]
  */
  string                        exclude_names[];
  /* 
    Variable: exclude_addresses
    All registers with given relative address, inside ~exclude_addresses~ array, 
    will get filtered
  */
  uvm_reg_addr_t                exclude_addresses[];
  /* 
    Variable: exclude_ranges
    This variable can be used to describe excluding address range ~exclude_ranges~. 
    All registers within the given address ranges, will get filtered accordinly. 
  */
  uvm_reg_addr_range_t          exclude_ranges[];
  /* 
    Variable: include_ranges
    This variable can be used to describe excluding address range ~exclude_ranges~. 
    All registers within the given address ranges, will get filtered accordinly. 
  */
  uvm_reg_addr_range_t          include_ranges[];
  /* 
    Variable: exclude_attributes
    This variable can be used to filter registers using attributes.
  */
  string                        exclude_attributes[];
  /*
    Variable: debug
    If this bit is one, sequence banner will also include names of registers 
    that were filtered and some extra details. This is useful for debug purposes.
  */
  bit                           debug;

  /*
    Function: get_all_registers
    This function gets all registers inside the model (for all maps)
  */
  virtual function void get_all_registers();
    // get 'model'.
    if(!model)
      if (!(uvm_config_db#(uvm_reg_block)::get(uvm_root::get(), get_full_name(), "model", model)))
         `uvm_fatal("BUILT-IN-SEQ", $sformatf(
           "Sequence %s's container is not set. Cannot continue. Exiting..", get_full_name()))
    model.get_maps(maps);
    foreach (maps[i]) 
      maps[i].get_registers(regs);
  endfunction

  /*
    Function: get_configs
    Get all configuration parameters
  */
  virtual function void get_configs();
    int tmp_int=0;
    string tmp_str;

    // get 'exclude_attributes'
    if(uvm_config_db#(int)::get(uvm_root::get(), get_full_name(), "exclude_attributes", tmp_int))
      exclude_attributes=new[tmp_int](exclude_attributes);
    foreach(exclude_attributes[i]) begin
      if(uvm_config_db#(string)::get(uvm_root::get(), get_full_name(), 
        $sformatf("exclude_attributes[%0d]",i), tmp_str))
        exclude_attributes[i]=tmp_str;
    end
    tmp_int=0;
    tmp_str="";

    // get 'conditions'
    if(!conditions.size())
      void'(uvm_config_db#(int)::get(uvm_root::get(), get_full_name(), "conditions", tmp_int));
    conditions=new[tmp_int];
    tmp_int=0;
    foreach(conditions[i]) begin
      uvm_built_in_conditions_e c;
      void'(uvm_config_db#(uvm_built_in_conditions_e)::get(
        uvm_root::get(), get_full_name(), $sformatf("conditions[%0d]", i), c));
      conditions[i]=c;
    end
    tmp_int=0;

    // get 'exclude_ranges'
    if(!exclude_ranges.size())
      void'(uvm_config_db#(int)::get(uvm_root::get(), get_full_name(), "exclude_ranges", tmp_int));
    exclude_ranges=new[tmp_int];
    tmp_int=0;
    foreach(exclude_ranges[i]) begin
      uvm_reg_addr_range_t ar;
      void'(uvm_config_db#(uvm_reg_addr_range_t)::get(
        uvm_root::get(), get_full_name(), $sformatf("exclude_ranges[%0d]", i), ar));
      exclude_ranges[i]=ar;
    end

    // get 'include_ranges'
    if(!include_ranges.size())
      void'(uvm_config_db#(int)::get(uvm_root::get(), get_full_name(), "include_ranges", tmp_int));
    include_ranges=new[tmp_int];
    tmp_int=0;
    foreach(include_ranges[i]) begin
      uvm_reg_addr_range_t ar;
      void'(uvm_config_db#(uvm_reg_addr_range_t)::get(
        uvm_root::get(), get_full_name(), $sformatf("include_ranges[%0d]", i), ar));
      include_ranges[i]=ar;
    end

    // get 'path' variable.
    void'(uvm_config_db#(uvm_built_in_path_e)::get(uvm_root::get(), get_full_name(), "path", path));

    // get 'debug' variable.
    if(!debug) void'(uvm_config_db#(bit)::get(uvm_root::get(), get_full_name(), "debug", debug));

    // get 'exclude_names' variable.
    if(uvm_config_db#(int)::get(uvm_root::get(), get_full_name(), "exclude_names", tmp_int))
      exclude_names=new[tmp_int];
    foreach(exclude_names[i]) begin
      string s;
      void'(uvm_config_db#(string)::get(uvm_root::get(), get_full_name(), $sformatf("exclude_names[%0d]",i), s));
      exclude_names[i]=s;
    end

    // get 'exclude_addresses' variable.
    if(uvm_config_db#(int)::get(uvm_root::get(), get_full_name(), "exclude_addresses", tmp_int))
      exclude_addresses=new[tmp_int];
    foreach(exclude_addresses[i]) begin
      uvm_reg_addr_t a;
      void'(uvm_config_db#(uvm_reg_addr_t)::get(
        uvm_root::get(), get_full_name(), $sformatf("exclude_addresses[%0d]",i), a));
      exclude_addresses[i]=a;
    end
  endfunction

  /*
    Function: print_configs
    This function is going to print all configuration parameters of sequence
  */
  virtual function void print_configs();
    if(!uvm_report_enabled(UVM_LOW,UVM_INFO,"BUILT-IN-SEQ")) return;
    `uvm_info ("BUILT-IN-SEQ", "Printing sequence banner", UVM_LOW)
    $display("/---------------------------------------------------------------");
    $display("|  Starting %s Sequence", get_name());
    $display("|  Sequence's container : \"%s\"", model.get_full_name());
    $display("|  Number of registers selected = %0d", regs.size());
    $display("|  Number of registers filtered = %0d", fregs.size());
    if(debug)
      foreach(fregs[i])
        $display("|    %0d) %0s", i+1, fregs[i].get_name());
    $display("|  path = %0s", path.name());
    if(conditions.size())
      $display("|  conditions : %0d", conditions.size());
    foreach(conditions[i])
      $display("|    %0d) %s", i+1, conditions[i].name());
    // Print exclude_names
    if(exclude_names.size())
      $display("|  exclude_names : %0d", exclude_names.size());
    if(debug)
      foreach(exclude_names[i]) 
        $display("|    %0d) \"%s\"", i+1, exclude_names[i]);
    if(exclude_addresses.size())
      $display("|  exclude_addresses : %0d", exclude_addresses.size());
    if(debug)
      foreach(exclude_addresses[i]) 
        $display("|    %0d) 0x%0x", i+1, exclude_addresses[i]);
    if(exclude_ranges.size()) begin
      $display("|  exclude_ranges : %0d", exclude_ranges.size());
      if(debug) begin
        foreach(exclude_ranges[i])
          $display("|    %0d) 'h%0x-'h%0x", i+1, exclude_ranges[i].min, exclude_ranges[i].max);
      end
    end
    if(include_ranges.size()) begin
      $display("|  include_ranges : %0d", include_ranges.size());
      if(debug) begin
        foreach(include_ranges[i])
          $display("|    %0d) 'h%0x-'h%0x", i+1, include_ranges[i].min, include_ranges[i].max);
      end
    end
    $display("\\---------------------------------------------------------------");
  endfunction

  // Filter registers based on configuration parameter values
  virtual function void filter_regs();
    uvm_reg_indirect_data ui;
    for(int i=regs.size(); i>0; i--) begin
      // Remove abstract indirect register from this testing
      if($cast(ui, regs[i-1])) begin
        fregs.push_back(regs[i-1]);
        regs.delete(i-1); 
        continue;
      end
      // Remove registers which dont fulfill conditions
      foreach(conditions[j]) begin
        case (conditions[j])
          UVM_HAS_RESET_SET : begin
            if (!regs[i-1].has_reset()) begin
              fregs.push_back(regs[i-1]);
              regs.delete(i-1);
              break;
            end
          end
          default : begin
            uvm_reg_map m[$];
            regs[i-1].get_maps(m);
            foreach(m[k]) begin
              if (
                (conditions[j]==UVM_SELECT_RW_REGISTERS && regs[i-1].Xget_fields_accessX(m[k])!="RW") ||
                (conditions[j]==UVM_SELECT_RO_REGISTERS && regs[i-1].Xget_fields_accessX(m[k])!="RO") ||
                (conditions[j]==UVM_SELECT_WO_REGISTERS && regs[i-1].Xget_fields_accessX(m[k])!="WO") ||
                (conditions[j]==UVM_FILTER_RW_REGISTERS && regs[i-1].Xget_fields_accessX(m[k])=="RW") ||
                (conditions[j]==UVM_FILTER_RO_REGISTERS && regs[i-1].Xget_fields_accessX(m[k])=="RO") ||
                (conditions[j]==UVM_FILTER_WO_REGISTERS && regs[i-1].Xget_fields_accessX(m[k])=="WO")) 
              begin
                fregs.push_back(regs[i-1]);
                regs.delete(i-1);
                break;
              end
            end
            if(!regs[i-1]) break;
          end
        endcase
      end
      if(!regs[i-1]) continue;
      // Remove registers which have any of the exclude_attributes set
      foreach(exclude_attributes[j]) begin
        if (uvm_resource_db#(bit)::get_by_name({"REG::",regs[i-1].get_full_name()}, exclude_attributes[j], 0) != null) begin
          fregs.push_back(regs[i-1]);
          regs.delete(i-1);
          break;
        end
      end
      if(!regs[i-1]) continue;
      foreach(exclude_names[j]) begin
        if(uvm_is_match({"*",exclude_names[j]}, regs[i-1].get_name())) begin
          fregs.push_back(regs[i-1]);
          regs.delete(i-1);
          break;
        end
      end
      if(!regs[i-1]) continue;
      foreach(exclude_addresses[j]) begin
        foreach(maps[k])
          if(maps[k].get_reg_by_offset(exclude_addresses[j])==regs[i-1]) begin
            fregs.push_back(regs[i-1]);
            regs.delete(i-1);
            break;
          end
        if(!regs[i-1]) break;
      end
      if(!regs[i-1]) continue;
      foreach(exclude_ranges[j]) begin
        foreach(maps[k]) begin
          uvm_reg_addr_t a[];
          void'(regs[i-1].get_addresses(maps[k],a));
          foreach(a[l]) begin
            if(a[l] inside {[exclude_ranges[j].min:exclude_ranges[j].max]}) begin
              fregs.push_back(regs[i-1]);
              regs.delete(i-1);
              break;
            end
          end
          if(!regs[i-1]) break;
        end
        if(!regs[i-1]) break;
      end
    end
  endfunction

  // This function will 'get' all config parameters and filter out registers
  virtual function void setup();
    uvm_reg_map maps[$];

    // Get all registers inside model (from all maps)
    get_all_registers();
    // Get all configuration parameters for that particular sequence
    get_configs();
    // Filter registers based on configuration parameter values
    filter_regs();
  endfunction: setup

  // This function can be implemented by user to do further filtering of regiters
  virtual function void post_setup();
  endfunction

  virtual task body();
    // Not interested in getting response
    this.set_response_queue_error_report_disabled(1);
    setup();
    post_setup();
    print_configs();
    main();
    post_main();
  endtask
 
  // This task will be implemented by all sequences extensing from base sequence.
  pure virtual task main();

  virtual function void post_main();
    `uvm_info("BUILT-IN-SEQ", $sformatf("  Finishing %s sequence", get_name()), UVM_LOW) 
  endfunction

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

  function new(string name="uvm_reg_built_in_base_seq");
    super.new(name);
    exclude_attributes = new[1];
    exclude_attributes[0]="NO_REG_TESTS";
  endfunction
endclass : uvm_reg_built_in_base_seq

`endif // UVM_REG_BUILT_IN_BASE_SEQ
