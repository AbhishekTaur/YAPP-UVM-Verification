//-----------------------------------------------
// UVM run file for lab01
//------------------------------------------------
-uvmhome $UVMHOME
// include directories, starting with UVM src directory
-incdir ../sv

// compile files
+SVSEED=random

../sv/yapp_pkg.sv // compile YAPP package
top.sv            // compile top level module