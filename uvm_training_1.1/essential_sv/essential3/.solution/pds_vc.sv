package vcclasses;
import packet_classes::*;

typedef enum {SINGLE, MULTICAST, BROADCAST} seq_policy_t;

virtual class component_base;
  protected string name;

  function new (input string ainst);
    name = ainst;
  endfunction

  virtual function string getname();
    return name;
  endfunction

  virtual function void print(input pp_t pp);
   $display("base class print placeholder");
  endfunction

endclass

/* 
// component template
class name extends component_base;

  // properties

  function new (input string ainst);
    super.new(ainst);
  endfunction

  // methods

endclass
*/

class stimgen extends component_base;

  int count = 0;
  int portno;
  seq_policy_t sp;

  function new (input string ainst);
    super.new(ainst);
  endfunction

  function void get_next_item(output packet pkt);
    psingle ps;
    pbroadcast pb;
    pmulticast pm;
    string str;
    str.itoa(count);
    case (sp)
     SINGLE    : begin
                 ps = new({"ps",str},portno); 
                 assert(ps.randomize());
                 ps.ptype = "single";
                 pkt = ps;
                 end
     BROADCAST : begin
                 pb = new({"pb",str},portno);
                 assert(pb.randomize());
                 pb.ptype = "broadcast";
                 pkt = pb;
                 end
     MULTICAST : begin
                 pm = new({"pm",str},portno);
                 assert(pm.randomize());
                 pm.ptype = "multicast";
                 pkt = pm;
                 end
     endcase
     $display("packet sent from port %0d @%t", portno, $time);
     pkt.print(HEX);
   endfunction
endclass

class driver extends component_base;
 virtual port_if pif;

 stimgen sref;

 packet pkt;

  function new (input string ainst);
    super.new(ainst);
  endfunction

  task run(input int count);
    repeat(count) begin
      sref.get_next_item(pkt); 
      send_to_dut(pkt);
    end
  endtask

  // protocol specific code to drive pkt to DUT
  task send_to_dut(packet pkt);
    @(negedge pif.clk iff pif.suspend_ip == 0);
    pif.data_ip = {pkt.data, pkt.source, pkt.target};
    pif.valid_ip = 1'b1;
    @(negedge pif.clk iff pif.suspend_ip == 0);
    pif.valid_ip = 1'b0;
    repeat(5)
      @(negedge pif.clk);
  endtask: send_to_dut

endclass

class monitor extends component_base;
 virtual port_if pif;
 int portno;

  function new (input string ainst);
    super.new(ainst);
  endfunction

  task run();
    checkport();
  endtask

 task checkport();
   packet pkt = new("pkt",portno);
   pif.suspend_op = 1'b0;
   forever begin
     @(posedge pif.valid_op);
     {pkt.data, pkt.source, pkt.target} = pif.data_op;
     $display("packet received at port %0d @%t", portno, $time);
     pkt.print(HEX);
   end
   endtask

endclass    

class pds_vc extends component_base;

 driver dd;
 stimgen sg;
 monitor mn;

  function new (input string ainst);
    super.new(ainst);
    dd = new("dd");
    sg = new("sg");
    mn = new("mn");
    dd.sref = sg;
  endfunction

  function void setpolicy (input seq_policy_t sp);
    sg.sp = sp;
  endfunction

 task configure(input virtual port_if ppif,
                         input int pn);
   dd.pif = ppif;
   mn.pif = ppif;
   sg.portno = pn;
   mn.portno = pn;
   fork
     mn.run();
   join_none
 endtask
   
 task run(input int count);
   dd.run(count);
 endtask

endclass
 
endpackage
