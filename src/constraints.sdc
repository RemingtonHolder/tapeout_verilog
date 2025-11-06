# cut the enable arc in the NAND
set_disable_timing [get_pins {tapped_ring/start/B}] -to [get_pins {tapped_ring/start/Y}]
# don't time the feedback loop
set_false_path -through [get_nets {tapped_ring/y}]
set_false_path -through [get_nets {tapped_ring/b0}]
