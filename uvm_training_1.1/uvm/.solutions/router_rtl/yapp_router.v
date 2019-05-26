/*-----------------------------------------------------------------
File name     : yapp_router.v
Developers    : Kathleen Meade, Brian Dickinson
Created       : 23 Jun 2009
Description   : YAPP Router RTL model
Notes         : New version properly drops packets with extra debug reporting
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

//****                                                                ****
//****                         waveforms                              ****
//****                                                                ****
//
//                _   _   _   _   _   _   _   _   _   _   _   _   _   _   
//clock ...... : | |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_ 
//               :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
//                ___________________             _______________
//in_data_vld  : /                   \___________/               \___________
//               :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   
//                                        ___                         ___
//error....... : ________________________/   \_______________________/   \___
//               :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
//                ___ ___ __...__ ___ ___         ___ ___ __...__ ___
//in_data .... : X_H_X_D_X__...__X_D_X_P_>_______<_H_X_D_X__...__X_P_>_______
//               :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
//                _______________________         ___________________
//packet ..... : <______packet_0_________>-------<______packet_1_____>-------
//               :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
//
//H = Header
//D = Data
//P = Parity
// 
// the router assert data_vld_x  when valid data appears in channel queue x
// assert input read_enb_x to read packets from the queue.
// receiver must keep track of packet extent and size.
// error is asserted if parity error is detected at the end of packet reception 
//
//****************************************************************************/
`timescale 1ns/100ps 

  module host_ctl (input clock,
              input reset,
              input wr_rd,
              input en,
              input [7:0] addr,
              inout [7:0] data,
              output en_out,
              output [7:0] max_pkt_size_out);

   parameter   DEF_MAX_PKT = 8'h3F;
   parameter   DEF_EN = 1'b1;
   //parameter   DEF_EN = 1'b0;   //KAM - For Training
   
   //internal registers
   reg [7:0]   max_pkt_reg;
   reg         enable_reg;

   //internal data bus
   reg [7:0]   int_data;

   //continuous assignments
   assign max_pkt_size_out = max_pkt_reg;
   assign en_out = enable_reg;
   assign data = int_data;

   always @(negedge clock or posedge reset) begin
     if (reset) begin
       max_pkt_reg = DEF_MAX_PKT;
       enable_reg =  DEF_EN;
       int_data = 8'h00;
     end
     else if (!en)   
         int_data = 8'hZZ;
     else if (en ) begin
       case (wr_rd) 
         0 : begin //read
             case (addr) 
               8'h00: int_data = max_pkt_reg;
               8'h01: int_data = {7'h00 , enable_reg};
               default: int_data = 8'hZZ;
             endcase // case(addr)
             end
         1 : begin //write
             case (addr) 
               8'h00: max_pkt_reg = data;
               8'h01: enable_reg = data[0];
             endcase // case(addr)
             end
       endcase // case(wr_rd)
      end // if (en)
   end // always @ (posedge clock)
endmodule // host_ctl
   
module fifo (input clock,   
             input reset,
             input write_enb, 
             input read_enb,  
             input [7:0] in_data,  
             output reg [7:0] data_out,  
             output empty,   
             output almost_empty,   
             output full);

// Internal Signals
   reg [7:0] ram[0:15];   // FIFO Memory
   reg       tmp_empty;
   reg       tmp_full;
   reg [3:0] write_ptr; 
   reg [3:0] read_ptr; 

// Continuous assignments
   assign empty = tmp_empty;
   assign almost_empty = (write_ptr == read_ptr + 4'b1) && !write_enb;
   assign full  = tmp_full;
//   assign data_out = ram[read_ptr];

always @(posedge clock) begin
   data_out <= ram[read_ptr];
end

// Processes 

   always @(negedge clock or posedge reset )
   if (reset) begin
      write_ptr <= 0; 
      tmp_full <= 1'b0;
      tmp_empty <= 1'b1;
      write_ptr <= 4'b0;
      read_ptr <= 4'b0;
   end
   else begin : fifo_core
     // Read and Write at the same time when empty
     if ((read_enb == 1'b1) && (write_enb == 1'b1) && (tmp_empty == 1'b1)) begin
       ram[write_ptr] <= in_data;
       write_ptr <= (write_ptr + 4'b1);
       tmp_empty <= 0;
     end
     // Read and Write at the same time when not empty
     else if ((read_enb == 1'b1) && (write_enb == 1'b1) && (tmp_empty == 1'b0)) begin
       ram[write_ptr] <= in_data;
       read_ptr <= (read_ptr + 4'b1);
       write_ptr <= (write_ptr + 4'b1);
     end
     // Write
     else if (write_enb == 1'b1) begin
       tmp_empty <= 1'b0;
       if (tmp_full == 1'b0) begin
         ram[write_ptr] <= in_data;
         write_ptr <= (write_ptr + 4'b1);
       end
       if ((read_ptr == write_ptr + 4'b1) && (read_enb == 1'b0)) begin
         tmp_full <= 1'b1;
       end
     end
     // Read
     else if (read_enb == 1'b1) begin
       if (tmp_empty == 1'b0) begin
         read_ptr <= (read_ptr + 4'b1);
       end
       if ((tmp_full == 1'b1) && (write_enb == 1'b0)) begin
         tmp_full <= 1'b0;
       end
       if ((write_ptr == read_ptr + 4'b1) && (write_enb == 1'b0)) begin
         tmp_empty <= 1'b1;
       end
     end
   end

endmodule //fifo

//****************************************************************************/

`define HEADER_WAIT  2'b00
`define DATA_LOAD    2'b01
`define DUMP_PKT     2'b10

