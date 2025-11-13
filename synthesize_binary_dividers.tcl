# Synthesis script for all binary dividers (combinational versions)

# Set project paths
set project_dir "c:/vivadocodes/vedicdivide/project_1"

# Open project
open_project "$project_dir/project_1.xpr"

# List of binary dividers to synthesize
set dividers {
    "binary_nonrestoring_divider"
    "binary_restoring_divider"
    "binary_srt_divider"
}

foreach divider $dividers {
    puts "\n=========================================="
    puts "Synthesizing $divider..."
    puts "==========================================\n"
    
    # Reset synthesis run
    reset_run synth_1
    
    # Set top module
    set_property top $divider [current_fileset]
    
    # Run synthesis
    launch_runs synth_1
    wait_on_run synth_1
    
    # Open synthesized design
    open_run synth_1
    
    # Write reports
    report_utilization -file "$project_dir/project_1.runs/synth_1/${divider}_utilization_synth.rpt"
    report_timing_summary -file "$project_dir/project_1.runs/synth_1/${divider}_timing_synth.rpt"
    
    puts "\n$divider synthesis complete!"
    
    # Run implementation
    puts "Running implementation for $divider..."
    launch_runs impl_1 -to_step route_design
    wait_on_run impl_1
    
    # Open implemented design
    open_run impl_1
    
    # Write implementation reports
    report_utilization -file "$project_dir/project_1.runs/impl_1/${divider}_utilization_impl.rpt"
    report_timing_summary -file "$project_dir/project_1.runs/impl_1/${divider}_timing_impl.rpt"
    
    puts "$divider implementation complete!\n"
}

puts "\n=========================================="
puts "All binary dividers synthesized!"
puts "==========================================\n"

close_project
