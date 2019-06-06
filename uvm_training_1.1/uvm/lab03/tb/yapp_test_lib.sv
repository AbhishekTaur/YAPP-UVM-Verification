class base_test extends uvm_test;

	`uvm_component_utils(base_test)

	yapp_env env;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		uvm_config_wrapper::set(this, "env.agent.sequencer.run_phase",
                                   "default_sequence",
                                   yapp_5_packets::type_id::get());
		super.build_phase(phase);
		env = new("env", this);
	endfunction: build_phase

	virtual function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction: end_of_elaboration_phase

endclass : base_test


class test2 extends base_test;

	`uvm_component_utils(test2)

	function new(string name, uvm_component parent);
    	super.new(name, parent);
  	endfunction : new

endclass: test2