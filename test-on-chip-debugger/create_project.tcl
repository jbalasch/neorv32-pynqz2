set board "pynq-z2"

# Create and clear output directory
set outputdir work
file mkdir $outputdir

set files [glob -nocomplain "$outputdir/*"]
if {[llength $files] != 0} {
    puts "deleting contents of $outputdir"
    file delete -force {*}[glob -directory $outputdir *]; # clear folder contents
} else {
    puts "$outputdir is empty"
}

switch $board {
  "pynq-z2" {
    set pynqz2part "xc7z020clg400-1"
    set pynqz2prj ${board}-test-setup
  }
}

# Create project
create_project -part $pynqz2part $pynqz2prj $outputdir

set_property board_part tul.com.tw:$board:part0:1.0 [current_project]
set_property target_language VHDL [current_project]

# Define filesets

## Core: NEORV32
add_files [glob ./../neorv32/rtl/core/*.vhd] ./../neorv32/rtl/core/mem/neorv32_dmem.default.vhd ./../neorv32/rtl/core/mem/neorv32_imem.default.vhd
set_property library neorv32 [get_files [glob ./../neorv32/rtl/core/*.vhd]]
set_property library neorv32 [get_files [glob ./../neorv32/rtl/core/mem/neorv32_*mem.default.vhd]]

add_files ./../neorv32/rtl/test_setups/neorv32_test_setup_on_chip_debugger.vhd

add_files ./clkgen_pynqz2.sv

## Design: processor subsystem template, and (optionally) BoardTop and/or other additional sources
set fileset_design ./neorv32_pynz2_ocd_wrapper.vhd

## Constraints
set fileset_constraints [glob ./*.xdc]

## Simulation-only sources
set fileset_sim [list ./../neorv32/sim/simple/neorv32_tb.simple.vhd ./../neorv32/sim/simple/uart_rx.simple.vhd]

# Add source files

## Design
add_files $fileset_design

## Constraints
add_files -fileset constrs_1 $fileset_constraints

## Simulation-only
add_files -fileset sim_1 $fileset_sim

# Run synthesis, implementation and bitstream generation
#launch_runs impl_1 -to_step write_bitstream -jobs 4
#wait_on_run impl_1
