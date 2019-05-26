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


