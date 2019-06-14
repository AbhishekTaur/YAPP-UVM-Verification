class router_module_env extends uvm_env;

	`uvm_component_utils(router_module_env)

	router_reference router_ref;

	router_scoreboard router_sb;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		set_config_int( "*", "recording_detail", 1);
		super.build_phase(phase);

		router_sb = router_scoreboard::type_id::create("router_sb", this);
		router_ref = router_reference::type_id::create("router_ref", this);
	endfunction : build_phase

	function void connect_phase(uvm_phase phase);
		router_ref.sb_add_out.connect(router_sb.sb_yapp_in);
	endfunction : connect_phase


endclass : router_module_env