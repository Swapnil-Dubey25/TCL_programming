#----------------------script for mapping the content of the .csv file to a variable array-------------------------#

set file_name [lindex $argv 0]
package require csv
package require struct::matrix
struct::matrix m
set f [open $file_name]
csv::read2matrix $f m , auto
close $f
set no_of_column [m columns]
set no_of_rows [m rows]
m link my_array
set i 0

#-----------------script for creating the variables of the same name as mentioned in the .csv file which can be used for debugging------ #

while {$i < $no_of_rows} {
	puts "\nInfo : Assigning the variable $my_array(0,$i) as $my_array(1,$i) from the .csv file"
	if {$i == 0} {
		set [string map {" " ""} $my_array(0,$i)] $my_array(1,$i)
	} else {
		set [string map {" " ""} $my_array(0,$i)] [file normalize $my_array(1,$i)]
	}
	set i [expr {$i+1}]
}
puts "\nINFO : Below is the list of initial variables and there location in the local directory which can be used for debugging "
#puts  "DesignName" =  $DesignName"
#puts "OutputDirectory" = $OutputDirectory"
#puts "NetlistDirectory" = $NetlistDirectory"
#puts "EarlyLibraryPath" = $EarlyLibraryPath"
#puts "ConstraintsFile" = $ConstraintsFile"

#---------Script to check  the files end directiory are mentioned  in the .csv file exist or not--------------#

if {![file exist $NetlistDirectory]} {
	puts "\n Error : Netlist Directory doesnot exist in the mentioned path $NetlistDirectory"
	exit
} else {
	puts "\n Info :RTL netlist directory exist in the path $NetlistDirectory"
}

if {![file exist $EarlyLibraryPath]} {
        puts "\n Error : Early Library path file doesnot exist in the mentioned path $EarlyLibraryPath"
        exit
} else {
        puts "\n Info :Early Library path file exist in the path $EarlyLibraryPath "
}

if {![file exist $ConstraintsFile]} {
        puts "\n Error : Constraints file doesnot exist in the mentioned path $ConstraintsFile"
        exit
} else {
        puts "\n Info : Constraints file exist in the path $ConstraintsFile"
}

if {![file exist $OutputDirectory]} {
        puts "\n Error : Output directory doesnot exist in the mentioned path $OutputDirectory"
	file mkdir $OutputDirectory
        exit
} else {
        puts "\n Info : Output directory  exist in the path $OutputDirectory" 
}

#-----------------------Constraints file(SDC:CALCULATION OF ININITAL LOCATIONS )------------------------------#

puts "\n Info : dumping the sdc contsraints for $DesignName"
::struct::matrix constraints
set files [open $ConstraintsFile]
csv::read2matrix $files constraints , auto
close $files
set number_of_rows [constraints rows]
set number_of_columns [constraints columns]

#-------------locating the row number for "clocks" , "inputs" , "output"------------------------------------- #

set clock_start [lindex [lindex [constraints search all CLOCKS] 0] 1]
set input_port_start [lindex [lindex [constraints search all INPUTS] 0] 1]
set output_port_start [lindex [lindex [constraints search all OUTPUTS] 0] 1]

#-----check for the location of the column of " clocks"," input" , "output"-------------------------------------------------------------#

set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0] 0]

#-------------------CLOCK CONSTRAINTS--------------------------------------------------------------------------#
#---------------Clock latency constraints---------------------------------------------------------------------#

set clock_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_port_start-1}] early_rise_delay] 0 ] 0]
set clock_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_port_start-1}] early_fall_delay] 0 ] 0]
set clock_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_port_start-1}] late_rise_delay] 0 ] 0]
set clock_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_port_start-1}] late_fall_delay] 0 ] 0]


#-----------------------clock transition constraints-----------------------------------------------------------#

set clock_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_port_start-1}] early_rise_slew] 0 ] 0]
set clock_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_port_start-1}] early_fall_slew] 0 ] 0]
set clock_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_port_start-1}] late_rise_slew] 0 ] 0]
set clock_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_port_start-1}] late_fall_slew] 0 ] 0]

