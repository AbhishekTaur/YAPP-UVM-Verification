
//-----------------------------------------------
// UVM run file for lab04
//------------------------------------------------
-uvmhome $UVMHOME

// include directories
-incdir ../sv

// options
+UVM_VERBOSITY=UVM_LOW 
// (un)comment lines to select test
+UVM_TESTNAME=short_packet_test
//+UVM_TESTNAME=set_config_test
//+UVM_TESTNAME=test2
//+SVSEED=random 

// compile files
../sv/yapp_pkg.sv
top.sv
