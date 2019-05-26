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
//+UVM_TESTNAME=default_sequence_test
+UVM_TESTNAME=tx_topology
//+UVM_TESTNAME=rx_topology

// compile files
../sv/yapp_pkt_pkg.sv
../sv/channel_if.sv 
demo_top.sv
