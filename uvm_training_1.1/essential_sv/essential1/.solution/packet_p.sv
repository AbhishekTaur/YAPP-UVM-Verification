package packet_classes;
 
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
