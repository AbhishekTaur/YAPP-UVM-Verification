class router_virtual_sequencer extends uvm_sequencer;

	`uvm_component_utils(router_virtual_sequencer)

	yapp_tx_sequencer yapp_sequencer;
	hbus_master_sequencer hbus_sequencer;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : router_virtual_sequencer