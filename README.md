# FPGA-Implementations

### FPGA-based implementations of sorting and clustering operations, with Computer-FPGA communication using RS232 protocol.

This repository houses some key implementations developed during my work on the project titled "Trigger Algorithm Development using a µ-TCA-based FPGA" at the TIFR.  

## Introduction:
* <Say something>

## Attributions and Licensing:
This project relies heavily on the codes from the authors Sebastien Bourdeauducq and Teunis van Beelen, which are availble in the public domain under the GNU GPL version 3.

Therefore, this repository also falls under the licensing terms of GNU GPL version 3 (see LICENSE).

<IP Cores>

## Summary of Implementations
* **Array-Sort:**  
Performs sorting on a variable-size array of 32-bit (unsigned) integers received from the computer and writes back the sorted array.  
* **BRAM-Sort:**  
Performs sorting on a variable-size array of 32-bit (unsigned) integers stored in a block-RAM. The BRAM is implemented using an IP-Core and it is loaded with an array which is received from the computer. The sorted array is written back.  
* **2-Means-Clustering:**  
Performs clustering on a 2-dimensional variable-size data set consisting of pairs of 32-bit (unsigned) integers (X, Y) and returns two 2D centroids representing the distribution of the data set. A B-RAM IP-core is implemented internally to store and operate upon the data set. The implementation performs integer-division and provides integer-level precision. A validation script in python has been provided to compute the centroids of the data set and compare them with the ones returned by the FPGA.  

## Description of the common modules

## General configuration
* The 'Board' directory houses the VHDL/Verliog codes as well as the design constraints (for Digilent Basys3 board) to implement a UART terminal on the FPGA board. To reuse the code, please be sure to use an appropriate constraints file suitable for your device.  
* The 'Computer' directory houses the C/C++ codes to to implement a UART terminal on the computer. Shell scripts have also been provided to scan for ports as well as to build, link and run the codes using gcc and g++ compilers.  


### UART
* This design implements an 8-bit UART with one start bit (active low), one stop bit (active high) and no parity bits. 10 bits per packet.
* Baud rate is flexible and needs to be declared in the files: <file names>.
* Code for the implementation of a UART terminal each, on the computer as well as the FPGA, have been provided here.
* Versions of the code in various stages of development will be stored in different directories.
