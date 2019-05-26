module top;
  timeunit 1ns;
  timeprecision 100ps;
  import packet_classes::*;
 
  bit clk;
  bit reset = 1'b1;

  // function to derive packet type from target value
  function string derive_type(input logic[3:0] target);
    // deal with x & all-0 first
    if (^target === 1'bX) return "unknown-x";
    else if (|target == 0) return "unknown-0";
    else
      case (target)
        4'b1111 : return "broadcast"; 
        4'b0001,
        4'b0010,
        4'b0100,
        4'b1000 : return "single"; 
        default : return "multicast"; 
      endcase
  endfunction

  always
    #10 clk <= ~clk;

  port_if port0(clk,reset);
  port_if port1(clk,reset);
  port_if port2(clk,reset);
  port_if port3(clk,reset);

  switch_port sw1 (.port0, .port1, .port2, .port3, .clk, .reset);

  packet pkt, pkt0, pkt1, pkt2, pkt3;
  
    assign port1.valid_ip = 1'b0;
    assign port2.valid_ip = 1'b0;
    assign port3.valid_ip = 1'b0;
    
   initial begin
    $timeformat(-9,2," ns",8);
    @(negedge clk);
    reset = 1'b0;
    repeat (2)
    @(negedge clk);
    reset = 1'b1;
    end
    
    initial begin : run
      @(negedge reset);
      @(posedge reset);
      #1000;
      $finish;
    end
    
  initial begin : port0_drive
      port0.valid_ip = 1'b0;
      @(posedge reset);
      @(negedge clk);
     // packet generation 
      pkt = new("pkt",0);
      pkt.data = 8'ha5;
      pkt.ptype = "broadcast";
      pkt.target = 4'hf;
     // end packet generation
     // packet drive
      @(negedge clk iff port0.suspend_ip == 0);
      port0.data_ip =  {pkt.data, pkt.source, pkt.target};
      port0.valid_ip = 1'b1;
     $display("pkt in port 0 @%t",$time);
      pkt.print();
      @(negedge clk iff port0.suspend_ip == 0);
      port0.valid_ip = 1'b0;
      repeat (2) @(negedge clk);
    // end packet drive
    #1000;
    $finish;
  end

 initial begin : port0_monitor
   port0.suspend_op = 1'b0;
   forever begin
     @(posedge port0.valid_op)
     pkt0 = new("pkt",0);
    {pkt0.data, pkt0.source, pkt0.target} = port0.data_op;
    pkt0.ptype = derive_type(pkt0.target);
     $display("pkt out port 0 @%t",$time);
     pkt0.print();
    end 
 end

   
 initial begin : port1_monitor
   port1.suspend_op = 1'b0;
   forever begin
     @(posedge port1.valid_op)
     pkt1 = new("pkt",1);
     {pkt1.data, pkt1.source, pkt1.target} = port1.data_op;
     pkt1.ptype = derive_type(pkt1.target);
     $display("pkt out port 1 @%t",$time);
     pkt1.print();
    end 
 end
   
 initial begin : port2_monitor
   port2.suspend_op = 1'b0;
   forever begin
     @(posedge port2.valid_op)
     pkt2 = new("pkt",2);
     {pkt2.data, pkt2.source, pkt2.target} = port2.data_op;
     pkt2.ptype = derive_type(pkt2.target);
     $display("pkt out port 2 @%t",$time);
     pkt2.print();
    end 
 end
   
 initial begin : port3_monitor
   port3.suspend_op = 1'b0;
   forever begin
     @(posedge port3.valid_op)
     pkt3 = new("pkt",3);
     {pkt3.data, pkt3.source, pkt3.target} = port3.data_op;
     pkt3.ptype = derive_type(pkt3.target);
     $display("pkt out port 3 @%t",$time);
     pkt3.print();
    end 
 end
   
endmodule
