# Add simple debug testbench and run it

# Set as top module
set_property top tb_simple_debug [get_filesets sim_1]

# Update compile order
update_compile_order -fileset sim_1

puts "Debug testbench set as top. Now run: launch_simulation"
