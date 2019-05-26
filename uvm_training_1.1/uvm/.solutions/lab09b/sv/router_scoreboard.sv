/*-----------------------------------------------------------------
File name     : router_scoreboard.sv
Developers    : Kathleen Meade
Created       : 01/04/11
Description   : This file implements the router scoreboard for lab09.
              : 
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: router_scoreboard
//
//------------------------------------------------------------------------------
class router_scoreboard extends uvm_scoreboard;

   // TLM Port Declarations
   `uvm_analysis_imp_decl(_yapp)
   `uvm_analysis_imp_decl(_chan0)
   `uvm_analysis_imp_decl(_chan1)
   `uvm_analysis_imp_decl(_chan2)

   uvm_analysis_imp_yapp    #(yapp_packet, router_scoreboard) sb_yapp_in;
   uvm_analysis_imp_chan0 #(yapp_packet, router_scoreboard) sb_chan0;
   uvm_analysis_imp_chan1 #(yapp_packet, router_scoreboard) sb_chan1;
   uvm_analysis_imp_chan2 #(yapp_packet, router_scoreboard) sb_chan2;
   
   // Scoreboard Packet Queues
   yapp_packet sb_queue0[$];
   yapp_packet sb_queue1[$];
   yapp_packet sb_queue2[$];
   
   // Scoreboard Statistics
   int packets_in,  in_dropped;
   int packets_ch0, compare_ch0, miscompare_ch0, dropped_ch0;
   int packets_ch1, compare_ch1, miscompare_ch1, dropped_ch1;
   int packets_ch2, compare_ch2, miscompare_ch2, dropped_ch2;

   // Constructor
   function new(string name="", uvm_component parent=null);
     super.new(name, parent);
     sb_yapp_in = new("sb_yapp_in", this);
     sb_chan0 = new("sb_chan0", this);
     sb_chan1 = new("sb_chan1", this);
     sb_chan2 = new("sb_chan2", this);
   endfunction
      
   `uvm_component_utils(router_scoreboard)

   virtual function void write_yapp(yapp_packet packet);
     yapp_packet sb_packet;
     // Make a copy for storing in the scoreboard
     $cast( sb_packet,  packet.clone());  // Clone returns uvm_object type
     packets_in++;
     case (sb_packet.addr)
        2'b00: begin 
                sb_queue0.push_back(sb_packet);
                `uvm_info(get_type_name(), "Added packet to Scoreboard Queue 0", UVM_HIGH)
               end
        2'b01: begin
                sb_queue1.push_back(sb_packet);
                `uvm_info(get_type_name(), "Added packet to Scoreboard Queue 1", UVM_HIGH)
               end
        2'b10: begin
                sb_queue2.push_back(sb_packet);
                `uvm_info(get_type_name(), "Added packet to Scoreboard Queue 2", UVM_HIGH)
               end
        default: begin
                `uvm_info(get_type_name(), $sformatf("Packet Dropped: Bad Address=%d\n%s",
                                sb_packet.addr, sb_packet.sprint()), UVM_LOW)
                in_dropped++;
               end
     endcase
    endfunction
    
  // Channel 0 Packet Check (write) implementation
    virtual function void write_chan0(yapp_packet packet);
      yapp_packet sb_packet;
      packets_ch0++;
      if( sb_queue0.size() == 0 ) begin
        `uvm_warning(get_type_name(),
        $sformatf("Scoreboard Error [EMPTY]: Received Unexpected Channel_0 Packet!\n%s", packet.sprint()))
        dropped_ch0++;
        return;
      end
      if( packet.compare(sb_queue0[0]) ) begin
        void'(sb_queue0.pop_front());
        `uvm_info(get_type_name(), $sformatf("Scoreboard Compare Match: Channel_0 Packet\n%s", packet.sprint()), UVM_MEDIUM)
        compare_ch0++;
      end
      else begin
        sb_packet = sb_queue0[0];
        `uvm_warning(get_type_name(), $sformatf("Scoreboard Error [MISCOMPARE]: Received Channel_0 Packet:\n%s\nExpected Channel_0 Packet:%s", packet.sprint(), sb_packet.sprint()))
        miscompare_ch0++;
      end
   endfunction
    
  // Channel 1 Packet Check (write) implementation
    virtual function void write_chan1(yapp_packet packet);
      yapp_packet sb_packet;
      packets_ch1++;
      if( sb_queue1.size() == 0 ) begin
        `uvm_warning(get_type_name(),
        $sformatf("Scoreboard Error [EMPTY]: Received Unexpected Channel_1 Packet!\n%s", packet.sprint()))
        dropped_ch1++;
        return;
      end
      if( packet.compare(sb_queue1[0]) ) begin
        void'(sb_queue1.pop_front());
        `uvm_info(get_type_name(), $sformatf("Scoreboard Compare Match: Channel_1 Packet\n%s", packet.sprint()), UVM_MEDIUM)
        compare_ch1++;
      end
      else begin
        sb_packet = sb_queue1[0];
        `uvm_warning(get_type_name(), $sformatf("Scoreboard Error [MISCOMPARE]: Received Channel_1 Packet:\n%s\nExpected Channel_1 Packet:%s", packet.sprint(), sb_packet.sprint()))
        miscompare_ch1++;
      end
   endfunction

  // Channel 2 Packet Check (write) implementation
    virtual function void write_chan2(yapp_packet packet);
      yapp_packet sb_packet;
      packets_ch2++;
      if( sb_queue2.size() == 0 ) begin
        `uvm_warning(get_type_name(),
        $sformatf("Scoreboard Error [EMPTY]: Received Unexpected Channel_2 Packet!\n%s", packet.sprint()))
        dropped_ch2++;
        return;
      end
      if( packet.compare(sb_queue2[0]) ) begin
        void'(sb_queue2.pop_front());
        `uvm_info(get_type_name(), $sformatf("Scoreboard Compare Match: Channel_2 Packet\n%s", packet.sprint()), UVM_MEDIUM)
        compare_ch2++;
      end
      else begin
        sb_packet = sb_queue2[0];
        `uvm_warning(get_type_name(), $sformatf("Scoreboard Error [MISCOMPARE]: Received Channel_2 Packet:\n%s\nExpected Channel_2 Packet:%s", packet.sprint(), sb_packet.sprint()))
        miscompare_ch2++;
      end
   endfunction

// UVM check_phase
function void check_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "Checking Router Scoreboard", UVM_LOW)
  if (sb_queue0.size() || sb_queue1.size() || sb_queue2.size())
  `uvm_warning(get_type_name(), $sformatf("Check:\n\n   WARNING: Router Scoreboard Queue's NOT Empty:\n     Chan 0: %0d\n     Chan 1: %0d\n     Chan 2: %0d\n", sb_queue0.size(), sb_queue1.size(), sb_queue2.size()))
  else
  `uvm_info(get_type_name(), "Check:\n\n   Router Scoreboard Empty!\n", UVM_LOW)
endfunction : check_phase

// UVM report() phase
function void report_phase(uvm_phase phase);
  `uvm_info(get_type_name(), $sformatf("Report:\n\n   Scoreboard: Packet Statistics \n     Packets In:   %0d     Packets Dropped: %0d\n     Channel 0 Total: %0d  Pass: %0d  Miscompare: %0d  Dropped: %0d\n     Channel 1 Total: %0d  Pass: %0d  Miscompare: %0d  Dropped: %0d\n     Channel 2 Total: %0d  Pass: %0d  Miscompare: %0d  Dropped: %0d\n\n", packets_in, in_dropped, packets_ch0, compare_ch0, miscompare_ch0, dropped_ch0, packets_ch1, compare_ch1, miscompare_ch1, dropped_ch1, packets_ch2, compare_ch2, miscompare_ch2, dropped_ch2), UVM_LOW)
endfunction : report_phase

endclass : router_scoreboard
       
