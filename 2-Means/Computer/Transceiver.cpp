//  Author: Amey.

#ifdef _WIN32
#include <Windows.h>
#else
#include <unistd.h>
#endif

#include "RS232_UART.h"
#include <iostream>
#include <string>
#include <vector>
#include<fstream>
using namespace std;

#define COMPORT 17						// Check this page to determine the COMPORT: https://www.teuniz.net/RS-232/
#define BAUD 9600
#define ZZZ 75	//Sleep duration in ms.
unsigned int recvInt32();
void sendInt32(unsigned int);

													// Comments marked [W] are needed for testing the code in Visual Studio.

int main()
{
	if (RS232_OpenComport(COMPORT, BAUD, "8N1"))		//Set mode here.
	{
		printf("Communication Port unavailable!\n");
		cin.ignore();
		return(0);
	}
	
	
	cout << "\t\tK-MEANS CLUSTERING IMPLEMENTATION OVER FPGA.\n\nPress ENTER to begin.\n";
	cin.ignore();
	//cin >> n;

	cout << "\nLoading dataset...\nSr.no.\tCo-ordinates\n";
	std::ifstream dataset("CustomData.dat", std::ifstream::in);
	
	//Dump column headers.
	string dump;
	dataset >> dump;
	dataset >> dump;

	std::vector<unsigned int> tx;
	for(int i = 1; !dataset.eof(); i++)
	{
		unsigned int x, y;
		dataset >> x;
		dataset >> y;
		cout << i << "\t(" << x << ", " << y << ")\n";
		tx.push_back(x);
		tx.push_back(y);
	}

	dataset.close();

	unsigned int *C, n = tx.size() / 2;
	C = new unsigned int[4];

	cout << "\nTransmitting the size of the dataset: " << n << endl;
	sendInt32(n);

	cout << "Transmitting the dataset...\n";
	for (auto i = tx.begin(); i != tx.end(); i++)
		sendInt32(*i);


	cout << "\nReceiving cluster centroids...\n";
	for (unsigned int i = 0; i < 4; i++)
		C[i] = recvInt32();

	RS232_CloseComport(COMPORT);
	
	cout << "C1: (" << C[0] << ", " << C[1] << ")\n";
	cout << "C2: (" << C[2] << ", " << C[3] << ")\n";
	cout << "\nClustering Completed.\n";
	
	//The following code writes the centroids into the file "centroids.dat" in order to pass them to other modules.
	std::ofstream result("centroids.dat", std::ofstream::out | std::ofstream::trunc);
	result << C[0] << "\t" << C[1] << "\n" << C[2] << "\t" << C[3];
	result.close();

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

	//DEBUG...
	//cout << rx << "\n";
	
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
		/*#ifdef _WIN32
			Sleep(ZZZ);
		#else
			usleep(ZZZ);  // sleep for some ms
		#endif
		*/
	}
}