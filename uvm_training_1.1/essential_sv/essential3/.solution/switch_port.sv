module switch_port ( port_if.sw port0, port1, port2, port3,
                input logic clk, reset);

  // switchring data 
  typedef logic [19:0] switchdata_t;

  bit debug = 0;

  // switchring unpacked array of pkts
  switchdata_t switchring [3:0];

  // input & output port FIFO's
  switchdata_t qin_zero [$:4];
  switchdata_t qin_one [$:4];
  switchdata_t qin_two [$:4];
  switchdata_t qin_three [$:4];
  switchdata_t qout_zero [$:4];
  switchdata_t qout_one [$:4];
  switchdata_t qout_two [$:4];
  switchdata_t qout_three [$:4];

  typedef enum {check, shift} state_t;
  state_t state;
  
  int packets_out, packets_in, packets_dropped;

 // loading from input ports
 always@(posedge clk iff port0.valid_ip == 1'b1)
   begin: port0_load
   qin_zero.push_back({port0.data_ip, port0.data_ip[3:0]});
   if (debug) $display("SWITCH: pkt in switch port 0 %h", port0.data_ip);
   packets_in++;
   end

 always@(posedge clk)
   begin: sus_check
   if (qin_zero.size() >= 4) begin
     port0.suspend_ip = 1'b1;
     $display("port0 input suspended");
   end
   else
     port0.suspend_ip = 1'b0;
   end
   
 always@(posedge clk iff port1.valid_ip == 1'b1)
   begin: port1_load
   qin_one.push_back({port1.data_ip, port1.data_ip[3:0]});
   if (debug) $display("SWITCH: pkt in switch port 1 %h", port1.data_ip);
   packets_in++;
   end

 assign port1.suspend_ip = (qin_one.size() >= 4);

 always@(posedge clk iff port2.valid_ip == 1'b1)
   begin: port2_load
   qin_two.push_back({port2.data_ip, port2.data_ip[3:0]});
   if (debug) $display("SWITCH: pkt in switch port 2 %h", port2.data_ip);
   packets_in++;
   end

 assign port2.suspend_ip = (qin_two.size() >= 4);

 always@(posedge clk iff port3.valid_ip == 1'b1)
   begin: port3_load
   qin_three.push_back({port3.data_ip, port3.data_ip[3:0]});
   if (debug) $display("SWITCH: pkt in switch port 3 %h", port3.data_ip);
   packets_in++;
   end

 assign port3.suspend_ip = (qin_three.size() >= 4);

 always
   begin: port0_unload
   port0.valid_op = 1'b0;
   @(posedge clk iff (qout_zero.size()> 0));
   wait (port0.suspend_op == 0);
   port0.data_op = qout_zero.pop_front();      
   port0.valid_op = 1'b1;
   if (debug) $display("SWITCH: pkt out switch port 0 %h @ %0d", port0.data_op, $time);
   packets_out++;
   @(posedge clk);
   end
   
 always
   begin: port1_unload
   port1.valid_op = 1'b0;
   @(posedge clk iff (qout_one.size()> 0));
   wait (port1.suspend_op == 0);
   port1.data_op = qout_one.pop_front();      
   port1.valid_op = 1'b1;
   if (debug) $display("SWITCH: pkt out switch port 1 %h @ %0d", port1.data_op, $time);
   packets_out++;
   @(posedge clk);
   end
   
 always
   begin: port2_unload
   port2.valid_op = 1'b0;
   @(posedge clk iff (qout_two.size()> 0))
   wait (port2.suspend_op == 0);
   port2.data_op = qout_two.pop_front();      
   port2.valid_op = 1'b1;
   if (debug) $display("SWITCH: pkt out switch port 2 %h @ %0d", port2.data_op, $time);
   packets_out++;
   @(posedge clk);
   end
   
 always
   begin: port3_unload
   port3.valid_op = 1'b0;
   @(posedge clk iff (qout_three.size()> 0))
   wait (port3.suspend_op == 0);
   port3.data_op = qout_three.pop_front();      
   port3.valid_op = 1'b1;
   if (debug) $display("SWITCH: pkt out switch port 3 %h @ %0d", port3.data_op, $time);
   packets_out++;
   @(posedge clk);
   end
   

   
 always@(posedge clk, negedge reset)
  if (~reset) begin
    switchring = '{default:0};
    state = check;
    end
  else begin
  

  case (state)

  check : begin
          if (switchring[3][3] && (qout_three.size() < 4)) 
            begin
            switchring[3][3] <= 0;
            qout_three.push_back(switchring[3][19:4]);
            end
          if (switchring[2][2] && (qout_two.size() < 4)) 
            begin
            switchring[2][2] <= 0;
            qout_two.push_back(switchring[2][19:4]);
            end
          if (switchring[1][1] && (qout_one.size() < 4)) 
            begin
            switchring[1][1] <= 0;
            qout_one.push_back(switchring[1][19:4]);
            end

          if (switchring[0][0] && (qout_zero.size() < 4)) 
            begin
            switchring[0][0] <= 0;
            qout_zero.push_back(switchring[0][19:4]);
            end
          state <= shift;
          end

  shift : begin
           // switch 3
          if (switchring[0][3:0] != 0)
             switchring[3] <= switchring[0];
           else if (qin_three.size() > 0)
             switchring[3] <= qin_three.pop_front();
           else
             switchring[3] <= 0;
          
          // switch 2
          if (switchring[3][3:0] != 0)
             switchring[2] <= switchring[3];
          else if (qin_two.size() > 0)
             switchring[2] <= qin_two.pop_front();
          else
             switchring[2] <= 0;

          // switch 1
          if (switchring[2][3:0] != 0)
             switchring[1] <= switchring[2];
          else if (qin_one.size() > 0)
             switchring[1] <= qin_one.pop_front();
          else
             switchring[1] <= 0;

          // switch 0
          if (switchring[1][3:0] != 0)
             begin
             switchring[0] <= switchring[1];
             end
          else if (qin_zero.size() > 0)
             switchring[0] <= qin_zero.pop_front();
          else
             switchring[0] <= 0;
        
          state <= check;
          end 

  endcase

 end 


endmodule
         
   
      
     

   
