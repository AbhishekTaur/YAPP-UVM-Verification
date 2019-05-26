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

`ifndef GEN_ACCESS_FILE
`define GEN_ACCESS_FILE

class uvm_reg_generate_access_file_seq extends uvm_reg_mem_hdl_paths_seq;
  local integer filenr = $fopen("access_file");

  // the access path store
  local bit store[string];

  virtual task body();
    `uvm_info("RegMem","generating IUS access file",UVM_NONE)
    $fdisplay(filenr,"DEFAULT -rwc");
    store.delete();
    super.body();
    
    foreach(store[idx])
      $fdisplay(filenr,"PATH %s +rw",idx);
        
    `uvm_info("RegMem","pass the generated file to irun via \"-afile access_file\"",UVM_NONE)
    $fclose(filenr);
  endtask
  
  // remove trailing [] indicating a partial access to an hdl object
  // 1. assumption is that there are no encapsulated delimiter
  // 2. assumption that this is not an escaped 
  virtual function string clean_path(string a);
    if(!(a[a.len()-1] inside {"]",")"}))
        return a;
        
    begin
      int unsigned idx = a.len()-1;
      byte search_char = a[idx]=="]" ? "[" : "(";

      for(int i=idx; i>0; i--) begin
        if(a[i] == search_char) begin
          return clean_path(a.substr(0,i-1));
        end 
      end
                          
      `uvm_fatal("RegMem",{"access file generation failed on path ",a})
    end 
  endfunction
  

  protected virtual function void check_reg(uvm_reg r,
                                            string kind);
    uvm_hdl_path_concat paths[$];

    // avoid calling get_full_hdl_path when the register has not path for this abstraction kind
    if(!r.has_hdl_path(kind)) return;

    r.get_full_hdl_path(paths, kind);
    if (paths.size() == 0) return;

    foreach(paths[p]) begin
      uvm_hdl_path_concat path=paths[p];
      foreach (path.slices[j]) begin
        string p_ = path.slices[j].path;
        store[clean_path(p_)]=1;
      end
    end
  endfunction


  protected virtual function void check_mem(uvm_mem m,
                                            string kind);
    uvm_hdl_path_concat paths[$];

    // avoid calling get_full_hdl_path when the register has not path for this abstraction kind
    if(!m.has_hdl_path(kind)) return;

    m.get_full_hdl_path(paths, kind);
    if (paths.size() == 0) return;

    foreach(paths[p]) begin
      uvm_hdl_path_concat path=paths[p];
      foreach (path.slices[j]) 
      begin
        string p_ = path.slices[j].path;
        store[clean_path(p_)]=1;
      end
    end
  endfunction 

  `uvm_object_utils(uvm_reg_generate_access_file_seq)

  function new(string name="uvm_reg_generate_access_file_seq");
    super.new(name);
  endfunction
endclass: uvm_reg_generate_access_file_seq

`endif // GEN_ACCESS_FILE
