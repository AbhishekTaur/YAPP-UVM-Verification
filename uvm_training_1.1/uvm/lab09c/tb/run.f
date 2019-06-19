//-----------------------------------------------
// UVM run file for lab01
//------------------------------------------------
-uvmhome $UVMHOME

-timescale 1ns/100ps 

// compile files
+SVSEED=random
+UVM_TESTNAME=virtual_seq_test
+UVM_VERBOSITY=UVM_LOW


// include directories, starting with UVM src directory
-incdir ../sv
-incdir ../../yapp/sv 
-incdir ../../channel/sv
-incdir  ../../hbus/sv 

//-gui
//+access+rwc

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

// router module package
../sv/router_module_pkg.sv

// router DUT
../../router_rtl/yapp_router.v 
top_dut.sv