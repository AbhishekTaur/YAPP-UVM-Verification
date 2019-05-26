/*******************************************************************************
         
  Copyright (c) 2006 Cadence Design Systems, Inc. All rights reserved worldwide.
         
  This software is licensed under the Apache license, version 2.0 ("License"). 
  This software may only be used in compliance with the terms of the License.
  Any other use is strictly prohibited. You may obtain a copy of the License at 

    http://www.apache.org/licenses/LICENSE-2.0
         
        The software distributed under the License is provided  "AS IS" WITHOUT
  WARRANTY, EXPRESS OR IMPLIED, OF ANY KIND, INCLUDING, WITHOUT LIMITATION ANY
  WARRANTY AS TO PERFORMANCE, NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS
  FOR ANY PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE RESULTS AND PERFORMANCE
  OF THE PRODUCT IS ASSUMED BY YOU.  TO THE MAXIMUM EXTENT PERMITTED BY LAW,
  IN NO EVENT SHALL CADENCE BE LIABLE TO YOU OR ANY THIRD PARTY FOR ANY
  INCIDENTAL, INDIRECT, SPECIAL OR CONSEQUENTIAL DAMAGES, OR ANY OTHER DAMAGES,
  INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS PROFITS, BUSINESS
  INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR OTHER PECUNIARY LOSS ARISING
  OUT OF THE USE OFTHIS SOFTWARE.
         
        See the License terms for the specific language governing the permissions
  and limitations under the License.
         
*******************************************************************************/

`ifndef CDNS_TCL_INTERFACE_SVH
`define CDNS_TCL_INTERFACE_SVH


`ifdef UVM_PLI
`define cdns_uvm_access(ARG1) $uvm_set_access(ARG1);
`else
`define cdns_uvm_access(ARG1)
`endif

`define TCL_FILENAME ".uvmtclcomm.txt"

//------------------------------------------------------------------------------
//
// CLASS - cdns_hierarchy_only_printer
//
//------------------------------------------------------------------------------

class cdns_hierarchy_only_printer extends uvm_table_printer;
  function void print_object (string name, uvm_object value,
                              byte scope_separator=".");
    uvm_component no;
    if($cast(no, value)) super.print_object(name, value, scope_separator);
  endfunction
  function void print_string (string name, string value,
                              byte scope_separator="."); 
    return;
  endfunction
  function void print_time   (string name, time value,
                              byte scope_separator=".");
    return;
  endfunction
  function void print_field  ( string      name,
                               uvm_bitstream_t value,
                               int         size,
                               uvm_radix_enum  radix=UVM_NORADIX,
                               byte        scope_separator=".",
                               string      type_name="");
    return;
  endfunction
  function void print_generic (string name, string  type_name, 
                               int    size, string  value,
                              byte scope_separator=".");
    return;
  endfunction

  function new();
    super.new();
    knobs.size_width = 0;
    knobs.show_root = 1;
    knobs.reference=1;
  endfunction
endclass


//------------------------------------------------------------------------------
//
// CLASS - cdns_list_printer
//
//------------------------------------------------------------------------------

class cdns_list_printer extends uvm_printer;

  function void print_object (string name, uvm_object value,
                              byte scope_separator=".");
    uvm_component no;
    if($cast(no, value)) super.print_object(name, value, scope_separator);
  endfunction
  function void print_string (string name, string value,
                              byte scope_separator="."); 
    return;
  endfunction
  function void print_time   (string name, time value,
                              byte scope_separator=".");
    return;
  endfunction
  function void print_field  ( string      name,
                               uvm_bitstream_t value,
                               int         size,
                               uvm_radix_enum  radix=UVM_NORADIX,
                               byte        scope_separator=".",
                               string      type_name="");
    return;
  endfunction
  function new();
    super.new();
    knobs.full_name = 1;
    knobs.depth = 0;
    knobs.reference=1;
  endfunction
endclass


cdns_hierarchy_only_printer cdns_tcl_printer;
uvm_table_printer cdns_tcl_all_printer;

