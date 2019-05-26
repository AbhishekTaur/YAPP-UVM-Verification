catch { rename help ncsim_builtin_help } e

# Generic parameters
set UNDEF        -1

# Verbosity values
set NONE   0
set LOW    100
set MEDIUM 200
set HIGH   300
set FULL   400
set DEBUG  500

set UVM_NONE   $NONE
set UVM_LOW    $LOW
set UVM_MEDIUM $MEDIUM
set UVM_HIGH   $HIGH
set UVM_FULL   $FULL
set UVM_DEBUG  $DEBUG

# Severity values
set INFO    0
set WARNING 1
set ERROR   2
set FATAL   3

set UVM_INFO    $INFO
set UVM_WARNING $WARNING
set UVM_ERROR   $ERROR
set UVM_FATAL   $FATAL

set EMPTY_STRING          {""}

# Action values
set NO_ACTION      0
set DISPLAY        1
set LOG            2
set COUNT          4
set EXIT           8
set CALL_HOOK     16 
set STOP          32

set OVM_NO_ACTION      $NO_ACTION
set OVM_DISPLAY        $DISPLAY
set OVM_LOG            $LOG
set OVM_COUNT          $COUNT
set OVM_EXIT           $EXIT
set OVM_CALL_HOOK      $CALL_HOOK 
set OVM_STOP           $STOP

# Value types for calling sv wrappers
set SET_VERBOSITY 0
set GET_VERBOSITY 1
set SET_ACTIONS   2
set GET_ACTIONS   3
set SET_STYLE     4
set GET_STYLE     5
set SET_SEVERITY  6
set GET_SEVERITY  7
set ANYSET        100

proc isnumber {value} {
  set v [string index $value 0]
  if { $v >= 0 && $v <= 9 } { return 1 }
  if { $v == "'" } { return 1 }
  return 0 
}

proc verbosity_to_value { verbosity } {
  global NONE
  global LOW
  global MEDIUM
  global HIGH
  global FULL 
  global DEBUG 

  if { [regexp {^-} $verbosity] } { return -1 }

  switch "$verbosity" {
    "NONE"   { return $NONE }
    "UVM_NONE"   { return $NONE }
    "LOW"    { return $LOW }
    "UVM_LOW"    { return $LOW }
    "MEDIUM" { return $MEDIUM }
    "UVM_MEDIUM" { return $MEDIUM }
    "HIGH"   { return $HIGH }
    "UVM_HIGH"   { return $HIGH }
    "FULL"   { return $FULL }
    "UVM_FULL"   { return $FULL }
    "DEBUG"   { return $DEBUG }
    "UVM_DEBUG"   { return $DEBUG }
  }
  if { ! [isnumber $verbosity] } { return -1 }
  return "$verbosity"
}

proc uvm_get_result {} {
  set result ""
  if { ! [file exists .uvmtclcomm.txt] } { return "" }
  set fid [open .uvmtclcomm.txt r]
  if { [gets $fid result] != -1 } {
    while { [gets $fid line] != -1 } {
      set result "$result\n$line"
    } 
  }
  return $result
}

proc severity_to_value { severity } {
  global INFO
  global WARNING
  global ERROR
  global FATAL

  switch "$severity" {
    "INFO"    { return $INFO }
    "UVM_INFO"    { return $INFO }
    "WARNING" { return $WARNING }
    "UVM_WARNING" { return $WARNING }
    "ERROR"   { return $ERROR }
    "UVM_ERROR"   { return $ERROR }
    "FATAL"   { return $FATAL }
    "UVM_FATAL"   { return $FATAL }
  }
  return "$severity"
}

proc value_to_verbosity { value } {
  global NONE
  global LOW
  global MEDIUM
  global HIGH
  global FULL 
  global DEBUG 

  if { $value == $NONE } { return "NONE" }
  if { $value == $LOW } { return "LOW" }
  if { $value == $MEDIUM } { return "MEDIUM" }
  if { $value == $HIGH } { return "HIGH" }
  if { $value == $FULL } { return "FULL" }
  if { $value == $DEBUG } { return "DEBUG" }
  return $value
}

