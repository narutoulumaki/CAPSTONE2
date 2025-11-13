# Nuclear option: completely delete simulation directory and rebuild

puts "Closing simulation..."
catch {close_sim -force}

puts "Deleting entire simulation directory..."
set sim_dir "C:/vivadocodes/vedicdivide/project_1/project_1.sim"
if {[file exists $sim_dir]} {
    file delete -force $sim_dir
    puts "Deleted $sim_dir"
}

puts "Resetting simulation..."
reset_simulation sim_1

puts "Please manually run: launch_simulation"
puts "This will force a complete recompilation."
