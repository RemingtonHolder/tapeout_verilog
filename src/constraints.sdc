# cut the enable arc through the NAND
set_disable_timing [get_pins start/B] -to [get_pins start/Y]

# break timing around the feedback so STA/Resizer leave it alone
set_false_path -through [get_nets y]
set_false_path -through [get_nets b0]
