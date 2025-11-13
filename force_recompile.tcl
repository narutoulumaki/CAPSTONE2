# Force clean recompilation of all sources
# This script removes all compiled simulation files and recompiles everything

puts "Closing current simulation..."
catch {close_sim -force}

puts "Resetting simulation fileset..."
reset_simulation sim_1

puts "Removing all compiled files..."
set sim_dir "C:/vivadocodes/vedicdivide/project_1/project_1.sim/sim_1/behav/xsim"
if {[file exists $sim_dir]} {
    file delete -force $sim_dir
}

puts "Recompiling all design sources..."
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Launching fresh simulation..."
launch_simulation

puts "Simulation ready! Now run: run 1000ns"
