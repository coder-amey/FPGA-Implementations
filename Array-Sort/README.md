# Array-Sort

## Introduction:
This design performs sorting on a variable-size array of 32-bit (unsigned) integers received from the computer and writes back the sorted array.

## Dependencies
* UART transceiver core module: uart_transceiver.v (Sebastien Bourdeauducq)
* RS-232 driver module: RS232_UART.c & RS232_UART.h (Teunis van Beelen)

## Implementation Details
* All the numbers are in a 32-bit unsigned integer format and are represented as std_logic_vectors (except for the internal variables) within the FSMs.

### Input
* The first input to the programme is the size of the array (*n*).
* This is followed by *n* values corresponding to the elements of the array.

### Output
* The output consists of a sequence of *n* values representing the sorted array.

### Modular Organization
* The Int32CommUtil (Communications and Utility for 32-bit integer processing) module is the primary FSM which drives the functionality of the programme and it instantiates the modules of the other entities, viz. UART and Int32ArrSort.
* The UART module interfaces the UART Transceiver Module with the Driver module and debounces the signal that may interfere with the transmission.
* The Int32ArrSort module is the process block which implements the **selection sort algorithm**.
* As the size of the array is not pre-defined, the driver module must communicate with the process module to transfer the unsorted array for processing. The Driver and the Process modules use a message-acknowledge protocol to communicate with each other. There are dedicated lines for 32-bit data signals and acknowledgement signals, between the two modules, from the driver to the process block and vice-versa. The integer values are passed through the respective channel, one at a time. The next value is sent once an acknowledgement signal is received from the other module. The sorted array is returned to the driver module in the same manner.
* In the default state, the Int32CommUtil driver activates the UART module and waits for input. It reads the size, instantiates an array of std_logic_vector of the specified size, and stores the following received input into the array.
* Once the array has been recorded, it activates the process block (Int32ArrSort module) and communicates with it to transfer the array for processing. Once the array has been transferred, it waits for the process block to finish processing and send the sorted array.
* The Int32ArrSort module implements the selection sort algorithm on the array. The sorting is done in-place and the sorted array is communicated back to the driver module.
* In the final state, the driver module reads the array from the process block and serially tranmits it over the UART transceiver to the computer.
* The programme running on the computer randomly generates an array of a given size and feeds it to the FPGA board over the UART transceiver. It also verifies that the array obtained from the FPGA board is in a sorted order.
