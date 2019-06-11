class router_tb extends uvm_component;

	`uvm_component_utils(router_tb)

	yapp_env env;

	channel_env channel_env0;

	channel_env channel_env1;

	channel_env channel_env2;

	hbus_env hbus;

	router_virtual_sequencer virtual_sequencer;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		set_config_int( "*", "recording_detail", 1);
		super.build_phase(phase);

		env = yapp_env::type_id::create("env", this);

		set_config_int("channel_env*", "has_rx", 1);
		set_config_int("channel_env*", "has_tx", 0);

		channel_env0 = channel_env::type_id::create("channel_env0", this);
		channel_env1 = channel_env::type_id::create("channel_env1", this);
		channel_env2 = channel_env::type_id::create("channel_env2", this);

		set_config_int("hbus", "num_masters", 1);
		set_config_int("hbus", "num_slaves", 0);
		
		hbus = hbus_env::type_id::create("hbus", this);

		virtual_sequencer = router_virtual_sequencer::type_id::create("virtual_sequencer", this);
	endfunction : build_phase

	// UVM connect_phase
  function void connect_phase(uvm_phase phase);
    // Virtual Sequencer Connections
    virtual_sequencer.hbus_sequencer = hbus.masters[0].sequencer;
    virtual_sequencer.yapp_sequencer = env.agent.sequencer;
  endfunction : connect_phase

endclass : router_tb