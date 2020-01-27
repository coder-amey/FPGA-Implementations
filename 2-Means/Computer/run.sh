#Compile and load the dependencies.
gcc -c  -o UARTlib.o RS232_UART.c
g++ -c -o Transceiver.o Transceiver.cpp
g++ -o UART.out Transceiver.o UARTlib.o 

#Run the transceiver.
./UART.out

#Compare and plot the obtained centroids using python.
python3 KMeans.py

#Cleanup.
rm centroids.dat Transceiver.o UARTlib.o UART.out