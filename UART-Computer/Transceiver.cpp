//  Author: Amey.

#ifdef _WIN32
#include <Windows.h>
#else
#include <unistd.h>
#endif

#include "RS232_UART.h"
#include <iostream>
using namespace std;

#define COMPORT 5
#define BAUD 9600
#define ZZZ 50	//Sleep duration in ms.

unsigned int recvInt32();
void sendInt32(unsigned int);

int main()
{
	if (RS232_OpenComport(COMPORT, BAUD, "8N1"))		//Set mode here.
	{
		printf("Communication Port unavailable!\n");
		return(0);
	}
	while(true)	//Exit using interrupt.
	{
		unsigned int tx, rx;
		cin >> tx;
		sendInt32(tx);
		cout << "Sent integer: " << tx << endl;
		rx = recvInt32();
		cout << "Received integer: " << rx << endl;
	}
	RS232_CloseComport(COMPORT);
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
		#ifdef _WIN32
			Sleep(ZZZ);
		#else
			usleep(ZZZ * 1000);  // sleep for some ms
		#endif
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
		#ifdef _WIN32
			Sleep(ZZZ);
		#else
			usleep(ZZZ * 1000);  // sleep for some ms
		#endif
	}
}
