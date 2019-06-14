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


class simple_test extends base_test;

	`uvm_component_utils(simple_test)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		uvm_config_wrapper::set(this, "route.env.agent.sequencer.run_phase",
                                   "default_sequence",
                                   yapp_012_seq::type_id::get());
		set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
		uvm_config_wrapper::set(this, "route.channel_env?.rx_agent.sequencer.run_phase",
                                   "default_sequence",
                                   channel_rx_resp_seq::type_id::get());
		super.build_phase(phase);
	endfunction : build_phase

endclass : simple_test

class test_ovc_integration extends base_test;

  // component macro
  `uvm_component_utils(test_ovc_integration)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
   yapp_packet::type_id::set_type_override(short_yapp_packet::get_type());
    uvm_config_wrapper::set(this, "route.hbus.masters[0].sequencer.run_phase",
                            "default_sequence",
                            hbus_small_packet_seq::type_id::get());
    uvm_config_wrapper::set(this, "route.env.agent.sequencer.run_phase",
                            "default_sequence",
                            test_ovc_seq::type_id::get());
    uvm_config_wrapper::set(this, "route.channel_env?.rx_agent.sequencer.run_phase",
                            "default_sequence",
                            channel_rx_resp_seq::type_id::get());
    super.build_phase(phase);
  endfunction: build_phase

endclass : test_ovc_integration

class virtual_seq_test extends base_test;

	`uvm_component_utils(virtual_seq_test)

	function new(string name, uvm_component parent);
		super.new(name, parent);

	endfunction : new

	function void build_phase(uvm_phase phase);
		yapp_packet::type_id::set_type_override(short_yapp_packet::get_type());

		uvm_config_wrapper::set(this, "route.virtual_sequencer.run_phase",
                            "default_sequence",
                            router_simple_vseq::type_id::get());
   		uvm_config_wrapper::set(this, "route.channel_env?.rx_agent.sequencer.run_phase",
                            "default_sequence",
                            channel_rx_resp_seq::type_id::get());
    	super.build_phase(phase);

	endfunction : build_phase

endclass : virtual_seq_test