proc is_verbosity_value { value } {
  global NONE
  global LOW
  global MEDIUM
  global HIGH
  global FULL 
  global DEBUG 
  set value [verbosity_to_value $value]
  if { ($value == $NONE)   || ($value == $LOW)  ||
       ($value == $MEDIUM) || ($value == $HIGH) ||
       ($value == $FULL)   || ($value == $DEBUG) } {
     return 1
  }
  return 0
}

proc value_to_severity { value } {
  global INFO
  global WARNING
  global ERROR
  global FATAL

  if { $value == $INFO }    { return "INFO" }
  if { $value == $WARNING } { return "WARNING" }
  if { $value == $ERROR }   { return "ERROR" }
  if { $value == $FATAL }   { return "FATAL" }
  return $value
}

proc is_severity_value { value } {
  global INFO
  global WARNING
  global ERROR
  global FATAL

  set value [severity_to_value $value]
  if { ($value == $INFO)  || ($value == $WARNING) ||
       ($value == $ERROR) || ($value == $FATAL) } { 
    return 1
  }
  return 0
}

proc do_command { args } {
  if { [catch { set r [eval $args] } e ] } {
    if { [regexp OBJACC $e] } {
       puts "uvm: *E,UVMACC: UVM commands require read/write access for the verilog functions which implement the commands"
    } else { 
      return -code return $e
    }
    return "command failed"
  }
  return $r
}

proc help args {
  if { [llength $args] == 0 } {
    puts ""
    puts "UVM commands:"
    puts ""
    puts "uvm_component uvm_get   uvm_message uvm_phase   uvm_set     uvm_version"
    puts [ncsim_builtin_help]
    return;
  }
  foreach i $args {
    if { $i == "uvm_component" } {
      puts "uvm_component................Get information on UVM components"
      puts "    -list....................List all UVM components"
      puts "    -tops....................Print top level components"
      puts "    -describe <names>........Print one or more UVM component."
      puts "        <names>..............List of components to describe"
      puts "        -depth <depth>.......The depth of the component hierarchy"
      puts "                             to display (the default is 1). A depth"
      puts "                             of -1 recurses the full hierarchy"
    } elseif { $i == "uvm_get" } {
      puts "uvm_get <name> <field>........Get the value of a variable from a"
      puts "                              component. The component name can"
      puts "                              be a wildcarded name. The field"
      puts "                              must exist in the component."
    } elseif { $i == "uvm_message" } {
     puts "uvm_message...................Access the UVM messaging service. Is currently"
     puts "                              used for getting and setting verbosity values."
     puts "    <verbosity> <comp>........Set the verbosity for a component"
     puts "                              The component may be a wildcard. Verbosity"
     puts "                              may be an integer or an UVM verbosity value."
     puts "    -file <file>..............Specify a file name (currently for e messages"
     puts "                              only)."
     puts "    -get_verbosity <comp>.....Get the verbosity of a specific component."
     puts "                              If more than one component matches the comp"
     puts "                              name, the first value is returned."
     puts "    -hier <comp>..............Explicitly specify the component (glob style"
     puts "                              patterns are used). This argument is optional."
     puts "                              An argument that is not a severity value will"
     puts "                              be taken as the component setting."
     puts "    -tag <tag>................Specify a tag (currently for e messages only)."
     puts "    -text <text>..............Specify a text (currently for e messages only)."
    } elseif { $i == "uvm_phase" } {
      puts "uvm_phase <option>...........Access the phase interface for breaking on "
      puts "                             phases, or executing stop requests on phases."
      puts "                             Phases may be from the common domain (build"
      puts "                             through final) of from the runtime uvm domain"
      puts "                             (pre_reset through post_shutdown)."
      puts "    -delete..................Remove a previously set -stop_at break point."
      puts "    -get.....................Get the name of the current phase. This is the"
      puts "                             default option if no other options are specified."
      puts "    -run <phase name>........Run to the desired phase."
      puts "    -stop_at <options> <phase name> <stop options>"
      puts "                             Set a break point on the specified phase. By"
      puts "                             default, the break will occur at the start of"
      puts "                             the phase. A standard tcl break point (using the"
      puts "                             stop commmand) is issued. All options after the"
      puts "                             phase name are sent to the stop command. Use"
      puts "                             \"help stop\" for a list of options that can be used."
      puts "      -begin.................Set the callback for the beginning of the phase."
      puts "                             This is the default."
      puts "      -build_done............Sets a callback when the primary environment"
      puts "                             build out (from the run_test() command) is"
      puts "                             complete."
      puts "      -end...................Set the callback for the end of the phase."
      puts "    -stop_request............Execute a global stop request for the current"
      puts "                             phase."
    } elseif { $i == "uvm_set" } {
      puts "uvm_set <name> <field> <value>"
      puts "                             Set <field> for unit <name>."
      puts "    -config                  Apply the set to a configuration parameter. This"
      puts "                             means that the setting will not be applied until"
      puts "                             the specified component updates its configuration"
      puts "                             (which normally occurs during build()."
      puts "                             "
      puts "                             If field is 'default_sequence', then the component"
      puts "                             target is assumed to be a <sequencer>.<phase>."
      puts "                             The value is used to find the factory wrapper in"
      puts "                             factory and then the uvm_config_db#"
      puts "                             (uvm_object_wrapper::set() is used to perform"
      puts "                             the setting."
      puts "    -type int | string.......Specify the type of object to set." 
      puts "                             If type is not specified then if value "
      puts "                             is an integral value, int is assumed,"
      puts "                             otherwise string is assumed. For non-config sets"
      puts "                             the field must exist in the component."
    } elseif { $i == "uvm_version" } {
      puts "uvm_version..................Get the UVM library version."
    } else {
      puts [ncsim_builtin_help $i]
    }
  }
}

