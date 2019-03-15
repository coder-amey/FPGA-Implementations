gcc -c  -o UARTlib.o RS232_UART.c
g++ -c -o Transceiver.o Transceiver.cpp
g++ -o UART.out Transceiver.o UARTlib.o 
./UART.out
