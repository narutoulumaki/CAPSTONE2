# TCL script to add binary divider sources to Vivado project
# Run this in Vivado TCL console

# Add combinational binary dividers
add_files -norecurse {C:/vivadocodes/vedicdivide/project_1/project_1.srcs/sources_1/new/binary_nonrestoring_divider.sv}
add_files -norecurse {C:/vivadocodes/vedicdivide/project_1/project_1.srcs/sources_1/new/binary_restoring_divider.sv}
add_files -norecurse {C:/vivadocodes/vedicdivide/project_1/project_1.srcs/sources_1/new/binary_srt_divider.sv}

# Add pipelined binary dividers
add_files -norecurse {C:/vivadocodes/vedicdivide/project_1/project_1.srcs/sources_1/new/binary_nonrestoring_divider_pipelined.sv}
add_files -norecurse {C:/vivadocodes/vedicdivide/project_1/project_1.srcs/sources_1/new/binary_restoring_divider_pipelined.sv}
add_files -norecurse {C:/vivadocodes/vedicdivide/project_1/project_1.srcs/sources_1/new/binary_srt_divider_pipelined.sv}

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Binary divider sources added successfully!"
puts "You can now run simulation."
