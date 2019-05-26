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

`ifndef CDNS_PREDICTOR_EXT
`define CDNS_PREDICTOR_EXT


/*  
  <><><><><><><><><><><>
   uvm_reg_predictor_ext
  <><><><><><><><><><><>

 Does a compare before updating upon read and updates upon write
 It takes care of logging indirect registers updates correctly
*/
class uvm_reg_predictor_ext #(type BUSTYPE=int) extends uvm_reg_predictor#(BUSTYPE);

  local uvm_predict_s m_pending[uvm_reg];
  virtual function void write(BUSTYPE tr);
     uvm_reg rg;
     uvm_reg_bus_op rw;
     assert(adapter != null);

     // In case they forget to set byte_en
     rw.byte_en = -1;
     adapter.bus2reg(tr,rw);
     rg = map.get_reg_by_offset(rw.addr, (rw.kind == UVM_READ));

     // ToDo: Add memory look-up and call uvm_mem::XsampleX()

     if (rg != null) begin
       bit found;
       uvm_reg_item reg_item;
       uvm_reg_map local_map;
       uvm_reg_map_info map_info;
       uvm_predict_s predict_info;
 
       if (!m_pending.exists(rg)) begin
         uvm_reg_item item = new;
         predict_info =new;
         item.element_kind = UVM_REG;
         item.element      = rg;
         item.path         = UVM_PREDICT;
         item.map          = map;
         item.kind         = rw.kind;
         predict_info.reg_item = item;
         m_pending[rg] = predict_info;
       end
       predict_info = m_pending[rg];
       reg_item = predict_info.reg_item;

       if (predict_info.addr.exists(rw.addr)) begin
          `uvm_error("REG_PREDICT_COLLISION",{"Collision detected for register '",
                     rg.get_full_name(),"'"})
          // TODO: what to do with subsequent collisions?
          m_pending.delete(rg);
       end

       local_map = rg.get_local_map(map,"predictor::write()");
       map_info = local_map.get_reg_map_info(rg);

       foreach (map_info.addr[i]) begin
         if (rw.addr == map_info.addr[i]) begin
            found = 1;
           reg_item.value[0] |= rw.data << (i * map.get_n_bytes()*8);
           predict_info.addr[rw.addr] = 1;
           if (predict_info.addr.num() == map_info.addr.size()) begin
              // We've captured the entire abstract register transaction.
              uvm_predict_e predict_kind = 
                  (reg_item.kind == UVM_WRITE) ? UVM_PREDICT_WRITE : UVM_PREDICT_READ;
              pre_predict(reg_item);
              `ifdef CDNS_UVM_EXT
              // ----------------------
              begin // Begin Comparison
              // ----------------------
                uvm_reg_indirect_data dreg;
                uvm_reg r=rg;
                if($cast(dreg, r)) r=dreg.get_data_reg();
                if(reg_item.kind == UVM_READ) begin
                  //uvm_reg_data_t  exp=r.get_mirrored_value(), dc=0, v=reg_item.value[0];
                  uvm_reg_data_t  exp=r.get(), dc=0, v=reg_item.value[0];
                  uvm_reg_field flds[$];
                  r.get_fields(flds);
                  // Assume that WO* field will readback as 0's
                  foreach(flds[i]) begin
                     string acc = flds[i].get_access(map);
                     if (flds[i].get_compare() == UVM_NO_CHECK) begin
                        dc |= ((1 << flds[i].get_n_bits())-1)
                              << flds[i].get_lsb_pos();
                     end
                     else if (acc == "WO" ||
                              acc == "WOC" ||
                              acc == "WOS" ||
                              acc == "WO1") begin
                        // Assume WO fields will always read-back as 0
                        exp &= ~(((1 << flds[i].get_n_bits())-1)
                                 << flds[i].get_lsb_pos());
                     end

                  end
                  if ((v|dc) !== (exp|dc)) begin
                     `uvm_error("REG_PREDICT", 
                        $sformatf("Register \"%s\" value read from DUT (0x%0h) does not match mirrored value (0x%0h)",
                                                 r.get_full_name(), v, (exp ^ ('x & dc))));
                                                 
                      foreach(flds[i]) begin
                         if(flds[i].get_compare() == UVM_CHECK) begin
                             uvm_reg_data_t mask=((1 << flds[i].get_n_bits())-1);
                             uvm_reg_data_t field = mask << flds[i].get_lsb_pos();
                             uvm_reg_data_t diff = ((v ^ exp) >> flds[i].get_lsb_pos()) & mask;
                             if(diff)
                                `uvm_info("REG_PREDICT",
                                   $sformatf("Field %s mismatch read=%0d'h%0h mirrored=%0d'h%0h slice [%0d:%0d]",flds[i].get_name(),
                                    flds[i].get_n_bits(),(v >> flds[i].get_lsb_pos()) & mask,
                                    flds[i].get_n_bits(),(exp >> flds[i].get_lsb_pos())&mask,
                                    flds[i].get_lsb_pos()+flds[i].get_n_bits()-1,flds[i].get_lsb_pos()),UVM_NONE)
                         end
                      end
                  end
                end
              //-------------------
              end // End Comparison
              //-------------------
              `endif

              rg.XsampleX(reg_item.value[0], rw.byte_en,
                          reg_item.kind == UVM_READ, local_map);
              begin
                 uvm_reg_block blk = rg.get_parent();
                 blk.XsampleX(map_info.offset,
                              reg_item.kind == UVM_READ,
                              local_map);
              end
              rg.do_predict(reg_item, predict_kind, rw.byte_en);
              `ifdef CDNS_UVM_EXT
              begin
                uvm_reg_indirect_data dreg;
                uvm_reg r;
                r=($cast(dreg, rg)) ? dreg.get_data_reg() : rg;
                `uvm_info("REG_PREDICT", 
                  $sformatf("%s to register %s with value = 'h%0x updated value = 'h%0x",
                  reg_item.kind.name(), r.get_full_name(), reg_item.value[0], r.get()), UVM_MEDIUM)
              end
              `else
                `uvm_info("REG_PREDICT", 
                  $sformatf("%s to register %s with value = 'h%0x",
                  reg_item.kind.name(), rg.get_full_name(), reg_item.value[0]), UVM_MEDIUM)
              `endif
              reg_ap.write(reg_item);
              m_pending.delete(rg);
           end
           break;
         end
       end
       if (!found)
         `uvm_error("REG_PREDICT_INTERNAL",{"Unexpected failed address lookup for register '",
                  rg.get_full_name(),"'"})
     end
     else begin
       `uvm_info("REG_PREDICT_NOT_FOR_ME",
          {"Observed transaction does not target a register: ",
            $sformatf("%p",tr)},UVM_FULL)
     end
  endfunction
  `uvm_component_param_utils(uvm_reg_predictor_ext#(BUSTYPE))

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass : uvm_reg_predictor_ext

`endif // CDNS_PREDICTOR_EXT
