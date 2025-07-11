create_clock -name {CLK} -period 12.0 [get_ports {CLK}]
create_clock -name {clk} -period 24.0 [get_ports {clk}]
set_input_delay -clock {clk} -max 1.0 [all_inputs]
set_input_delay -clock {clk} -min 0.2 [all_inputs]
set_output_delay -clock {clk} -max 1.0 [all_outputs]
set_output_delay -clock {clk} -min 0.2 [all_outputs]

derive_clock_uncertainty
