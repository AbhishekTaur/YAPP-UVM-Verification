//-----------------------------------------------
// UVM run file for lab01
//------------------------------------------------
-uvmhome $UVMHOME
// include directories, starting with UVM src directory
-incdir ../sv

// compile files
+SVSEED=random
//+UVM_TESTNAME=set_config_test
//+UVM_TESTNAME=incr_payload_test
//+UVM_TESTNAME=exhaustive_seq_test
+UVM_TESTNAME=router_dut_test
+UVM_VERBOSITY=UVM_FULL

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