//  Author: Amey.

#ifdef _WIN32
#include <Windows.h>
#else
#include <unistd.h>
#endif

#include "RS232_UART.h"
#include <iostream>
using namespace std;

//For various COMPORT numbers, possible baud rates and modes refer: https://www.teuniz.net/RS-232/
#define COMPORT 17
#define BAUD 9600

unsigned int recvInt32();
void sendInt32(unsigned int);

int main()
{
	if (RS232_OpenComport(COMPORT, BAUD, "6E2"))		//Set mode here.
	{
		printf("Communication Port unavailable!\n");
		return(0);
	}
	
	sendInt32(137);
	unsigned int rx = recvInt32();

	cout << "Received integer: " << rx << endl;
	RS232_CloseComport(COMPORT);
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
			printf("Receiving... %x (%c)\n", rx, rx);
		}
		#ifdef _WIN32
			Sleep(100);
		#else
			usleep(100000);
		#endif
	}
	return(rx);
}

void sendInt32(unsigned int tx)
{
	unsigned char unable_to_read[] = "cefijloqrtwx";
	for (int i = 0; i < 12; i++)
	{
		unsigned char buffer = (unsigned char) (tx & 255);
		tx = tx >> +8;
    
		//DEBUG...
		printf("Sending... %x(%c)\n", unable_to_read[i], unable_to_read[i]);
		
		if (RS232_SendByte(COMPORT, unable_to_read[i]))
		{
			cout << "Error while transmitting!" << endl;
			return;
		}
		#ifdef _WIN32
			Sleep(100);
		#else
			usleep(100000);
		#endif
		cin.ignore(); //Wait to cross-check output on the FPGA.
	}
}
