# Simple clean and recompile script

# Close any open simulation
catch {close_sim -force}

# Reset the simulation
reset_simulation sim_1

puts "Files reset. Now manually run: launch_simulation"
