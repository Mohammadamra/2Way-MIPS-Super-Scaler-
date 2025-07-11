## Generated SDC file "PipeLinedP.out.sdc"

## Copyright (C) 2022  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 22.1std.0 Build 915 10/25/2022 SC Lite Edition"

## DATE    "Wed Dec 11 20:51:08 2024"

##
## DEVICE  "10M08DAF484C8G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 12.0 -waveform { 0.000 8 } [get_ports {clk}]
 
#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty


#**************************************************************
# Set Input Delay
#**************************************************************
set_input_delay -clock {clk} -max 1.0 [all_inputs]
set_input_delay -clock {clk} -min 0.5 [all_inputs]

#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_0[31]}]


set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  1.000 [get_ports {instruction_1[31]}]



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

