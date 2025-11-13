# Clean project and add only required source files
# Run this in Vivado TCL console after removing all files from project

puts "========================================="
puts "Adding required source files..."
puts "========================================="

# Add Vedic dividers (already exist, keep them)
puts "Adding Vedic BCD dividers..."
add_files -norecurse -fileset sources_1 {C:/vivadocodes/vedicdivide/project_1/project_1.srcs/sources_1/new/vedicdivider_dhwajank.sv}
add_files -norecurse -fileset sources_1 {C:/vivadocodes/vedicdivide/project_1/project_1.srcs/sources_1/new/vedicdivider_dhwajank_pipelined.sv}

# Add binary dividers (combinational)
puts "Adding binary dividers (combinational)..."
add_files -norecurse -fileset sources_1 {C:/vivadocodes/vedicdivide/project_1/project_1.srcs/sources_1/new/binary_nonrestoring_divider.sv}
add_files -norecurse -fileset sources_1 {C:/vivadocodes/vedicdivide/project_1/project_1.srcs/sources_1/new/binary_restoring_divider.sv}
add_files -norecurse -fileset sources_1 {C:/vivadocodes/vedicdivide/project_1/project_1.srcs/sources_1/new/binary_srt_divider.sv}

# Add binary dividers (pipelined)
puts "Adding binary dividers (pipelined)..."
add_files -norecurse -fileset sources_1 {C:/vivadocodes/vedicdivide/project_1/project_1.srcs/sources_1/new/binary_nonrestoring_divider_pipelined.sv}
add_files -norecurse -fileset sources_1 {C:/vivadocodes/vedicdivide/project_1/project_1.srcs/sources_1/new/binary_restoring_divider_pipelined.sv}
add_files -norecurse -fileset sources_1 {C:/vivadocodes/vedicdivide/project_1/project_1.srcs/sources_1/new/binary_srt_divider_pipelined.sv}

# Add testbench
puts "Adding testbench..."
add_files -norecurse -fileset sim_1 {C:/vivadocodes/vedicdivide/project_1/project_1.srcs/sim_1/new/tb_binary_dividers.sv}

# Update compile order
puts "Updating compile order..."
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Set testbench as top
set_property top tb_binary_dividers [get_filesets sim_1]
update_compile_order -fileset sim_1

puts "========================================="
puts "✓ All files added successfully!"
puts "========================================="
puts ""
puts "Now run: launch_simulation"
