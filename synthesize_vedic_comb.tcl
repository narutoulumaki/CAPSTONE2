# TCL script to synthesize combinational Vedic divider
# Run this in Vivado TCL console

puts "\n=========================================="
puts "SYNTHESIZING COMBINATIONAL VEDIC DIVIDER"
puts "==========================================\n"

# Set top module
set_property top vedicdivider_dhwajank [current_fileset]

# Reset synthesis run
reset_run synth_1

# Launch synthesis
launch_runs synth_1 -jobs 8
wait_on_run synth_1

# Check if successful
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "ERROR: Synthesis failed!"
    exit 1
}

# Open synthesized design
open_run synth_1

# Generate reports
report_utilization -file vedic_comb_utilization.rpt
report_timing_summary -file vedic_comb_timing.rpt

puts "\n=========================================="
puts "SYNTHESIS COMPLETE!"
puts "Check these files:"
puts "  - vedic_comb_utilization.rpt"
puts "  - vedic_comb_timing.rpt"
puts "==========================================\n"
