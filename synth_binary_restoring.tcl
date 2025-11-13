# Synthesize binary restoring divider
# (Project already open in Vivado GUI)

# Set top module
set_property top binary_restoring_divider [current_fileset]

# Reset and run synthesis
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Open and report
open_run synth_1
report_utilization -file "c:/vivadocodes/vedicdivide/project_1/project_1.runs/synth_1/binary_restoring_utilization_synth.rpt"
report_timing_summary -file "c:/vivadocodes/vedicdivide/project_1/project_1.runs/synth_1/binary_restoring_timing_synth.rpt"

# Run implementation
launch_runs impl_1 -to_step route_design -jobs 4
wait_on_run impl_1

# Open and report
open_run impl_1
report_utilization -file "c:/vivadocodes/vedicdivide/project_1/project_1.runs/impl_1/binary_restoring_utilization_impl.rpt"
report_timing_summary -file "c:/vivadocodes/vedicdivide/project_1/project_1.runs/impl_1/binary_restoring_timing_impl.rpt"

puts "Binary Restoring Divider synthesis complete!"
