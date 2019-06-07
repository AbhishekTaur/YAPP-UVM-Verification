//-----------------------------------------------
// UVM run file for lab01
//------------------------------------------------
-uvmhome $UVMHOME
// include directories, starting with UVM src directory
-incdir ../sv

// compile files
+SVSEED=random
+UVM_TESTNAME=set_config_test
+UVM_TESTNAME=short_packet_test
+UVM_VERBOSITY=UVM_HIGH

../sv/yapp_pkg.sv // compile YAPP package
top.sv            // compile top level module