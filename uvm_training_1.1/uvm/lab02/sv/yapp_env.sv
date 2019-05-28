class yapp_env extends uvm_env;

	`uvm_component_utils(yapp_env)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	yapp_tx_agent agent;


	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		agent = new("agent", this);
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		print();
	endtask : run_phase

endclass : yapp_env