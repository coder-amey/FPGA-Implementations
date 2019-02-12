# UART
UART implementation for Computer-FPGA communication over RS232 interface.

### This repository is a work in progress.  

## Introduction:
* The UART-FPGA directory houses the VHDL/Verliog codes as well as design constraints (for Digilent Basys3 board) to implement a UART terminal on the FPGA board.  
* The UART-Computer directory houses the C/C++ codes to to implement a UART terminal on the computer. Shell scripts have also been provided to scan for ports as well as to build, link and run the codes using gcc and g++.

## Current Implementation
* The current implementation maps I/O pins to the LEDs and switches on the FPGA board.
* Functions have been defined on the computer-end to transmit and receive 32-bit (unsigned) integers.

## Bug report
The FPGA ignores or is unable to read specific bytes.

E.g.: 0x00, 0xFF, ASCII characters: c, e, f, i, j, l, o, q, r, t, w, x; and more...
