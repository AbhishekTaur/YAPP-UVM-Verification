
//-----------------------------------------------
// UVM run file for lab03
//------------------------------------------------

-uvmhome $UVMHOME

// include directories
-incdir ../sv

// options
+UVM_VERBOSITY=UVM_MEDIUM 
// (un)comment lines to select test
+UVM_TESTNAME=base_test
//+UVM_TESTNAME=test2

// compile files
../sv/yapp_pkg.sv
top.sv
