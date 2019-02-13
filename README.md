# UART
UART implementation for Computer-FPGA communication over RS232 interface.

### This repository is a work in progress.  

## Introduction:
* The UART-FPGA directory houses the VHDL/Verliog codes as well as design constraints (for Digilent Basys3 board) to implement a UART terminal on the FPGA board.  
* The UART-Computer directory houses the C/C++ codes to to implement a UART terminal on the computer. Shell scripts have also been provided to scan for ports as well as to build, link and run the codes using gcc and g++.
* This design implements an 8-bit UART with one start bit (active low), one stop bit (active high) and no parity bits.
* Baud rate is flexible.

## Attributions and Licensing:
This project relies heavily on the codes from the authors Sebastien Bourdeauducq and Teunis van Beelen, which are availble in the public domain under the GNU GPL version 3.

Therefore, this repository also falls under the licensing terms of GNU GPL version 3 (see LICENSE).

## Current Implementation
* The current implementation maps the I/O pins to the LEDs and the switches on the FPGA board.
* Functions have been defined on the computer-end to transmit and receive 32-bit (unsigned) integers.

## Bug report
None.