set sdc_file [open $OutputDirectory/$DesignName.sdc "w"]
set i [expr {$clock_start +1}]
set end_of_ports [expr {$input_port_start-1}]
puts "\n INFO: WORKING ON CLOCK CONSTRAINTS"
while {$i < $end_of_ports} {
        puts -nonewline $sdc_file "\nCreate_clock -name [constraints get cell 0 $i] -period [constraints get cell 1 $i] -waveform \{0 [expr {[constraints get cell 1 $i]*[constraints get cell 2 $i]/100}]\} \[get ports [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\n set_clock_transition -rise -min [constraints get cell $clock_early_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\n set_clock_transition -fall -min [constraints get cell $clock_early_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\n set_clock_transition -rise -max [constraints get cell $clock_late_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\n set_clock_transition -fall -max [constraints get cell $clock_late_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"

       	puts -nonewline $sdc_file "\n set_clock_latency -source -early -rise [constraints get cell $clock_early_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\n set_clock_latency -source -early -fall [constraints get cell $clock_early_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\n set_clock_latency -source -late -rise [constraints get cell $clock_late_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\n set_clock_latency -sorce -late -fall [constraints get cell $clock_late_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"

	set i [expr {$i+1}]
}
#-------------------------INPUT CONSTRAINTS----------------------------------------------------------------------------------------#

set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$number_of_columns-1}] [expr {$output_port_start-1}] early_rise_delay] 0 ] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$number_of_columns-1}] [expr {$output_port_start-1}] early_fall_delay] 0 ] 0]
set input_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$number_of_columns-1}] [expr {$output_port_start-1}] late_rise_delay] 0 ] 0]
set input_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$number_of_columns-1}] [expr {$output_port_start-1}] late_fall_delay] 0 ] 0]
set input_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$number_of_columns-1}] [expr {$output_port_start-1}] early_rise_slew] 0 ] 0]
set input_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$number_of_columns-1}] [expr {$output_port_start-1}] early_fall_slew] 0 ] 0]
set input_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$number_of_columns-1}] [expr {$output_port_start-1}] late_rise_slew] 0 ] 0]
set input_late_fall__slew_start [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$number_of_columns-1}] [expr {$output_port_start-1}] late_fall_slew] 0 ] 0]
		
set Related_clock [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$number_of_columns-1}] [expr {$output_port_start-1}] clocks] 0 ] 0]

set i [expr {$input_port_start +1}]
set end_of_port [expr {$output_port_start-1}]
puts "\n :INFO: Working on input contraints"
puts "\n :INFO : Categorising the input ports bits and bussed "
while {$i < $end_of_port} {
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1/ w]
foreach f $netlist {
	set fd [open $f]
	while {[gets $fd line] != -1} {
		set pattern1 "[constraints get cell 0 $i];"
		if {[regexp -all -- $pattern1 $line]} {
			set pattern2 {lindex [split $line ";"] 0}
			if {[regexp -all {input} [lindex [split $pattern2 "\S+"] 0]]} {
				set s1 "[lindex [split $pattern2 "S+"] 0] [lindex [split $pattern2 "S+"] 1] [index [split $pattern "S+"] 2]"
				puts -nonewline $temp_file "\n [regsub -all {\S+} $s1 " "]"
			}
		}
	}
	close $fd
}
close $tmp_file

set tmp_file [open /tmp/1 r]
set tmp2_file [open /tmp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open /tmp/2 r]
set count [llength [read $tmp2_file]]
if {$count >2} {
	set inp_Ports [concat [constraints get call 0 $i]*]
} else {
	set inp_ports [constraints get cell 0 $i]
}
puts -nonewline $sdc_file "\n set_input_delay -clock \[get_clocks [constraints get cell $Related_clock $i]\] -min -rise -source -latency_included [constraints get cell $input_early_rise_delay_start $i]\[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\n set_input_delay -clock \[get_clocks [constraints get cell $Related_clock $i]\] -min -fall -source -latency_included [constraints get cell $input_early_fall_delay_start $i]\[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\n set_input_delay -clock \[get_clocks [constraints get cell $Related_clock $i]\] -max -rise -source -latency_included [constraints get cell $input_late_rise_delay_start $i]\[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\n set_input_delay -clock \[get_clocks [constraints get cell $Related_clock $i]\] -max -fall  -source -latency_included [constraints get cell $input_late_fall_delay_start $i]\[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\n set_input_delay -clock \[get_clocks [constraints get cell $Related_clock $i]\] -in -rise -source -latency_included [constraints get cell $input_early_rise_delay_start $i]\[get_ports $inp_ports\]"

puts -nonewline $sdc_file "\n set_input_delay -clock \[get_clocks [constraints get cell $Related_clock $i]\] -in -rise -source -latency_included [constraints get cell $input_early_rise_delay_start $i]\[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\n set_input_delay -clock \[get_clocks [constraints get cell $Related_clock $i]\] -in -rise -source -latency_included [constraints get cell $input_early_rise_delay_start $i]\[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\n set_input_delay -clock \[get_clocks [constraints get cell $Related_clock $i]\] -in -rise -source -latency_included [constraints get cell $input_early_rise_delay_start $i]\[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\n set_input_delay -clock \[get_clocks [constraints get cell $Related_clock $i]\] -in -rise -source -latency_included [constraints get cell $input_early_rise_delay_start $i]\[get_ports $inp_ports\]"
set i [expr {$i+1}]
} 
close $tmp2_file