module port_fsm (//FSM Control Signals
                 input clock,       
                 input reset,
                 input hold,        
                 input fifo_empty,    
                 output reg   error,

                 // Host Interface Registers
                 input router_enable,
                 input [7:0] max_pkt_size,

                 // Input Port Data
                 input  [7:0] in_data,      
                 input  in_data_vld,    
                 output in_suspend, 

                 // Output Port Data
                 output     [1:0] addr,
                 output     [7:0] chan_data,
                 output     [2:0] write_enb);     
                
// Internal Signals
reg    [2:0] write_enb_r;
reg          fsm_write_enb;
reg    [1:0] state_r, state;
reg    [7:0] parity;
reg          sus_data_in;
reg    [1:0] dest_chan_r;

//Continuous Assignments
  assign in_suspend = sus_data_in;
  wire [1:0] dest_chan = ((state_r == `HEADER_WAIT) && (in_data_vld == 1'b1)) ? in_data : dest_chan_r;
  assign addr = dest_chan;

  wire chan0 = dest_chan == 2'b00 ? 1'b1 : 1'b0;
  wire chan1 = dest_chan == 2'b01 ? 1'b1 : 1'b0;
  wire chan2 = dest_chan == 2'b10 ? 1'b1 : 1'b0;

  assign chan_data = in_data;
  assign write_enb[0] = chan0 & fsm_write_enb;
  assign write_enb[1] = chan1 & fsm_write_enb;
  assign write_enb[2] = chan2 & fsm_write_enb;

  wire header_valid = (state_r == `HEADER_WAIT) && (in_data_vld == 1'b1);

  always @(negedge clock or posedge reset) 
  begin : fsm_state
    if (reset) begin 
      state_r <= `HEADER_WAIT;
      dest_chan_r <= 2'b00;
    end
    else begin
      state_r <= state;
      if ((state_r == `HEADER_WAIT) && (in_data_vld == 1'b1))
        dest_chan_r <= in_data[1:0];
    end
  end //fsm_state;

  always @(state_r or in_data_vld or in_data or max_pkt_size or fifo_empty or hold) 
  begin
      state = state_r;   //Default state assignment
      sus_data_in = 1'b0;
      fsm_write_enb = 1'b0;
      case (state_r) 
      `HEADER_WAIT : begin
                      sus_data_in = !fifo_empty && in_data_vld;
                      if (in_data_vld == 1'b0) 
                        state = `HEADER_WAIT;      // stay in state if data not valid
                      else if (in_data[1:0] == 2'b11) begin
                        state = `DUMP_PKT;         // invalid address, dump packet
                        $display("ROUTER DROPS PACKET - ADDRESS is %0d",in_data[1:0]);
                        end
                      else if ((in_data[7:2] > max_pkt_size[5:0]) || (in_data[7:2] < 1)) begin		// error length
                        state = `DUMP_PKT;      // invalid length, dump packet
                        $display("ROUTER DROPS PACKET - LENGTH is %0d, MAX is %0d",in_data[7:2],max_pkt_size[5:0]);
                        end
                      else if (fifo_empty == 1'b1) begin
                        state = `DATA_LOAD;     // load good packet
                        fsm_write_enb = 1'b1;
                        end
                      else
                        state = `HEADER_WAIT;  // input suspended, fifo not empty - stay in state
                    end // case: HEADER_WAIT
             
        `DUMP_PKT  : begin
                       if (in_data_vld == 1'b0)
                           state = `HEADER_WAIT;
                     end
        `DATA_LOAD : begin
                       sus_data_in = hold;
//                       sus_data_in = hold && in_data_vld;
                       if (in_data_vld == 1'b0) begin
                         state = `HEADER_WAIT;
                         fsm_write_enb = 1'b1;
                       end
                       else begin
                         fsm_write_enb = !hold;
                       end
                     end // case: DATA_LOAD
         default: state = `HEADER_WAIT;
  
       endcase
  end //fsm_core

  always @(negedge clock or posedge reset)
  begin
    if (reset) begin : parity_calc
       parity <= 8'b0000_0000;
       error <=1'b0;
    end
    else begin
      if ((in_data_vld == 1'b1) && (sus_data_in == 1'b0)) begin
        error <= 1'b0;
        parity <= parity ^ in_data;
      end
      else if (in_data_vld == 1'b0) begin
        if ((state_r == `DATA_LOAD) && (parity != in_data)) begin
          error <= 1'b1;
          $display("*** ROUTER (DUT) Parity Error Identified: Expected:%h Computed:%h ***", in_data, parity);
        end
        parity <= 8'b0000_0000;
      end
      else begin
          error <= 1'b0;
      end //if  
    end
  end //parity_calc;

endmodule //port_fsm

//****************************************************************************/

module yapp_router (input clock,                              
                    input reset,                            
                    output error,

                    // Input channel
                    input [7:0] in_data,                           
                    input in_data_vld,                     
                    output in_suspend,

                    // Output Channels
                    output [7:0] data_0,  //Channel 0
                    output reg data_vld_0, 
                    input suspend_0, 
                    output [7:0] data_1,  //Channel 1
                    output reg data_vld_1, 
                    input suspend_1, 
                    output [7:0] data_2,  //Channel 2
                    output reg data_vld_2,
                    input suspend_2,
     
                    // Host Interface Signals
                    input [7:0] haddr,
                    inout [7:0] hdata,
                    input hen,
                    input hwr_rd);                            

// Internal Signals
wire     full_0;
wire     full_1;
wire     full_2;
wire     empty_0;
wire     empty_1;
wire     empty_2;
wire     almost_empty_0;
wire     almost_empty_1;
wire     almost_empty_2;
wire     fifo_empty;
wire     fifo_empty0;
wire     fifo_empty1;
wire     fifo_empty2;
wire     hold_0;
wire     hold_1;
wire     hold_2;
wire     hold;
wire   [2:0] write_enb;
wire   [1:0] addr;
wire      router_enable;
wire [7:0] max_pkt_size;
wire [7:0] chan_data;

// Continuous Assignments
always @(posedge clock or posedge reset) begin
  if (reset) begin
    data_vld_0 <= 1'b0;
    data_vld_1 <= 1'b0;
    data_vld_2 <= 1'b0;
  end
  else begin
    data_vld_0 <= !empty_0 && !almost_empty_0;
    data_vld_1 <= !empty_1 && !almost_empty_1;
    data_vld_2 <= !empty_2 && !almost_empty_2;
  end
end
  
  assign fifo_empty0 = (empty_0 | ( addr[1] |  addr[0]));     //addr!=00
  assign fifo_empty1 = (empty_1 | ( addr[1] | !addr[0]));     //addr!=01
  assign fifo_empty2 = (empty_2 | (!addr[1] |  addr[0]));     //addr!=10

  assign fifo_empty  = fifo_empty0 & fifo_empty1 & fifo_empty2;

  assign hold_0 = (full_0 & (!addr[1] & !addr[0]));   //addr=00
  assign hold_1 = (full_1 & (!addr[1] &  addr[0]));   //addr=01
  assign hold_2 = (full_2 & ( addr[1] & !addr[0]));   //addr=10
        
  assign hold   = hold_0 | hold_1 | hold_2;

//Host Interface Instance
  host_ctl hif_0 (.clock (clock),
                  .reset (reset),
                  .addr  (haddr),
                  .data  (hdata),
                  .en    (hen),
                  .wr_rd (hwr_rd),
                  .en_out (router_enable),
                  .max_pkt_size_out (max_pkt_size));
   
//Input Port FSM
  port_fsm in_port (.clock         (clock),          
                    .reset         (reset),
                    .in_suspend    (in_suspend),
                    .error         (error),            
                    .write_enb     (write_enb),      
                    .fifo_empty    (fifo_empty),     
                    .hold          (hold),           
                    .in_data_vld   (in_data_vld),   
                    .in_data       (in_data),        
                    .addr          (addr),
                    .chan_data     (chan_data),
                    .router_enable (router_enable),
                    .max_pkt_size  (max_pkt_size));
   
// Output Channels: 0, 1, 2
  fifo queue_0 (.clock     (clock),
                .reset     (reset),
                .write_enb (write_enb[0]),
                .read_enb  (!suspend_0),
                .in_data   (chan_data),
                .data_out  (data_0),
                .empty     (empty_0),
                .almost_empty (almost_empty_0),
                .full      (full_0));

  fifo queue_1 (.clock     (clock),
                .reset     (reset),
                .write_enb (write_enb[1]),
                .read_enb  (!suspend_1),
                .in_data   (chan_data),
                .data_out  (data_1),
                .empty     (empty_1),
                .almost_empty (almost_empty_1),
                .full      (full_1));

  fifo queue_2 (.clock     (clock),
                .reset     (reset),
                .write_enb (write_enb[2]),
                .read_enb  (!suspend_2),
                .in_data   (chan_data),
                .data_out  (data_2),
                .empty     (empty_2),
                .almost_empty (almost_empty_2),
                .full      (full_2));

endmodule //yapp_router
