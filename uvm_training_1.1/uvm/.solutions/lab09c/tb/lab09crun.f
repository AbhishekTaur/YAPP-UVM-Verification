
//-----------------------------------------------
// UVM run file for lab09B
//------------------------------------------------

-uvmhome $UVMHOME

// options
+UVM_VERBOSITY=UVM_LOW 
+UVM_TESTNAME=simple_vtest 

// default timescale
-timescale 1ns/100ps 

// include directories
-incdir ../sv
-incdir ../../yapp/sv 
-incdir ../../channel/sv
-incdir  ../../hbus/sv 
-incdir ../../router/sv

// compile files

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
../../router/sv/router_module_pkg.sv

// router DUT
../../router_rtl/yapp_router.v 
top_dut.sv

