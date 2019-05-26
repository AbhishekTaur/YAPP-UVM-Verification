module test;
//  import my_pkg::*;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class leaf extends uvm_component;
    time delays [string];
    uvm_phase current;

    `uvm_component_utils(leaf)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      delays = '{ "reset":10, "configure":10, "main":20, "shutdown":10};
    endfunction
    task do_phase(uvm_phase phase);
      phase.raise_objection(this, {"executing phase ", phase.get_name()});
      `uvm_info(phase.get_name(), $sformatf("Starting %s (delay: %0t) phase...",phase.get_name(), delays[phase.get_name()]), UVM_LOW)
      #(delays[phase.get_name()]);
      `uvm_info(phase.get_name(), $sformatf("Ending %s phase...",phase.get_name()), UVM_LOW)
      phase.drop_objection(this, {"executing phase ", phase.get_name()});
    endtask
    function void phase_started(uvm_phase phase);
      current = phase;
    endfunction
    task reset_phase(uvm_phase phase);
      do_phase(phase);
    endtask
    task configure_phase(uvm_phase phase);
      do_phase(phase);
    endtask
    task main_phase(uvm_phase phase);
      do_phase(phase);
    endtask
    task shutdown_phase(uvm_phase phase);
      do_phase(phase);
    endtask
  endclass

  class test extends uvm_component;
    leaf leaf1, leaf2;

    uvm_domain domain1, domain2;

    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      time t;
      super.new(name,parent);
      leaf1 = new("leaf1", this);
      leaf2 = new("leaf2", this);

      domain1 = new("domain1");
      domain2 = new("domain2");

      leaf1.set_domain(domain1);
      leaf2.set_domain(domain2);

      foreach(leaf1.delays[i]) begin
        void'(std::randomize(t) with { t inside { [ 5: 25 ] }; } );
        leaf1.delays[i] = t;
      end
      foreach(leaf2.delays[i]) begin
        void'(std::randomize(t) with { t inside { [ 5: 25 ] }; } );
        leaf2.delays[i] = t;
      end
 
      if($test$plusargs("SYNC"))
        domain1.sync(domain2);
    endfunction

    task run_phase(uvm_phase phase);
      uvm_phase rst;
      phase.raise_objection(this, {"executing phase ", phase.get_name()});
      `uvm_info(phase.get_name(), "Starting run phase...", UVM_LOW)
      #25;
      `uvm_info("Jump", "Jumping domain1 back to reset", UVM_LOW);
      rst = domain1.find(uvm_reset_phase::get());
      leaf1.current.jump(rst);
      #20;

      `uvm_info(phase.get_name(), "Ending run phase...", UVM_LOW)
      phase.drop_objection(this, {"executing phase ", phase.get_name()});
    endtask
  endclass

  initial run_test;
endmodule
