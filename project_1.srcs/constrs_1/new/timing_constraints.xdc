# Timing Constraints for Vedic Divider Pipelined Implementation
# Target: 200 MHz clock frequency (5 ns period)

# Create clock constraint on the input clock port
create_clock -period 5.000 -name clk -waveform {0.000 2.500} [get_ports clk]

# Set input delay relative to clock (assume 1ns from external source)
set_input_delay -clock clk -min 0.500 [get_ports {dividend[*] divisor[*] valid_in rst_n}]
set_input_delay -clock clk -max 1.000 [get_ports {dividend[*] divisor[*] valid_in rst_n}]

# Set output delay relative to clock (assume 1ns setup requirement at destination)
set_output_delay -clock clk -min 0.500 [get_ports {quotient[*] remainder[*] valid_out div_by_zero done}]
set_output_delay -clock clk -max 1.000 [get_ports {quotient[*] remainder[*] valid_out div_by_zero done}]

# Relax timing on reset (async reset doesn't need tight timing)
set_false_path -from [get_ports rst_n] -to [all_registers]
