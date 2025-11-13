# Quick script to add constraints and re-run
# Paste this into Vivado TCL Console

# Check if constraint file exists in project
set constr_file "C:/vivadocodes/vedicdivide/project_1/project_1.srcs/constrs_1/new/timing_constraints.xdc"

# Try to add it (will error if already added, that's okay)
catch {add_files -fileset constrs_1 -norecurse $constr_file}

# Set it as used
set_property used_in_synthesis true [get_files $constr_file]
set_property used_in_implementation true [get_files $constr_file]

# Reset and rerun
reset_run synth_1
reset_run impl_1

puts "Starting synthesis with timing constraints..."
launch_runs synth_1 -jobs 8
