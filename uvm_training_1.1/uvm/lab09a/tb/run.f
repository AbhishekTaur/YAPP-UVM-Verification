//-----------------------------------------------
// UVM run file for lab01
//------------------------------------------------
-uvmhome $UVMHOME
// include directories, starting with UVM src directory
-incdir ../../yapp/sv 
-incdir ../../channel/sv
-incdir  ../../hbus/sv 

// compile files
+SVSEED=random
//+UVM_TESTNAME=set_config_test
//+UVM_TESTNAME=incr_payload_test
//+UVM_TESTNAME=exhaustive_seq_test
//+UVM_TESTNAME=router_dut_test
//+UVM_TESTNAME=simple_test
+UVM_TESTNAME=virtual_seq_test
+UVM_VERBOSITY=UVM_LOW

//-gui
//+access+rwc

// default timescale
-timescale 1ns/100ps 

// compile files
// UVC package
// YAPP UVC package and interface
../../yapp/sv/yapp_pkt_pkg.sv 
../../yapp/sv/yapp_pkg.sv
../../yapp/sv/yapp_if.sv 

// Channel UVC package and interface
../../channel/sv/channel_pkg.sv 
../../channel/sv/channel_if.sv 

// HBUS UVC package and interface
../../hbus/sv/hbus_pkg.sv 
../../hbus/sv/hbus_if.sv 

// router DUT
../../router_rtl/yapp_router.v 
top_dut.sv