#-----------------------------------OUTPUT CONSTRAINTS-------------------------------------------------------------------------------------------------#

set output_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_port_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] early_rise_delay] 0 ] 0]
set output_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_port_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] early_fall_delay] 0 ] 0]
set output_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_port_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] late_rise_delay] 0 ] 0]
set output_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_port_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] late_fall_delay] 0 ] 0]
set output_load_start [lindex [lindex [constraints search rect $clock_start_column $output_port_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] load] 0 ] 0]
set related_clock [lindex [lindex [constraints search rect $clock_start_column $output_port_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] clocks] 0 ] 0]

set i [expr {$output_port_start +1}]
set end_of_ports [expr {$number_of_rows}]
puts "\n INFO: WORKING ON output CONSTRAINTS"
puts "\n INFO:Categorizing the bits and bussed"

while { $i < $end_of_ports } {
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1 w]
foreach f  $netlist {
        set fd [open $f]
        while {[gets $fd line] != -1} {
                set pattern1 "[constraints get cell 0 $i];"
                if {[regexp -all -- $pattern1 $line]} {
                        set pattern2 {lindex [split $line ";"] 0}
                        if {[regexp -all {output} [lindex [split $pattern2 "\S+"] 0]]} {
                                set s1 "[lindex [split $pattern2 "S+"] 0] [lindex [split $pattern2 "S+"] 1] [lindex [split $pattern "S+"] 2]"
                                puts -nonewline $temp_file "\n [regsub -all {\S+} $S1 " "]"
			}
		}
	}
close $fd
}
close $tmp_file

set tmp_file [open /tmp/1 r]
set tmp2_file [open /tmp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open /tmp/2 r]
set count [split [llength [read $tmp2_file]] " "]
if {$count >2} {
        set op_ports [concat [constraints get call 0 $i]*]
} else {
        set op_ports [constraints get cell 0 $i]
}
puts -nonewline $sdc_file "\nset_output_Delay_clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise source_latency_inlcuded [constraints get cell $output_early_rise_delay_start $i] \[get ports $op_ports\]"
puts -nonewline $sdc_file "\nset_output_Delay_clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise source_latency_inlcuded [constraints get cell $output_early_fall_delay_start $i] \[get ports $op_ports\]"
puts -nonewline $sdc_file "\nset_output_Delay_clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise source_latency_inlcuded [constraints get cell $output_late_rise_delay_start $i] \[get ports $op_ports\]"
puts -nonewline $sdc_file "\nset_output_Delay_clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise source_latency_inlcuded [constraints get cell $output_late_fall_delay_start $i] \[get ports $op_ports\]"
puts -nonewline $sdc_file "\nset_load [constraints get cell $output_load_start $i]\[get ports $op_ports\]"
set i [expr {$i+1}]
}
close $tmp2_file
close $sdc_file
puts "\n SDC CREATED."
#--------------------------------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------Hierarchy check-----------------------------------------------------------------------------------------------------#

puts "\nInfo:Creating Hierarchy check script to be used by Yosys"
set data "read liberty -lib -gnore miss dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.hier.ys"
set fileid [open $OutputDirectory/$filename "w"]
puts -nonewline $fileid $data

set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
	set data $f
	puts -nonewline $fileid "\nread_verilog $f"
}
puts -nonewline $fileid "\nread_verilog $f"
close $fileid

if { [catch { exec yosys -s $OutputDirectory/$DesignName.hier.ys>& $OutputDirectory/$DesignName.hierarchy_check.log} msg]} {
	set filename "$OutputDirectory/$DesignName.hierarchy.check.log"
	set pattern {referenced in module}
	puts "pattern is $pattern"
	set count 0
	set fid [open $filename r]
	while {[gets $fid line]!= -1} {
		incr count [regexp -all -- $pattern $line]
		if {[regexp -all -- $pattern $line]} {
			puts "\nError :module [lindex $line 2] is not of design $DesignName.please correct RTL in the path $NetlistDirectory"
			puts "\n Info : Hierarchy check fail"
		}
	}
	close $fid
} else {
	puts "\n INFO :hIERARCHY CHECK PASS"
}
puts "\n INFO: please find hierarchy check details in [file normalize $OutputDirectory/$DesignName.hierarchy_check.log] for more info"

