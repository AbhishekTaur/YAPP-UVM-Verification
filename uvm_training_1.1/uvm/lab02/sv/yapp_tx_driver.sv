class yapp_tx_driver extends uvm_driver #(yapp_packet);

	`uvm_component_utils(yapp_tx_driver)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual task run_phase(uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(req);
			send_to_dut(req);
			seq_item_port.item_done();
		end
	endtask : run_phase

	virtual task send_to_dut(yapp_packet pkt);
		`uvm_info(get_type_name(), $sformatf("Packet is \n%s", pkt.sprint()), UVM_LOW)
	endtask: send_to_dut

endclass : yapp_tx_driver