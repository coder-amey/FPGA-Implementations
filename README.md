# FPGA-Implementations

### FPGA-based implementations of sorting and clustering operations, with Computer-FPGA communication using RS232 protocol.

This repository houses some key implementations developed during my work on the project titled "Trigger Algorithm Development using a µ-TCA-based FPGA" at the TIFR.  

## Introduction:
* This repository showcases the basic building-blocks of an FPGA-implementation – such as the communication module (UART), the memory unit (BRAM) etc – and builds on top of them to implement a K-Means clustering algorithm with 2 centroids.
* This development is a part of a larger proof-of-concept project to implement an FPGA-based L1-trigger for the HL-LHC.
* This development was undertaken at the Tata Institute of Fundamental Research under the guidance of Dr. Raghunandan Shukla ([@raghunandanshukla](https://github.com/raghunandanshukla)) by Mr. Gaurang Patel, Mr. Rohit Rayte and (me) Mr. Amey Noolkar ([@coder-amey](https://github.com/coder-amey)).

## Summary of Implementations
* **Array-Sort:**  
Performs sorting on a variable-size array of 32-bit (unsigned) integers received from the computer and writes back the sorted array.  
* **BRAM-Sort:**  
Performs sorting on a variable-size array of 32-bit (unsigned) integers stored in a block-RAM. The BRAM is implemented using an IP-Core and it is loaded with an array which is received from the computer. The sorted array is written back.  
* **2-Means-Clustering:**  
Performs clustering on a 2-dimensional variable-size data set consisting of pairs of 32-bit (unsigned) integers (X, Y) and returns two 2D centroids representing the distribution of the data set. A B-RAM IP-core is implemented internally to store and operate upon the data set. The implementation performs integer-division and provides integer-level precision. A validation script in python has been provided to compute the centroids of the data set and compare them with the ones returned by the FPGA.  

## Description of the common modules

### General configuration
* The 'Board' directory houses the VHDL/Verliog codes as well as the design constraints (for Digilent Basys3 board) of the implementation for the FPGA board. To reuse the code, please be sure to use an appropriate constraints file suitable for your device.  
* The 'Computer' directory houses the C/C++ codes to implement a UART terminal on the computer and communicate with the FPGA-based implementation module. Shell scripts have also been provided to scan for ports as well as to build, link and run the codes using gcc and g++ compilers.  
* A summary of the execution of each of the implementations is provided in the corresponding transcript document.

### UART
* This design implements an 8-bit UART with one start bit (active low), one stop bit (active high) and no parity bits. 10 bits per packet.
* Code for the implementation of a UART terminal on the computer as well as the FPGA have been provided.
* Baud rate is flexible and needs to be declared in the files: Board/UART.vhd (line 15) and Computer/Transceiver.cpp (line 17).

### FSM-based design
* Each module has been designed as a Finite State Machine which is driven by the internal state signals, inputs and the clock.
* The design includes multiple nested state signals which drive specific functionality and help in debugging.
* Each module has a default state to begin with. The RESET signal brings all the internal state signals to this default state.

## Attributions and Licensing:
This project relies heavily on the codes from the authors Sebastien Bourdeauducq and Teunis van Beelen, which are available in the public domain under the GNU GPL version 3.

Therefore, this repository also falls under the licensing terms of GNU GPL version 3 (see LICENSE).

The implementations relying on Block-RAMs (BRAMs) depend on the True Dual-Port BRAM IP-Core provided by Xilinx (VLNV: xilinx.com:ip:blk_mem_gen:8.4). 
