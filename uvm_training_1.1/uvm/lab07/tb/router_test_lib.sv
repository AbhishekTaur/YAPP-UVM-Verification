class base_test extends uvm_test;

	`uvm_component_utils(base_test)

	router_tb route;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		route = router_tb::type_id::create("route", this);
	endfunction: build_phase

	virtual function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction: end_of_elaboration_phase

	virtual function void check_phase(uvm_phase phase);
		check_config_usage();
	endfunction: check_phase

	virtual task run_phase(uvm_phase phase);
		phase.phase_done.set_drain_time(this, 200ns);
	endtask : run_phase

endclass : base_test


class test2 extends base_test;

	`uvm_component_utils(test2)

	function new(string name, uvm_component parent);
    	super.new(name, parent);
  	endfunction : new

endclass: test2


class short_packet_test extends base_test;

	`uvm_component_utils(short_packet_test)
 
	function new(string name, uvm_component parent);
    	super.new(name, parent);
  	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
		super.build_phase(phase);

	endfunction: build_phase

endclass: short_packet_test

class set_config_test extends base_test;

	`uvm_component_utils(set_config_test)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		set_config_int("*agent", "is_active", UVM_PASSIVE);
		super.build_phase(phase);
	endfunction : build_phase

endclass : set_config_test


class incr_payload_test extends base_test;

	`uvm_component_utils(incr_payload_test)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		uvm_config_wrapper::set(this, "route.env.agent.sequencer.run_phase",
                                   "default_sequence",
                                   yapp_incr_payload_seq::type_id::get());
		set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
		super.build_phase(phase);
	endfunction : build_phase

endclass : incr_payload_test


class exhaustive_seq_test extends base_test;

	`uvm_component_utils(exhaustive_seq_test)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		uvm_config_wrapper::set(this, "route.env.agent.sequencer.run_phase",
                                   "default_sequence",
                                   yapp_exhaustive_seq::type_id::get());
		set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
		super.build_phase(phase);
	endfunction : build_phase

endclass : exhaustive_seq_test


class router_dut_test extends base_test;

	`uvm_component_utils(router_dut_test)

	function new(string name, uvm_component parent);
			super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		uvm_config_wrapper::set(this, "route.env.agent.sequencer.run_phase",
                                   "default_sequence",
                                   yapp_012_seq::type_id::get());
		super.build_phase(phase);
	endfunction : build_phase

endclass : router_dut_test