// All of these tcl functions are exported for dpi to allow direct tcl
// access.

// cdns_tcl_print_component
// --------------

export "DPI-C" function cdns_tcl_print_component;

function void cdns_tcl_print_component(string name,
                             int depth=1,
                             output bit [UVM_LARGE_STRING:0] rval,
                             input bit nooutput=0);
  uvm_component cq[$];
  uvm_printer p;
  uvm_component c;
  uvm_root top;
  integer fp;

  fp = $fopen(`TCL_FILENAME, "w");
  `cdns_uvm_access(rval)
  top = uvm_root::get();

  cq.delete();
  top.find_all(name, cq);

  if(!cq.size()) begin
    $fwrite(fp, "No components matching name %s were found", name);
    $fclose(fp);
    return;
  end

  if(! cdns_tcl_all_printer) cdns_tcl_all_printer = new;
  cdns_tcl_all_printer.knobs.show_root = 1;
  p = cdns_tcl_all_printer;

  p.knobs.depth = depth;
  for(int i=0; i<cq.size(); ++i) begin
    if(cq[i].print_enabled) begin
      $fwrite(fp,"%s",cq[i].sprint(p));
    end
  end

  $fclose(fp);
endfunction


// cdns_tcl_print_components
// ---------------

export "DPI-C" function cdns_tcl_print_components;

function void cdns_tcl_print_components(int depth=0,
                              bit all=0,
                              bit nooutput=1,
                              output bit [UVM_LARGE_STRING:0] rval);
  uvm_component c, cq[$];
  uvm_printer p;
  string cs;
  uvm_root top;
  integer fp;
  fp = $fopen(`TCL_FILENAME, "w");
  `cdns_uvm_access(rval)
  top = uvm_root::get();
  if(all) begin
    if(!cdns_tcl_all_printer) cdns_tcl_all_printer = new;
    cdns_tcl_all_printer.knobs.show_root = 1;
    p = cdns_tcl_all_printer;
  end
  else begin
    if(!cdns_tcl_printer) cdns_tcl_printer = new;
    p = cdns_tcl_printer;
  end

  cq.delete();
  if(top.get_first_child(cs)) 
    do begin
       c = top.get_child(cs);
       if(c.print_enabled)
         cq.push_back(c);
    end while(top.get_next_child(cs));

  if(cq.size() == 0)
    $fwrite(fp,"No uvm_component objects found in the design\n");
  else begin
    p.m_string = "";
    p.knobs.depth = depth;

    foreach(cq[i]) begin
      $fwrite(fp,"%s", cq[i].sprint(p));
    end

  end

  $fclose(fp);
endfunction


// cdns_tcl_list_components
// --------------

export "DPI-C" function cdns_tcl_list_components;

function void cdns_tcl_list_components(nooutput = 0,
                             output bit [UVM_LARGE_STRING:0] rval);
  uvm_component cq[$];
  uvm_root top;
  integer fp;

  fp = $fopen(`TCL_FILENAME, "w");

  cq.delete();
  top = uvm_root::get();
  rval = "";

  top.find_all("*",cq);

  if(cq.size() != 0) begin
    $fwrite(fp,"List of uvm components\n");
    // List is in bottom up order, but we want it in topdown order, so
    // traverse from back to front.
    for(int i=cq.size()-1; i>=0; --i) begin
      $fwrite(fp,"%s  (%s)(@%0d)\n",cq[i].get_full_name(), cq[i].get_type_name(), cq[i]);
    end
  end
  else begin
    $fwrite(fp,"No uvm components found");
  end

  $fdisplay(fp);
  $fclose(fp);
endfunction

// cdns_tcl_set
// -------

export "DPI-C" function cdns_tcl_set;

function void cdns_tcl_set(string component, 
   string field, uvm_bitstream_t value,
   bit do_config=0);

  uvm_root top;
  uvm_component cq[$];
  string f;
  top = uvm_root::get();
  if(do_config) begin
    set_config_int(component, field, value);
  end
  else begin
    cq.delete();
    top.find_all(component, cq);

    if(!cq.size())
      $display("uvm: *W,NOCOMP: No components match the name \"%s\", the set is ignored",component);

    for(int i=0; i<cq.size(); ++i) begin
      cq[i].set_int_local(field, value);
    end
  end
endfunction

// cdns_tcl_set_string
// ---------------

export "DPI-C" function cdns_tcl_set_string;

typedef class cdns_phase_process_watcher;

typedef struct {
  string component;
  string value;
} cdns_default_seq;

function void cdns_tcl_set_string(string component, 
   string field, string value,
   bit do_config);

  uvm_root top;
  uvm_component cq[$];

  top = uvm_root::get();
  if(do_config) begin
    if(field == "default_sequence")
    begin
      cdns_default_seq cfg; // TODO can use pattern assignment
      cfg.component = component;
      cfg.value = value;
      cdns_phase_process_watcher::set_default_seq(cfg);
    end
    else begin
      set_config_string(component, field, value);
    end
  end
  else begin
    cq.delete();
    top.find_all(component, cq);
    if(!cq.size())
      $display("uvm: *W,NOCOMP: No components match the name \"%s\", the set is ignored",component);

    for(int i=0; i<cq.size(); ++i) begin
      cq[i].set_string_local(field,value);
    end
  end
endfunction

// Messaging interface
parameter UVM_SET_VERBOSITY = 0;
parameter UVM_GET_VERBOSITY = 1;
parameter UVM_SET_ACTIONS   = 2;
parameter UVM_GET_ACTIONS   = 3;
parameter UVM_SET_STYLE     = 4;
parameter UVM_GET_STYLE     = 5;
parameter UVM_SET_SEVERITY  = 6;
parameter UVM_GET_SEVERITY  = 7;

function automatic bit cdns_get_reporter_matches (string name, ref uvm_report_object rq[$]);
  string s;
  uvm_root top;
  uvm_component cq[$];
  top = uvm_root::get();
  rq.delete();
  if((name == "") || (name == "*")) begin
    rq.push_back(top);
  end
  if(name != "") begin
    top.find_all(name, cq);
    foreach(cq[i]) rq.push_back(cq[i]);
  end
  if(rq.size()) begin
     return 1;
  end
  else begin
     return 0;
  end
endfunction

// Need to create a report catcher for the tag
class cdns_id_catcher extends uvm_report_catcher;
  uvm_pool#(uvm_report_object, uvm_pool#(string, int)) tag_map = new("tag_map");
  function new(string name="");
    super.new(name);
  endfunction
  function action_e catch(); 
    uvm_pool#(string, int) id_map;
    int v;
    if(tag_map.exists(get_client())) begin
      id_map = tag_map.get(get_client());
      if(id_map.exists(get_id())) begin
        v = id_map.get(get_id());
        if(get_verbosity() <= v) return CAUGHT;
      end
    end 
    return THROW;
  endfunction
  static cdns_id_catcher cdns_catcher = get();
  static function cdns_id_catcher get();
    if(cdns_catcher == null) begin
      cdns_catcher = new("cdns_catcher");
    end
    return cdns_catcher;
  endfunction
  bit added [uvm_report_object];
endclass
 
export "DPI-C" function cdns_tcl_set_message;

function void cdns_tcl_set_message ( string tag, string comp, int verbosity);
  uvm_report_object cq[$];
  uvm_root top;
  cdns_id_catcher catcher;
  void'(uvm_comparer::init());
  catcher = cdns_id_catcher::get();

  if(tag == "\"\"") tag = "";

  top = uvm_root::get();
  if(cdns_get_reporter_matches(comp, cq)) begin
     uvm_pool#(string, int) id_map;
     foreach(cq[i]) begin
       if(tag != "") begin
         if(catcher.tag_map.exists(cq[i])) begin
           id_map = catcher.tag_map.get(cq[i]);
         end
         else begin
           id_map = new;
           if(!catcher.added.exists(cq[i])) begin
             catcher.added[cq[i] ] = 1;
             uvm_report_cb::add(cq[i],catcher);
           end
           catcher.tag_map.add(cq[i], id_map);
         end
         id_map.add(tag, verbosity);
       end
       else begin
         cq[i].set_report_verbosity_level(verbosity);
       end
     end
  end
  else begin
    $display("uvm: *W,NOCOMP: No components match the name \"%s\", the verbosity setting is ignorned",comp);
  end
endfunction

export "DPI-C" function cdns_tcl_get_message;

function void cdns_tcl_get_message ( string tag, string comp);
  uvm_report_object cq[$];
  uvm_root top;
  integer fp;
  int verbosity;
  cdns_id_catcher catcher;

  if(tag == "\"\"") tag = "";
  verbosity = int'(UVM_MEDIUM);

  void'(uvm_comparer::init());
  catcher = cdns_id_catcher::get();

  fp = $fopen(`TCL_FILENAME, "w");
  top = uvm_root::get();
  if(cdns_get_reporter_matches(comp, cq)) begin
     uvm_pool#(string, int) id_map;
     if(cq[0]) begin
       if(tag != "") begin
         if(catcher.tag_map.exists(cq[0])) begin
           id_map = catcher.tag_map.get(cq[0]);
           if(id_map.exists(tag))
             verbosity = id_map.get(tag);
         end
       end
       else begin
         verbosity = cq[0].get_report_verbosity_level();
       end
     end
  end
  else begin
    $display("uvm: *W,NOCOMP: No components match the name \"%s\", unable to get the verbosity",comp);
  end

  case (verbosity)
    UVM_NONE: $fwrite(fp, "UVM_NONE");
    UVM_LOW: $fwrite(fp, "UVM_LOW");
    UVM_MEDIUM: $fwrite(fp, "UVM_MEDIUM");
    UVM_HIGH: $fwrite(fp, "UVM_HIGH");
    UVM_FULL: $fwrite(fp, "UVM_FULL");
    default: $fwrite(fp, "%0d", verbosity);
  endcase
  $fclose(fp);
endfunction



export "DPI-C" function cdns_tcl_get_phase;

function automatic void cdns_tcl_get_phase (output bit [UVM_SMALL_STRING:0] rval);
  uvm_phase ph;
  uvm_domain common;
  uvm_root top;
  uvm_phase phases[$];
  string curr;
  integer fp;
  fp = $fopen(`TCL_FILENAME, "w");
  top = uvm_root::get();
  common = uvm_domain::get_common_domain();

  phases.push_back(common.find(uvm_build_phase::get()));
  phases.push_back(common.find(uvm_connect_phase::get()));
  phases.push_back(common.find(uvm_end_of_elaboration_phase::get()));
  phases.push_back(common.find(uvm_start_of_simulation_phase::get()));
  phases.push_back(common.find(uvm_run_phase::get()));
  phases.push_back(common.find(uvm_extract_phase::get()));
  phases.push_back(common.find(uvm_check_phase::get()));
  phases.push_back(common.find(uvm_report_phase::get()));
  phases.push_back(common.find(uvm_final_phase::get()));

  curr = "Phasing not started";
  foreach(phases[i]) begin
    uvm_phase_state s;
    ph = phases[i];
    s = ph.get_state();
    if(s == UVM_PHASE_STARTED || s == UVM_PHASE_EXECUTING ||
             s == UVM_PHASE_READY_TO_END )
    begin
      curr = phases[i].get_name();
      break;
    end
    if(s == UVM_PHASE_DONE) begin
      curr = phases[i].get_name();
    end
  end

  $fwrite(fp, "%s", curr);
  $fclose(fp);
endfunction

export "DPI-C" function cdns_tcl_global_stop_request;

function void cdns_tcl_global_stop_request ();
    uvm_domain common;
    uvm_phase e; 

    common  = uvm_domain::get_common_domain();
    e = common.find_by_name("extract");
    uvm_domain::jump_all(e);            
endfunction
 

// API for user defined phases. Built-in phases will use direct
// event objects for greater user control.
//export "DPI-C" function cdns_tcl_break_at_phase;

event uvm_build_complete;
string uvm_break_phase="none";
bit   uvm_phase_is_start;

// Create a class with a process so it can run in a package
class cdns_phase_process_watcher;
  static cdns_phase_process_watcher phase_watcher = new;
  static bit started = 0;
  static cdns_default_seq seqs[$];

  function new;
    fork
      watch_phases;
    join_none
  endfunction
  task watch_phases;
  uvm_root top = uvm_root::get();
  `cdns_uvm_access(uvm_build_complete)
  `cdns_uvm_access(uvm_break_phase)
  `cdns_uvm_access(uvm_phase_is_start)

  void'(uvm_domain::get_common_domain());

  uvm_phase_is_start = 0;
  fork
    cdns_tcl_break_at_phase_task(uvm_build_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_build_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_connect_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_connect_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_end_of_elaboration_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_end_of_elaboration_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_start_of_simulation_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_start_of_simulation_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_run_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_run_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_extract_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_extract_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_check_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_check_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_report_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_report_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_final_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_final_phase::get(), 0);  

    cdns_tcl_break_at_phase_task(uvm_pre_reset_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_pre_reset_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_reset_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_reset_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_post_reset_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_post_reset_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_pre_configure_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_pre_configure_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_configure_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_configure_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_post_configure_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_post_configure_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_pre_main_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_pre_main_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_main_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_main_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_post_main_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_post_main_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_pre_shutdown_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_pre_shutdown_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_shutdown_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_shutdown_phase::get(), 0);  
    cdns_tcl_break_at_phase_task(uvm_post_shutdown_phase::get(), 1);  
    cdns_tcl_break_at_phase_task(uvm_post_shutdown_phase::get(), 0);  

    if(end_of_elaboration_ph != null) begin
      started = 1;
      foreach(seqs[i]) 
        set_default_seq(seqs[i]);
      end_of_elaboration_ph.wait_for_state(UVM_PHASE_READY_TO_END, UVM_GTE);
      ->uvm_build_complete;
    end
  join
  endtask

  static function void set_default_seq (cdns_default_seq cfg);
    uvm_factory factory;
    uvm_object_wrapper w;

    if(started) begin
      factory = uvm_factory::get();
      w =factory.find_by_name(cfg.value);

      if(w == null) begin
        uvm_report_error("NOTREG", { "Type ", cfg.value, " is not registered with the factory and cannot be used as a default sequence for ", cfg.component });
      end
      else begin
        uvm_config_db#(uvm_object_wrapper)::set(null, cfg.component, "default_sequence", w);
      end
    end
    else begin
      seqs.push_back(cfg);
    end
  endfunction
endclass

task automatic cdns_tcl_break_at_phase_task(uvm_phase phase, bit at_start);
  uvm_domain common;
  uvm_phase  thephase = phase;

  void'(uvm_root::get());
  common = uvm_domain::get_common_domain();
  if(thephase == null) return;
  phase = common.find(thephase);

  if(phase == null) begin
    common = uvm_domain::get_uvm_domain();
    phase = common.find(thephase);
  end

  if(at_start) phase.wait_for_state(UVM_PHASE_STARTED,UVM_EQ);
  else phase.wait_for_state(UVM_PHASE_DONE,UVM_EQ);
  uvm_phase_is_start = at_start;
  uvm_break_phase = phase.get_name();
//  $stop;
endtask


//
// cdns_tcl_uvm_version
// ---------------

export "DPI-C" function cdns_tcl_uvm_version;

function void cdns_tcl_uvm_version (output bit [UVM_SMALL_STRING:0] rval);
  integer fp;
  fp = $fopen(`TCL_FILENAME, "w");
  $fwrite(fp,"%s",uvm_revision_string());
  $fclose(fp);
endfunction

`endif //CDNS_TCL_INTERFACE_SVH
