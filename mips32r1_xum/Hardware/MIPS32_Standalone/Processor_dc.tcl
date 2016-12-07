#/**************************************************/
#/* Compile Script for Synopsys                    */
#/*                                                */
#/* dc_shell-t -f compile_dc.tcl                   */
#/*                                                */
#/* OSU FreePDK 45nm                               */
#/**************************************************/

#/* All verilog files, separated by spaces         */
set my_verilog_files [list Processor.v ]

#/* Top-level Module                               */
set my_toplevel Processor

#/* The name of the clock pin. If no clock-pin     */
#/* exists, pick anything                          */
set my_clock_pin clock

#/* Target frequency in MHz for optimization       100*/
set my_clk_freq_MHz 1

#/* Delay of input signals (Clock-to-Q, Package etc.)  0.1*/
set my_input_delay_ns 1

#/* Reserved time for output signals (Holdtime etc.)   0.1*/
set my_output_delay_ns 0.5

set cycle  10  
#/**************************************************/
#/* No modifications needed below                  */
#/**************************************************/
# set OSU_FREEPDK [format "%s%s"  [getenv "OSU_FREEPDK"] "/lib/files"]
set OSU_FREEPDK [concat  [list /home/lads/FreePDK_SRC/osu_freepdk_1.0/lib/files/ ] ]
set search_path [concat  [list . /usr/cad/synopsys/synthesis/2015.06-sp3/libraries/syn ] $search_path $OSU_FREEPDK]
set alib_library_analysis_path $OSU_FREEPDK

set link_library [set target_library [concat  [list gscl45nm.db] [list dw_foundation.sldb]]]
set target_library "gscl45nm.db"
define_design_lib WORK -path ./WORK
set verilogout_show_unconnected_pins "true"
# set_ultra_optimization true
# set_ultra_optimization -force

analyze -f verilog $my_verilog_files

elaborate $my_toplevel

current_design $my_toplevel

link
uniquify
    
create_clock -period $cycle [get_ports  clock]
set_dont_touch_network      [get_clocks clock]
set_clock_uncertainty  0.1  [get_clocks clock]
set_clock_latency      0.5  [get_clocks clock]

set_input_delay $my_input_delay_ns -clock clock [remove_from_collection [all_inputs] [get_ports clock]]
set_output_delay $my_output_delay_ns -clock clock [all_outputs]
#/* */
set_load -pin_load 1  [all_outputs]
set_drive          1  [all_inputs]
#/* */
set_max_fanout 20 [all_inputs]

#compile -ungroup_all -map_effort medium
#compile -dont_touch_all -map_effort medium
compile -map_effort medium -boundary_optimization
#compile -incremental_mapping -map_effort medium

check_design
report_constraint -all_violators

set filename [format "%s%s"  $my_toplevel "_syn.v"]
write -f verilog -hier -output [format "%s%s"  "./WORK/" $filename]

set filename [format "%s%s"  $my_toplevel "_syn.sdc"]
write_sdc [format "%s%s"  "./WORK/" $filename]
#$filename

set filename [format "%s%s"  $my_toplevel "_syn.ddc"]
write -f ddc -hier -output [format "%s%s"  "./WORK/" $filename]
#$filename 

set filename [format "%s%s"  $my_toplevel "_syn.sdf"]
write_sdf -version 2.1 [format "%s%s"  "./WORK/" $filename]
#$filename

redirect [format "%s%s"  "./REPORT/" violation.rpt] { report_constraint -all_violators -verbose }
redirect [format "%s%s"  [format "%s%s"  "./REPORT/" $my_toplevel] ".area"] { report_area }
redirect [format "%s%s"  "./REPORT/" timing.rpt] { report_timing }
redirect [format "%s%s"  "./REPORT/" cell.rpt] { report_cell }
redirect [format "%s%s"  "./REPORT/" power.rpt] { report_power }


# quit