proc uvm_get args {
  set num [llength $args]
  if { $num < 2 && [lindex $args 0] != "-help" } {
    puts "uvm_get <name> <field>"
    return
  }
  if { $num < 2 && [lindex $args 0] == "-help" } {
    help uvm_get 
    return
  }

  set name [lindex $args 0]
  set field [lindex $args 1]

  for {set i 2} {$i < [llength $args]} {incr i} {
    set value [lindex $args $i]
    if { $value == "-help" } {
      help uvm_get 
      return
    } elseif { [string index $value 0] == "-" } {
      puts "uvm: *E,UNKOPT: unrecognized option for the uvm_get command ($value)."
      return
    } elseif { $value != "" } {
      puts "uvm: *E,UNKOPT: unrecognized option for the uvm_get command ($value)."
      return
    }
  }
  if { [regexp {[*?]} $field ] } {
    puts "uvm: *E,NOWLCD: Wildcard field name, $field, not allowed for uvm_get"
    return
  }

  set comps [uvm_component -describe $name -depth 0]
  if { [regexp {@[0-9]+} $comps comp] } {
    return [do_command value ${comp}.${field}]
  } else {
    puts "uvm: *E,NOMTCH: Did not match any components to $name"
  }
}
proc uvm_set args {
  set num [llength $args]
  if { $num < 3 && [lindex $args 0] != "-help" } {
    puts "uvm_set <name> <field> <value>"
    return
  }
  if { $num < 3 && [lindex $args 0] == "-help" } {
    help uvm_set 
    return
  }

  set name  -1
  set field -1
  set int 0 
  set str 0 
  set config 0
  set v 0

  for {set i 0} {$i < [llength $args]} {incr i} {
    set value [lindex $args $i]
    if { $value == "-help" } {
      help uvm_set 
      return
    } elseif { $value == "-config" } {
      set config 1
    } elseif { $value == "-type" } {
      incr i
      set value [lindex $args $i]
      if { $value == "int" } {
        set int 1
      } elseif { $value == "string" } {
        set str 1
      } else {
        puts "Error: illegal type [lindex $args $i] specifed with -type option"
      }
    } elseif { [string index $value 0] == "-" } {
      puts "uvm: *E,UNKOPT: unrecognized option for the uvm_set command ($value)."
      return
    } else {
      if { $name == -1 } { 
        set name $value 
      } elseif { $field == -1 } {
        set field $value
      } else {
        set v $value
      }
    }
  }
  if { ($name == -1)  || ($field == -1) } {
     puts "uvm: *E,ILLCL: uvm_set requires a unit and a field"
     return
  } 
  if { $int == 0 && $str == 0 } {
    if { [is_verbosity_value $v] } {
      set v [verbosity_to_value $v]
    } elseif { [is_severity_value $v] } {
      set v [severity_to_value $v]
    }
    if { [isnumber $v] } {
      set int 1
      set str 0
    } else {
      set int 0
      set str 1
    }
  }
  if { $int == 0 && $str == 0 } {
    puts "Error: no value given for setting field $field"
    return
  }
  if { $int == 1 && $config == 1} {
    call tcl_uvm_set \"$name\" \"$field\" $v $config
  } elseif { $config == 1} {
    call tcl_uvm_set_string \"$name\" \"$field\" \"$v\" $config
  } else {
    set comps [uvm_component -describe $name -depth 0]
    set cnt 0
    if { [regexp {@[0-9]+} $comps comp] } {
      foreach  i [split $comps] {
        if { [regexp {@[0-9]+} $i comp] } {
          if { $int == 1} {
            if { ! [catch { set r [do_command deposit ${comp}.${field} $v] } e ] } {
              incr cnt  
          }} else {
            if { ! [catch { set r [do_command deposit ${comp}.${field} \"$v\"] } e ] } {
              incr cnt  
          }}
    }}}
    if { $cnt == 0 } {
        puts "uvm: *E,NOMTCH: Did not match any components to $name for field $field"
    }
  }
}

proc uvm_component args {
  set depth "default"
  set ll   0
  set desc 0
  set tops  0
  set names [list]
  set scope [scope]
  if { [llength $args] == 0 } {
    puts "uvm_component <options>"
    return
  } 
  for {set i 0} {$i < [llength $args]} {incr i} {
    set value [lindex $args $i]
    if { $value == "-depth" } {
      incr i
      set depth [lindex $args $i] 
    } elseif { $value  == "-list" } {
      set ll 1
    } elseif { $value  == "-help" } {
      help uvm_component
      return
    } elseif { $value  == "-describe" } {
      set desc 1
    } elseif { $value  == "-tops" } {
      set tops 1
      set desc 1
    } elseif { [string index $value 0] == "-" } {
      puts "uvm: *E,UNKOPT: unrecognized option for the uvm_component command ($value)."
      return
    } else {
      lappend names $value
    }
  }
  if { ("$depth" == "default") && ($tops == 1)} {
    set depth 0
  } elseif {$depth == "default" } {
    set depth 1
  }
  if { $ll == 1 } { 
    call tcl_uvm_list_components 1
    set rval [uvm_get_result]
    scope -set $scope
    if { [llength $names] != 0 } {
      set l {}
      set rl [split $rval "\n"]
      set rl [lrange $rl 1 [ expr [llength $rl] -2] ]
      set nm  [join $names " "]
      foreach i $rl {
        foreach pattern $names {
          if [string match $pattern [lindex [split $i " "] 0] ] { lappend l $i }
      } }
      if { [llength $l] == 0 } {
        set rval "No uvm components match the input name(s): $nm" 
      } else {
        set match [join $l "\n"]
        set rval "List of uvm components matching the input name(s): $nm\n$match"
      }
    }
    return $rval
  } 
  if { $desc == 1 } {
    if { $tops == 1 } {
      call tcl_uvm_print_components $depth 0 1
      set rval [uvm_get_result]
      scope -set $scope
      return $rval
    } else {
      if { [llength $names] == 0 } {
        puts "uvm: *E,ILLOPT: the -describe option requires a component name"
      }
      set rval ""
      foreach name $names {
        call tcl_uvm_print_component \"$name\" $depth 1
        if { $rval != "" } { set rval "$rval\n" }
        set rval "${rval}[uvm_get_result]"
      }
      scope -set $scope
      return $rval
    }
  } elseif { [llength $names] != 0 } {
    puts "uvm: *E,NOACT: no action specified for the components \"$names\""
  } else {
    puts "uvm: *E,ILLOPT: illegal usage of the uvm_component command"
  }
}

proc uvm_message args {
  global UNDEF
  global SET_VERBOSITY
  global GET_VERBOSITY
  global SET_ACTIONS
  global GET_ACTIONS
  global SET_STYLE
  global GET_STYLE
  global SET_SEVERITY
  global GET_SEVERITY
  global ANYSET

  set get 0
  set value -1
  set hier "*"
  set file "*"
  set text_val "*"
  set tag ""

  for {set i 0} {$i < [llength $args]} {incr i} {
    set argvalue [lindex $args $i]
    if { $argvalue  == "-help" } {
      help uvm_message
      return
    } elseif {$argvalue == "-tag" } {
      incr i
      set tag [lindex $args $i]
    } elseif {$argvalue == "-text" } {
      incr i
      set text_val [lindex $args $i]
    } elseif {$argvalue == "-file" } {
      incr i
      set file [lindex $args $i]
    } elseif {$argvalue == "-verbosity" } {
      incr i
      set value [lindex $args $i]
    } elseif {$argvalue == "-get_verbosity" } {
      set get 1
    } elseif {$argvalue == "-set_verbosity" } {
      set get 0
    } elseif {$argvalue == "-hier" } {
      set hier $argvalue
    } elseif { [string index $argvalue 0] == "-" } {
      puts "uvm: *E,UNKOPT: unrecognized option for the uvm_message command ($argvalue)."
      return
    } else {
      if { [is_verbosity_value [verbosity_to_value $argvalue] ] } {
        set value [verbosity_to_value $argvalue]
      } elseif { [isnumber $argvalue] } {
        set value [verbosity_to_value $argvalue]
      } else {
        set hier $argvalue
      }
    }
  }
  if { [llength $args] == 0 } {
     puts "uvm_message \"\" \[-get_verbosity\] [options] <verbosity> <component>"
     return
  } 

 if { $get == 0 } {
    set value_type $SET_VERBOSITY
    call tcl_uvm_set_message $value_type \"$hier\" \"$file\" \"$text_val\" \"$tag\" $value
  } else {
    set value_type $GET_VERBOSITY
    return [tcl_get_message $hier \"\"]
  }
}

set all_breaks("empty") 0
set break_by_name("empty") 0

proc remove_break {b} {
  global break_by_name
  global all_breaks

  if {[info exists break_by_name($b)] == 0} {
    return 0
  }
  unset all_breaks("$break_by_name($b)")
  unset break_by_name($b)
  return 1
}

proc uvm_phase args {
  global UNDEF
  global all_breaks
  global break_by_name

#  set break_phase $UNDEF
  set break_phase $UNDEF
  set run_phase $UNDEF
  set pre 1
  set get $UNDEF
  set stop_req $UNDEF
  set stop_options $UNDEF
  set ph_cmd ""

  if { [llength $args] == 0 } { set get 1 }
  for {set i 0} {$i < [llength $args]} {incr i} {
    set argvalue [lindex $args $i]
    if { $argvalue  == "-help" } {
      help uvm_phase
      return
    } elseif { $argvalue == "-delete" } {
      incr i
      set argvalue [lindex $args $i]
      if { [remove_break $argvalue] == 0 } {
        puts "uvm: *E,ILLBRK: break point \"$argvalue\" is not valid."
      }
      return
    } elseif { $argvalue == "-stop_at" } {
      incr i
      set argvalue [lindex $args $i]
      if { $argvalue == "-begin" } {
        set pre 1
      } elseif { $argvalue == "-end" } {
        set pre 0
      } elseif { $argvalue == "-build_done" } {
        set break_phase "uvm_build_complete"
      } elseif { [string index $argvalue 0] == "-" } {
        puts "uvm: *E,UNKOPT: unrecognized option for the -stop_at option ($argvalue)."
        return
      } else {
        set break_phase $argvalue
      }
      if { $break_phase == $UNDEF } {
        incr i
        set break_phase [lindex $args $i]
      }
      incr i
      while { $i < [llength $args] } {
        if { $stop_options == -1 } { set stop_options ""}
        set stop_options "$stop_options \{[lindex $args $i]\}"
        incr i
      }
    } elseif { $argvalue == "-get" } {
      set get 1
    } elseif { $argvalue == "-run" } {
      incr i
      set run_phase [lindex $args $i]
    } elseif { ($argvalue == "-stop_request") || ($argvalue == "-global_stop_request") } {
      set stop_req 1
    } else {
      puts "uvm: *E,UNKOPT: unrecognized option for the uvm_phase command ($argvalue)."
      return
    }
  }
  if { (($get != $UNDEF) && (($break_phase != $UNDEF) || ($run_phase != $UNDEF)) ) ||
       (($get != $UNDEF) && (($stop_req != $UNDEF) || ($run_phase != $UNDEF)) ) ||
       (($break_phase != $UNDEF) && (($stop_req != $UNDEF) || ($run_phase != $UNDEF))) } {
    puts "uvm: *E,ILLARG: Only one operation may be specified: set break, get phase, set stop request, or run phase"
    return
  }
  if { $get == 1 } {
    set scope [scope]
    call tcl_uvm_get_phase
    set rval [uvm_get_result]
    scope -set $scope
    return $rval
  } elseif { $stop_req == 1 } {
    task uvm_pkg::cdns_tcl_global_stop_request
  } elseif { $break_phase != $UNDEF } {
    set scope [scope]
    call uvm_set_debug_scope
    if { $break_phase == "uvm_build_complete" } {
      set ph_cmd "$ph_cmd -build_done"
      set stop_cmd "stop -object uvm_build_complete"
      if {$stop_options != $UNDEF} {
        set stop_cmd "$stop_cmd $stop_options"
        set ph_cmd "$ph_cmd $stop_options"
      }
    } else  {
      regsub {_phase$} $break_phase "" break_phase
      set stop_cmd "stop -condition \{\#uvm_break_phase == \"$break_phase\" && \#uvm_phase_is_start == $pre\}"
      if {$pre} { set ph_cmd "$ph_cmd -stop_at $break_phase -begin" } else { set ph_cmd "$ph_cmd -stop_at $break_phase -end" }
      if {$stop_options != $UNDEF} {
        set stop_cmd "$stop_cmd $stop_options"
        set ph_cmd "$ph_cmd $stop_options"
      } 
    }
    if { [info exists all_breaks("$ph_cmd")] } {
      scope -set $scope
      return "Stop $all_breaks(\"$ph_cmd\") already exists"
    }
    set tmp [split [eval $stop_cmd] " "]
    set tmp [lindex $tmp 2]
    set tmp [lindex [split $tmp "\n"] 0]
    set all_breaks("$ph_cmd") $tmp
    set break_by_name($tmp) "$ph_cmd"
    scope -set $scope
    return "Created stop $tmp"
  } elseif { $run_phase != $UNDEF } {
    call tcl_uvm_global_run_phase \"$run_phase\" 
  }
}

proc tcl_get_message { comp tag } {
  set scope [scope]
  call tcl_uvm_get_message \"$comp\" \"$tag\"
  set rval [uvm_get_result]
  scope -set $scope
  return $rval
}


### Tcl access to the uvm versoin
proc uvm_version { } {
  set scope [scope]
  call tcl_uvm_version
  set rval [uvm_get_result]
  scope -set $scope
  return $rval
}

