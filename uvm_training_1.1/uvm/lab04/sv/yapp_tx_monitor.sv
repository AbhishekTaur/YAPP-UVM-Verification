class yapp_tx_monitor extends uvm_monitor;

	`uvm_component_utils(yapp_tx_monitor)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new


	virtual function void start_of_simulation_phase(uvm_phase phase);
		`uvm_info(get_type_name(), "Inside the yapp_tx_monitor", UVM_HIGH)
	endfunction: start_of_simulation_phase

	virtual task run_phase(uvm_phase phase);
		`uvm_info(get_type_name(), "Inside the tx monitor", UVM_INFO)
	endtask : run_phase


endclass : yapp_tx_monitor