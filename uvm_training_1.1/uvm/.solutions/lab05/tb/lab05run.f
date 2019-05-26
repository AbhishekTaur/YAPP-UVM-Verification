
//-----------------------------------------------
// UVM run file for lab05
//------------------------------------------------
-uvmhome $UVMHOME

// include directories
-incdir ../sv

// options
+UVM_VERBOSITY=UVM_LOW 
// (un)comment lines to select test
//+UVM_TESTNAME=incr_payload_test
//+UVM_TESTNAME=short_packet_test
+UVM_TESTNAME=exhaustive_seq_test
+SVSEED=random 

// compile files
../sv/yapp_pkg.sv
top.sv

