interface port_if(input bit clk,reset);
  // input port signals
  logic suspend_ip, valid_ip;
  logic [15:0] data_ip;
  // output port signals
  logic suspend_op, valid_op;
  logic [15:0] data_op;

  // clk and reset NOT in modport
  modport sw (input valid_ip, data_ip, suspend_op, 
              output valid_op, data_op, suspend_ip); 
endinterface
