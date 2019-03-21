## Author: Amey.

## Clock signal: Period = 10 ns
set_property PACKAGE_PIN W5 [get_ports CLK]
    set_property IOSTANDARD LVCMOS33 [get_ports CLK]
    create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK]

##Buttons
set_property PACKAGE_PIN U18 [get_ports RESET]
    set_property IOSTANDARD LVCMOS33 [get_ports RESET]

## LEDs
set_property PACKAGE_PIN P1 [get_ports {sbits[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {sbits[1]}]
set_property PACKAGE_PIN L1 [get_ports {sbits[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {sbits[0]}]

##USB-RS232 Interface
set_property PACKAGE_PIN B18 [get_ports uart_rx]
    set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]
set_property PACKAGE_PIN A18 [get_ports uart_tx]
    set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]