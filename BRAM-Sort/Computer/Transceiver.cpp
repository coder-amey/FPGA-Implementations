//  Author: Amey.

#ifdef _WIN32
#include <Windows.h>
#else
#include <unistd.h>
#endif

#include "RS232_UART.h"
#include <iostream>
#include <string>
using namespace std;

#define COMPORT 5
#define BAUD 9600
#define ZZZ 75	//Sleep duration in ms.

unsigned int recvInt32();
void sendInt32(unsigned int);

int main()
{
	if (RS232_OpenComport(COMPORT, BAUD, "8N1"))		//Set mode here.
	{
		printf("Communication Port unavailable!\n");
		return(0);
	}
	
	unsigned int n, *tx, *rx;
	cin >> n;
	sendInt32(n);
	cout << "Sending size: " << n << endl;

	tx = new unsigned int[n];
	rx = new unsigned int[n];

	cout << "Sending array:\n";
	
	for (int i = 0; i < n; i++)
	{
		//cin >> tx[i];
		tx[i] = rand();
		sendInt32(tx[i]);
		cout << tx[i] << "\t";
	}

	cout << "\n\nReceiving sorted array:\n";
	for (unsigned int i = 0; i < n; i++)
	{
		rx[i] = recvInt32();
		cout << rx[i] << "\t";
	}
	RS232_CloseComport(COMPORT);
	for (int i = 0; i < n-1; i++)
	{
		if (rx[i] > rx[i+1])
			cout << "\nError!\tArray mismatch at position: " << i + 1 << ".\n";
	}
	cout << "\nArray traversal complete.\n";

	cin.ignore();
	cin.ignore();
	return(0);
}

unsigned int recvInt32()
{
	unsigned char *buffer = new unsigned char[1];
	unsigned int rx, n;
	rx = n = 0;
	while (n < 4)
	{
		int i = RS232_PollComport(COMPORT, buffer, 1);

		if (i > 0)
		{
			unsigned int x = (unsigned int) *buffer;
			rx += (x <<= (n * 8));
			n++;
			
			//DEBUG...
		//printf("Receiving... %x (%c)\n", rx, rx);
		}
		/*
		#ifdef _WIN32
			Sleep(ZZZ);
		#else
			usleep(ZZZ * 1000);  // sleep for some ms
		#endif
		*/
	}
	return(rx);
}

void sendInt32(unsigned int tx)
{
	for (int i = 0; i < 4; i++)
	{
		unsigned char buffer = (unsigned char) (tx & 255);
		tx = tx >> +8;
		//DEBUG...
		//printf("Sending... %x(%c)\n", buffer, buffer);
		if (RS232_SendByte(COMPORT, buffer))
		{
			cout << "Error while transmitting!" << endl;
			return;
		}
		/*
		#ifdef _WIN32
			Sleep(ZZZ);
		#else
			usleep(ZZZ * 1000);  // sleep for some ms
		#endif
		*/
	}
}