class yapp_tx_agent extends uvm_agent;

	`uvm_component_utils_begin(yapp_tx_agent)
		`uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
	`uvm_component_utils_end

	yapp_tx_monitor monitor;
	yapp_tx_driver driver;
	yapp_tx_sequencer sequencer;

	uvm_active_passive_enum is_active = UVM_ACTIVE;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		monitor = yapp_tx_monitor::type_id::create("monitor", this);
		if(is_active == UVM_ACTIVE) begin
			driver = yapp_tx_driver::type_id::create("driver", this);
			sequencer = yapp_tx_sequencer::type_id::create("sequencer", this);
		end
	endfunction: build_phase

	virtual function void start_of_simulation_phase(uvm_phase phase);
		`uvm_info(get_type_name(), "Inside the yapp_tx_agent", UVM_HIGH)
	endfunction: start_of_simulation_phase

	virtual function void connect_phase(uvm_phase phase);
		if(is_active == UVM_ACTIVE)
			driver.seq_item_port.connect(sequencer.seq_item_export);
	endfunction: connect_phase

endclass : yapp_tx_agent