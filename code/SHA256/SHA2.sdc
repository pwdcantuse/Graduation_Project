# operating conditions and boundary conditions #

set cycle 7.0       ;#clock period defined by designer

create_clock -period $cycle [get_ports  clk]
set_dont_touch_network      [get_clocks clk]
set_fix_hold                [all_clocks]
set_clock_uncertainty  0.1  [all_clocks]
set_clock_latency      0.5  [all_clocks]
set_ideal_network           [get_ports clk]

set_input_delay  5      -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 0.5    -clock clk [all_outputs] 
set_load         1     [all_outputs]
set_drive        1     [all_inputs]

set_operating_conditions  -max slow  -min fast
set_wire_load_model -name tsmc13_wl10 -library slow                        

set_max_fanout 6 [all_inputs]

                       
