// four pds_vc's - one for each switch port
 
module top;
  import packet_classes::*;
  import vcclasses::*;
 
  pds_vc p0,p1,p2,p3;
    
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
      p0 = new("p0");
      p1 = new("p1");
      p2 = new("p2");
      p3 = new("p3");
      p0.configure(port0, 0);
      p1.configure(port1, 1);
      p2.configure(port2, 2);
      p3.configure(port3, 3);
      p0.setpolicy(BROADCAST);
      p1.setpolicy(BROADCAST);
      p2.setpolicy(BROADCAST);
      p3.setpolicy(BROADCAST);
      fork
        p0.run(1);
        p1.run(1);
        p2.run(1);
        p3.run(1);
      join
      #2000;
      $finish;
    end
    
endmodule

