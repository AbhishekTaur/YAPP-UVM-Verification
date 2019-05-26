package packet_classes;
 
// base class
virtual class base;
  protected string inst;

  function new(input string ainst);
    inst = ainst;
  endfunction

  virtual function string getname();
    return inst;
  endfunction 
 
endclass

// define packet class

// define single packet sub-class

// define multicast packet sub-class

// define broadcast packet sub-class

endpackage
