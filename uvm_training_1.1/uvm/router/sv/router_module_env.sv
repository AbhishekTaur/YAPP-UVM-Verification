class router_module_env extends uvm_env;

	`uvm_component_utils(router_module_env)

	router_reference router_ref;

	router_scoreboard router_sb;

	uvm_analysis_export #(yapp_packet) router_yapp;
   	uvm_analysis_export #(hbus_transaction) router_hbus;
   
   	uvm_analysis_export #(yapp_packet) router_chan0;
  	uvm_analysis_export #(yapp_packet) router_chan1;
   	uvm_analysis_export #(yapp_packet) router_chan2;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		router_yapp = new("router_yapp", this);
    	router_hbus = new("router_hbus", this);
    	router_chan0 = new("router_chan0", this);
    	router_chan1 = new("router_chan1", this);
    	router_chan2 = new("router_chan2", this); 
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		set_config_int( "*", "recording_detail", 1);
		super.build_phase(phase);

		router_sb = router_scoreboard::type_id::create("router_sb", this);
		router_ref = router_reference::type_id::create("router_ref", this);
	endfunction : build_phase

	function void connect_phase(uvm_phase phase);
		// hierarchy TLM connections for router module OVC
	    router_hbus.connect(router_ref.hbus_in);
	    router_yapp.connect(router_ref.yapp_in);
	    router_chan0.connect(router_sb.sb_chan0_in);
	    router_chan1.connect(router_sb.sb_chan1_in);
	    router_chan2.connect(router_sb.sb_chan2_in);
		router_ref.sb_add_out.connect(router_sb.sb_yapp_in);
	endfunction : connect_phase


endclass : router_module_env