## Author: Amey.

## Clock signal: Period = 10 ns.
set_property PACKAGE_PIN W5 [get_ports CLK]
    set_property IOSTANDARD LVCMOS33 [get_ports CLK]
    create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK]

##Buttons
set_property PACKAGE_PIN W19 [get_ports RESET]
    set_property IOSTANDARD LVCMOS33 [get_ports RESET]
set_property PACKAGE_PIN T17 [get_ports SEND]
    set_property IOSTANDARD LVCMOS33 [get_ports SEND]
 
## Switches
set_property PACKAGE_PIN V17 [get_ports {tx_data[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {tx_data[0]}]
set_property PACKAGE_PIN V16 [get_ports {tx_data[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {tx_data[1]}]
set_property PACKAGE_PIN W16 [get_ports {tx_data[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {tx_data[2]}]
set_property PACKAGE_PIN W17 [get_ports {tx_data[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {tx_data[3]}]
set_property PACKAGE_PIN W15 [get_ports {tx_data[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {tx_data[4]}]
set_property PACKAGE_PIN V15 [get_ports {tx_data[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {tx_data[5]}]
set_property PACKAGE_PIN W14 [get_ports {tx_data[6]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {tx_data[6]}]
set_property PACKAGE_PIN W13 [get_ports {tx_data[7]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {tx_data[7]}]

## LEDs
set_property PACKAGE_PIN U16 [get_ports {rx_data[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {rx_data[0]}]
set_property PACKAGE_PIN E19 [get_ports {rx_data[1]}]                  
    set_property IOSTANDARD LVCMOS33 [get_ports {rx_data[1]}]
set_property PACKAGE_PIN U19 [get_ports {rx_data[2]}]                  
    set_property IOSTANDARD LVCMOS33 [get_ports {rx_data[2]}]
set_property PACKAGE_PIN V19 [get_ports {rx_data[3]}]                  
    set_property IOSTANDARD LVCMOS33 [get_ports {rx_data[3]}]
set_property PACKAGE_PIN W18 [get_ports {rx_data[4]}]                  
    set_property IOSTANDARD LVCMOS33 [get_ports {rx_data[4]}]
set_property PACKAGE_PIN U15 [get_ports {rx_data[5]}]                  
    set_property IOSTANDARD LVCMOS33 [get_ports {rx_data[5]}]
set_property PACKAGE_PIN U14 [get_ports {rx_data[6]}]                  
    set_property IOSTANDARD LVCMOS33 [get_ports {rx_data[6]}]
set_property PACKAGE_PIN V14 [get_ports {rx_data[7]}]                  
    set_property IOSTANDARD LVCMOS33 [get_ports {rx_data[7]}]
set_property PACKAGE_PIN L1 [get_ports {rx_done}]                  
    set_property IOSTANDARD LVCMOS33 [get_ports {rx_done}]
set_property PACKAGE_PIN P1 [get_ports {tx_done}]                  
    set_property IOSTANDARD LVCMOS33 [get_ports {tx_done}]
        
##USB-RS232 Interface
set_property PACKAGE_PIN B18 [get_ports uart_rx]
    set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]
set_property PACKAGE_PIN A18 [get_ports uart_tx]
    set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]
