
/*-----------------------------------------------
 IUS release without embedded UVM library,
 using library supplied with lab files.
------------------------------------------------*/
-uvmhome $UVMHOME

// include directories, starting with UVM src directory
-incdir ../sv

// uncomment for gui
//-gui
//+access+rwc

// default timescale
-timescale 1ns/100ps

// options
+UVM_VERBOSITY=UVM_NONE 
//+UVM_TESTNAME=hbus_write_read_test
+UVM_TESTNAME=hbus_master_topology

// compile files
// starting with UVM package and dpi files
$UVMHOME/src/dpi/uvm_dpi.cc
../sv/hbus_pkg.sv
../sv/hbus_if.sv 
demo_top.sv
