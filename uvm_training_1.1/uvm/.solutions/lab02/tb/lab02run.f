//-----------------------------------------------
// UVM run file for lab02
//------------------------------------------------

-uvmhome $UVMHOME

// incdir for include files
-incdir ../sv

// runtime options
+UVM_VERBOSITY=UVM_LOW

// compile files
../sv/yapp_pkg.sv
top.sv

