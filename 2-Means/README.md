# UART
UART implementation for Computer-FPGA communication over RS232 interface.

### This repository is a work in progress.  

## Introduction:
* This design implements an 8-bit UART with one start bit (active low), one stop bit (active high) and no parity bits.
* Baud rate is flexible.
* Code for the implementation of a UART terminal each, on the computer as well as the FPGA, have been provided here.
* Versions of the code in various stages of development will be stored in different directories.
* The FPGA directory houses the VHDL/Verliog codes as well as design constraints (for Digilent Basys3 board) to implement a UART terminal on the FPGA board.  
* The Computer directory houses the C/C++ codes to to implement a UART terminal on the computer. Shell scripts have also been provided to scan for ports as well as to build, link and run the codes using gcc and g++ compilers.

## Attributions and Licensing:
This project relies heavily on the codes from the authors Sebastien Bourdeauducq and Teunis van Beelen, which are availble in the public domain under the GNU GPL version 3.

Therefore, this repository also falls under the licensing terms of GNU GPL version 3 (see LICENSE).

## Current Implementation
* The current implementation performs sorting on a variable-size array of 32-bit (unsigned) integers received from the computer and writes back the sorted array.
* The upper limit of the size  of the array has been set to 100. It can be changed (within the FPGA code) as per the requirement.
* It is recommended to press the RESET switch between two consecutive runs of the programme.
* The programme on the computer-end generates and sends a randomised array, reads the sorted array and checks its consistency.

## Bug report
None. (Need to upload the previous stable versions of the project.)
