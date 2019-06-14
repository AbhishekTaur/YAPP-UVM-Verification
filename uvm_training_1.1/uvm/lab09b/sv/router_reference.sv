class router_reference extends uvm_component;

	`uvm_component_utils(router_reference)

	`uvm_analysis_imp_decl(_yapp)
	`uvm_analysis_imp_decl(_hbus)

	uvm_analysis_imp_yapp #(yapp_packet, router_reference) yapp_in;
	uvm_analysis_imp_hbus #(hbus_transaction, router_reference) hbus_in;

	uvm_analysis_port #(yapp_packet) sb_add_out;

	// Configuration Information
   	bit [7:0] max_pktsize_reg = 8'h3F;
   	bit [7:0] router_enable_reg = 1'b1;

	int packets_dropped, bad_addr_packets, packets_forwarded, jumbo_packets;

	function new(string name="", uvm_component parent=null);
		super.new(name, parent);
		yapp_in = new("yapp_in", this);
		hbus_in = new("hbus_in", this);

		// TLM Connections to the Scoreboard
    	sb_add_out    = new("sb_add_out", this);
	endfunction : new

	virtual function void write_hbus(hbus_transaction hbus_packet);
		hbus_transaction packet;

		`uvm_info(get_type_name(), $sformatf("Received HBUS Transaction: \n%s", hbus_packet.sprint()), UVM_MEDIUM)

		$cast(packet, hbus_packet.clone());
		case(packet.haddr)
			'h00: max_pktsize_reg = packet.hdata;
			'h01: router_enable_reg = packet.hdata;
		endcase

	endfunction : write_hbus

	virtual function void write_yapp(yapp_packet packet);
		yapp_packet sb_packet;
		`uvm_info(get_type_name(), $sformatf("Received Input YAPP Packet: \n%s", packet.sprint()), UVM_LOW)
		// Make a copy for storing in the scoreboard
		$cast( sb_packet,  packet.clone());  // Clone returns uvm_object type

		if (packet.addr == 3) begin
			bad_addr_packets++;
			packets_dropped++;
			`uvm_info(get_type_name(), "YAPP Packet Dropped [BAD ADDRESS]", UVM_LOW)
		end
		else if ((router_enable_reg != 0) && (packet.length <= max_pktsize_reg)) begin
			// Send packet to Scoreboard via TLM port
			sb_add_out.write(packet);
			packets_forwarded++;
			`uvm_info(get_type_name(), "Sent YAPP Packet to Scoreboard", UVM_LOW)
		end
		else if ((router_enable_reg != 0) && (packet.length > max_pktsize_reg)) begin
			jumbo_packets++;
			packets_dropped++;
			`uvm_info(get_type_name(), "YAPP Packet Dropped [OVERSIZED]", UVM_LOW)
		end
		else if (router_enable_reg == 0) begin
			packets_dropped++;
			`uvm_info(get_type_name(), "YAPP Packet Dropped [DISABLED]", UVM_LOW)
		end
    endfunction

	function void report_phase(uvm_phase phase);
		`uvm_info(get_type_name(), $sformatf("Report:\n   Router Reference: Packet Statistics \n     Packets Dropped:   %0d\n     Packets Forwarded: %0d\n     Oversized Packets: %0d\n", packets_dropped, packets_forwarded, jumbo_packets ), UVM_LOW)
	endfunction : report_phase

endclass : router_reference