/*-----------------------------------------------------------------
File name     : yapp_tx_seq_lib.sv
Developers    : Kathleen Meade, Brian Dickinson
Created       : 01/04/11
Description   : Simple sequence for testing YAPP UVC
Notes         : 
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// SEQUENCE: base yapp sequence - base sequence with objections from which 
// all sequences can be derived
//
//------------------------------------------------------------------------------
class yapp_base_seq extends uvm_sequence #(yapp_packet);
  
  // Required macro for sequences automation
  `uvm_object_utils(yapp_base_seq)

  // Constructor
  function new(string name="yapp_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    starting_phase.raise_objection(this, get_type_name());
    `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
  endtask : pre_body

  task post_body();
    starting_phase.drop_objection(this, get_type_name());
    `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
  endtask : post_body

endclass : yapp_base_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: yapp_5_packets
//
//------------------------------------------------------------------------------
class yapp_5_packets extends yapp_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(yapp_5_packets)

  // Constructor
  function new(string name="yapp_5_packets");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_5_packets sequence", UVM_LOW)
     repeat(5)
      `uvm_do(req)
  endtask
  
endclass : yapp_5_packets


class yapp_012_seq extends yapp_base_seq;

	`uvm_object_utils(yapp_012_seq)

	function new(string name="yapp_012_seq");
		super.new(name);
	endfunction : new

	virtual task body();
		`uvm_info(get_type_name(), "Executing yapp_012_seq sequence", UVM_LOW)
		`uvm_do_with(req, { addr == 2'b00; })
		`uvm_do_with(req, { addr == 2'b01; })
		`uvm_do_with(req, { addr == 2'b10; })
	endtask

endclass : yapp_012_seq


class yapp_1_seq extends yapp_base_seq;

	`uvm_object_utils(yapp_1_seq)

	function new(string name="yapp_1_seq");
		super.new(name);
	endfunction : new

	virtual task body();
		`uvm_info(get_type_name(), "Executing yapp_1_seq sequence", UVM_LOW)
		`uvm_do_with(req , { addr == 2'b01; })
	endtask : body

endclass : yapp_1_seq


class yapp_111_seq extends yapp_base_seq;

	`uvm_object_utils(yapp_111_seq)

	function new(string name="yapp_111_seq");
		super.new(name);
	endfunction : new

	yapp_1_seq yapp_seq;

	virtual task body();
		`uvm_info(get_type_name(), "Executing yapp_111_seq sequence", UVM_LOW)
		repeat(3)
			`uvm_do(yapp_seq)
	endtask : body

endclass : yapp_111_seq


class yapp_repeat_addr_seq extends yapp_base_seq;

	`uvm_object_utils(yapp_repeat_addr_seq)

	function new(string name="yapp_repeat_addr_seq");
		super.new(name);
	endfunction : new

	rand bit [1:0] seq_addr;

	constraint seq_addr_c { seq_addr <= 2'b10; }

	virtual task body();
		`uvm_info(get_type_name(), "Executing yapp_repeat_addr_seq sequence", UVM_LOW)
		`uvm_do_with(req, { addr == seq_addr; })
		`uvm_do_with(req, { addr == seq_addr; })
	endtask : body

endclass : yapp_repeat_addr_seq


class yapp_incr_payload_seq extends yapp_base_seq;

	`uvm_object_utils(yapp_incr_payload_seq)

	function new(string name="yapp_incr_payload_seq");
		super.new(name);
	endfunction : new

	virtual task body();
		`uvm_info(get_type_name(), "Executing yapp_incr_payload_seq sequence", UVM_LOW)
		`uvm_create(req)
		assert(req.randomize());
		for (int i=0;i<req.length;i++)
      		req.payload[i] = i;
		req.set_parity();
		`uvm_send(req);
	endtask : body

endclass : yapp_incr_payload_seq


class yapp_rnd_seqs extends yapp_base_seq;

	`uvm_object_utils(yapp_rnd_seqs)

	function new(string name="yapp_rnd_seqs");
		super.new(name);
	endfunction : new

	rand int count;

	constraint count_constraint {
		count inside {[1:10]}; 
	}

	virtual task body();
		`uvm_info(get_type_name(),  $sformatf("Executing yapp_rnd_seqs %0d times...", count), UVM_LOW)
		repeat (count) begin
      		`uvm_do(req)
    end
	endtask : body

endclass : yapp_rnd_seqs


class six_yapp_seq extends yapp_base_seq;
	`uvm_object_utils(six_yapp_seq)

 	// Parameter for this sequence
  	yapp_rnd_seqs yss;

  	// Constructor
  	function new(string name="six_yapp_seq");
    	super.new(name);
  	endfunction

  	// Sequence body definition
  	virtual task body();
    	`uvm_info(get_type_name(), "Executing six_yapp_seq sequence" , UVM_LOW)
    	`uvm_do_with(yss, {count==6;})
  	endtask
endclass : six_yapp_seq

class yapp_exhaustive_seq extends yapp_base_seq;

	`uvm_object_utils(yapp_exhaustive_seq)

	function new(string name="yapp_exhaustive_seq");
		super.new(name);
	endfunction : new

	yapp_5_packets yapp_5_packs;
	yapp_012_seq yapp_012_seqeunce;
	yapp_1_seq yapp_1_sequence;
	yapp_111_seq yapp_111_sequence;
	yapp_repeat_addr_seq yapp_repeat_addr_sequence;
	yapp_incr_payload_seq yapp_incr_payload_sequence;
	yapp_rnd_seqs yapp_rnd_sequence;
	six_yapp_seq six_yapp_sequence;

	virtual task body();
    	`uvm_info(get_type_name(), "Executing yapp_exhaustive_seq sequence" , UVM_LOW)
    	`uvm_do(yapp_5_packs)
    	`uvm_do(yapp_012_seqeunce)
    	`uvm_do(yapp_1_sequence)
    	`uvm_do(yapp_111_sequence)
    	`uvm_do(yapp_repeat_addr_sequence)
    	`uvm_do(yapp_incr_payload_sequence)
    	`uvm_do(yapp_rnd_sequence)
    	`uvm_do(six_yapp_sequence)
	endtask: body


endclass : yapp_exhaustive_seq


//------------------------------------------------------------------------------
//
// SEQUENCE: test_ovc_seq - sends packets to all 4 channels with
// incrementing payloads from 1 to 22. Used in Lab07
//
//------------------------------------------------------------------------------


class test_ovc_seq extends yapp_base_seq;

  `uvm_object_utils(test_ovc_seq)

  // Constructor
  function new(string name="test_ovc_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing TEST_OVC_SEQ", UVM_LOW)
    `uvm_create(req)
    req.packet_delay = 1;
    for (int ad=0; ad < 4; ad++) begin
      req.addr = ad;
      for (int lgt=1; lgt < 23; lgt++) begin
        req.length = lgt;
        req.payload = new[lgt];
        for (int pld = 0; pld < lgt; pld++)
          req.payload[pld] = pld;
        randcase
          20 : req.parity_type = BAD_PARITY;
          80 : req.parity_type = GOOD_PARITY;
        endcase
         req.set_parity();
        `uvm_send(req)
      end
    end
  endtask

endclass : test_ovc_seq
