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

// This file layers on top of UVM to provide transaction recording. UVM provides 
// transaction hooks, but does not implement any transaction recording features.
// The cdns_uvm_recorder class creates a singleton recorder object that 
// replaces the uvm_default_recorder.

class cdns_uvm_recorder extends uvm_recorder;
  local bit m_do_text = 0;
  local static cdns_uvm_recorder m_inst = m_setup_recorder();
  static function cdns_uvm_recorder get();
     if(m_inst == null) 
       m_inst = new;
     return m_inst;
  endfunction

  local static function cdns_uvm_recorder m_setup_recorder();
     void'(get());
     uvm_default_recorder = m_inst;
  endfunction

  function new;
    set_name("cdns_uvm_recorder");
`ifdef CDNS_TEXT_RECORD
    m_do_text = 1;
`endif
  endfunction

  function void set_text_mode(bit on=1);
    m_do_text = on;
  endfunction
  function bit get_text_mode;
    return m_do_text;
  endfunction

  function bit open_file();
    if(m_do_text)
      void'(super.open_file());
    if (file == 0)
      file = $fopen(filename);
    return (file > 0);
  endfunction

  function integer create_stream (string name,
                                 string t,
                                 string scope);
    if(m_do_text)
      create_stream = super.create_stream(name, t, scope);
    return uvm_create_fiber(name,t,scope);
  endfunction

  function void m_set_attribute (integer txh,
                                 string nm,
                                 string value);
    if(m_do_text)
      super.m_set_attribute(txh, nm, value);
    uvm_set_attribute(txh,nm,uvm_string_to_bits(value),UVM_STRING,0);
  endfunction
  
  virtual function void set_attribute (integer txh,
                               string nm,
                               logic [1023:0] value,
                               uvm_radix_enum radix,
                               integer numbits=1024);
    if(m_do_text)
      super.set_attribute(txh, nm, value, radix, numbits);
    uvm_set_attribute(txh,nm,value,radix,numbits);
  endfunction
  
  function integer check_handle_kind (string htype, integer handle);
    return uvm_check_handle_kind(htype,handle);
  endfunction
  
  function integer begin_tr(string txtype,
                                     integer stream,
                                     string nm,
                                     string label="",
                                     string desc="",
                                     time begin_time=0);
    if(m_do_text)
      void'(super.begin_tr(txtype, stream, nm, label, desc, begin_time));
    return uvm_begin_transaction(txtype,stream,nm,label,desc,begin_time);
  endfunction
  
  function void end_tr (integer handle, time end_time=0);
    if(m_do_text)
      super.end_tr(handle, end_time);
   uvm_end_transaction(handle,end_time);
  endfunction
  
  function void link_tr(integer h1,
                                 integer h2,
                                 string relation="");
   if(m_do_text)
     super.link_tr(h1, h2, relation);
   uvm_link_transaction(h1,h2,relation);
  endfunction
  
  function void free_tr(integer handle);
   if(m_do_text)
     super.free_tr(handle);
   uvm_free_transaction_handle(handle);
  endfunction
//----------------------------------------------------------------------------


// create_fiber
// ----------------

protected function integer uvm_create_fiber (string name,
                                   string t,
                                   string scope);
  if(scope != "")
    uvm_create_fiber = $sdi_create_fiber(name,
                             t,
                             scope);
  else
    uvm_create_fiber = $sdi_create_fiber(name,
                             t,
                             "Transactions");
endfunction


// set_attribute_by_name
// -------------------------

protected function void uvm_set_attribute (integer txh,
                                         string nm,
                                         logic [1023:0] value,
                                         uvm_radix_enum radix,
                                         integer numbits=1024);
  if(radix == UVM_REAL || radix == UVM_REAL_DEC || radix == UVM_REAL_EXP) begin
    real rval;
    rval = $bitstoreal(value);
    $sdi_set_attribute_by_name(txh, nm, rval, "'s");
  end 
  else if(radix == UVM_NORADIX || radix == UVM_HEX) begin
    $sdi_set_attribute_by_name(txh, nm, value, "'h",,,numbits);
  end
  else if(radix == UVM_BIN) begin
    $sdi_set_attribute_by_name(txh, nm, value, "'b",,,numbits);
  end
  else if(radix == UVM_OCT) begin
    $sdi_set_attribute_by_name(txh, nm, value, "'o",,,numbits);
  end
  else if(radix == UVM_DEC) begin
    $sdi_set_attribute_by_name(txh, nm, value, "'s",,,numbits);
  end
  else if(radix == UVM_TIME) begin
    $sdi_set_attribute_by_name(txh, nm, value, "'u",,,numbits);
  end
  else if(radix == UVM_STRING || radix == UVM_ENUM) begin
    $sdi_set_attribute_by_name(txh, nm, value, "'a",,,numbits);
  end
  else begin
    $sdi_set_attribute_by_name(txh, nm, value, "'h",,,numbits);
  end
endfunction


// check_handle_kind
// ---------------------

protected function integer uvm_check_handle_kind (string htype, integer handle);
  return $sdi_check_handle_kind(htype, handle);
endfunction


// begin_transaction
// ---------------

protected function integer uvm_begin_transaction(string txtype,
                                 integer stream,
                                 string nm
                                 , string label="",
                                 string desc="",
                                 time begin_time=0
                                 );

  if (label == "") begin
    if (desc == "") begin
       if (begin_time == $realtime || begin_time == 0)
         return $sdi_transaction(uvm_string_to_bits(txtype), stream, nm);
       else
         return $sdi_transaction(uvm_string_to_bits(txtype), stream, nm,,,
                                 begin_time);
    end
    else begin
       if (begin_time == $realtime || begin_time == 0)
         return $sdi_transaction(uvm_string_to_bits(txtype), stream, nm,,
                                 desc);
       else
         return $sdi_transaction(uvm_string_to_bits(txtype), stream, nm,,
                                 desc,begin_time);
    end
  end
  else begin
    if (desc == "") begin
       if (begin_time == $realtime || begin_time == 0)
         return $sdi_transaction(uvm_string_to_bits(txtype), stream, nm,
                                 label);
       else
         return $sdi_transaction(uvm_string_to_bits(txtype), stream, nm,
                                 label,,begin_time);
    end
    else begin
       if (begin_time == $realtime || begin_time == 0)
         return $sdi_transaction(uvm_string_to_bits(txtype), stream, nm,
                                 label,desc);
       else
         return $sdi_transaction(uvm_string_to_bits(txtype), stream, nm,
                                 label,desc,
                                 begin_time);
    end
  end
endfunction


// end_transaction
// -------------------

protected function void uvm_end_transaction (integer handle, time end_time=0);
   if (end_time == $realtime || end_time == 0)
     $sdi_end_transaction(handle);
   else
     $sdi_end_transaction(handle, end_time);
endfunction


// link_transaction
// --------------------

protected function void uvm_link_transaction(integer h1, integer h2,
                                   string relation="");
  if (relation == "")
    $sdi_link_transaction(h2,h1);
  else
    $sdi_link_transaction(h2,h1,uvm_string_to_bits(relation));
endfunction



// free_transaction_handle
// ---------------------------

local function void uvm_free_transaction_handle(integer handle);
  $sdi_free_transaction_handle(handle);
endfunction

endclass


