package four_packet_classes;
 
  // print policy for formatting packet print
 typedef enum {HEX,BIN,DEC} pp_t;

// base class
virtual class base;
  protected string inst;

  function new (input string ainst);
    inst = ainst;
  endfunction

  virtual function string getname();
    return inst;
  endfunction 

  virtual function void print(input pp_t pp);
   $display("base class print placeholder");
  endfunction 
 
endclass

// packet class
class packet extends base;

  rand logic [3:0] target;
  logic [3:0] source;
  rand logic [7:0] data;
  string ptype;

  // basic constraint (over-ridden for broadcast packet)
  constraint cbasic {|(target & source) != 1'b1;}

  // constructor sets instance string; source and packet type
  function new (input string ainst,
                input int idt);
    super.new(ainst);
    source = 1 << idt;
    ptype = "any";
  endfunction

 // print with policy
  function void print(input pp_t pp = BIN);
    $display("\n----------------------------------");
    $display("%s",gettype()," packet %s",getname());
    case (pp)
      HEX: $display("from %h, to %h, data %h",source,target,data);
      DEC: $display("from %0d, to %0d, data %0d",source,target,data);
      BIN: $display("from %b, to %b, data %b",source,target,data);
    endcase
  endfunction

  // get packet type
  function string gettype();
      return ptype;
  endfunction

  function int compare (input packet ap);
    bit [3:0] res;  // use array and == to protect against x values
    res = 0;
    if (target == ap.target) res[3] = 1;
    if (source == ap.source) res[2] = 1;
    if (data == ap.data) res[1] = 1;
    if (ptype == ap.ptype) res[0] = 1;
    return &res;
   endfunction

  function void clone (output packet ap);
    ap = new(inst,0);
    ap.target = target;
    ap.source = source;
    ap.data = data;
    ap.ptype = ptype;
   endfunction

 
  endclass

// class fourpacket
class fourpacket extends base;

  rand packet pkt[0:3];     

  function new(input string ainst);
    string str;
    super.new(ainst);
    for (int i = 0;i<4;i++) begin
      str.itoa(i);
      pkt[i] = new({ainst,".p",str},i); 
      pkt[i].ptype = "any";
    end
  endfunction

  function void deep_print(input pp_t pp = BIN);
    $display("\n----------------------------------");
    $display("four packet deep print");
    $display("packet %s",getname());
    for (int i = 0;i<4;i++) 
      pkt[i].print(pp);
  endfunction

  function int deep_compare(input fourpacket ac);
    bit res;
    res = 1;
    for (int i = 0;i<4;i++) begin
    res = res && pkt[i].compare(ac.pkt[i]);  
    end
    return res;
  endfunction

  function void deep_clone(output fourpacket ac);
    ac = new(inst);
    for (int i = 0;i<4;i++) 
      pkt[i].clone(ac.pkt[i]);
  endfunction
  
endclass

  // single packet sub-class
  class psingle extends packet;
    constraint csingle {target inside {1,2,4,8};}
    function new(input string ainst,
                input int idt);
      super.new(ainst,idt);
      ptype = "single";
    endfunction
  endclass

  // multicast packet sub-class
  class pmulticast extends packet;
    constraint csingle {target inside {3,[5:7],[9:14]};}
    function new(input string ainst,
                input int idt);
      super.new(ainst,idt);
      ptype = "multicast";
    endfunction
  endclass

  // broadcast packet sub-class
  class pbroadcast extends packet;
    // over-ride basic constraint from packet parent!!
    constraint cbasic {target==15;}
    function new(input string ainst,
                input int idt);
      super.new(ainst,idt);
      ptype = "broadcast";
    endfunction
  endclass

endpackage
