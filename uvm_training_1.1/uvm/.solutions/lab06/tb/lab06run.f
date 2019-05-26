
//-----------------------------------------------
// UVM run file for lab06
------------------------------------------------
-uvmhome $UVMHOME

// include directories, starting with UVM src directory
-incdir ../sv

// options
+UVM_VERBOSITY=UVM_HIGH 
+UVM_TESTNAME=short_yapp_012
//+UVM_TESTNAME=incr_payload_test
//+UVM_TESTNAME=short_packet_test
//+UVM_TESTNAME=exhaustive_seq_test
//+SVSEED=random 

// uncomment for gui
//-gui
//+access+rwc

// default timescale
-timescale 1ns/100ps 

// compile files
// UVC package
../sv/yapp_pkg.sv

// UVC interfaces
../sv/yapp_if.sv 

//top_no_dut.sv

../../router_rtl/yapp_router.v
top_dut.sv
