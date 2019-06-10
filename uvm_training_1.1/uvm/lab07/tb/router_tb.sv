class router_tb extends uvm_component;

	`uvm_component_utils(router_tb)

	yapp_env env;


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		set_config_int( "*", "recording_detail", 1);
		super.build_phase(phase);
		env = yapp_env::type_id::create("env", this);
	endfunction : build_phase

endclass : router_tb