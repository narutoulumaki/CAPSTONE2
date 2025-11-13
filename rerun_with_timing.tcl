# TCL script to re-run implementation with timing constraints
# Run this in Vivado TCL console

# Reset implementation runs to force re-run with new constraints
reset_run synth_1
reset_run impl_1

# Launch synthesis with new constraints
launch_runs synth_1 -jobs 8
wait_on_run synth_1

# Launch implementation
launch_runs impl_1 -jobs 8
wait_on_run impl_1

# Generate timing and power reports
open_run impl_1
report_timing_summary -delay_type max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file timing_summary_200mhz.rpt
report_power -file power_200mhz.rpt
report_utilization -file utilization_final.rpt

puts "\n=========================================="
puts "VEDIC DIVIDER - IMPLEMENTATION COMPLETE"
puts "=========================================="
puts "Check these files for results:"
puts "  - timing_summary_200mhz.rpt"
puts "  - power_200mhz.rpt"
puts "  - utilization_final.rpt"
puts "==========================================\n"
