//
//  Message generator in C++
//  Binds PUB socket to tcp://*:8892
//
#include <zmq.hpp>
#include <stdio.h>
#include <iostream>
#include <unistd.h>
#include <string>
#include <time.h>

using namespace std;

const char* REMOTE_CAMERA_IP = "http://192.168.1.104:80/mjpg/video.mjpg";
const int NUMBER_OF_EVENTS = 6;
const int MAX_INTERVAL_TIME = 5;		// in seconds
char texts[NUMBER_OF_EVENTS][35] = {"Person entered a restricted area",
									"Person left a restricted area",
									"Light on",
									"Light off",
									"Camera covered",
									"Camera moved"};
char types[NUMBER_OF_EVENTS][16] = {"person",
									"light",
									"cam_cov",
									"cam_move"};

int main ()
{
    //  Prepare our context and PUB socket
    zmq::context_t context (1);
    zmq::socket_t socket (context, ZMQ_PUB);
    socket.bind ("tcp://*:8892");

	int event, interval;
	char timestamp [128];
	char snapshot_time [128];
	char snapshot_type [16];
	char snapshot [128];
	srand(time(NULL));
	
    while (1)
	{
		event = rand() % NUMBER_OF_EVENTS + 1;		// random event choosing
		//cout << "Event: " << event << endl;

		time_t rawtime;
		struct tm * timeinfo;
	
		time (&rawtime);
		timeinfo = localtime (&rawtime);
		
		strftime (timestamp, 32, "%d %b %G %H:%M:%S", timeinfo);
		strftime (snapshot_time, 64, "/snapshot/%Y%m%d_%H%M%S", timeinfo);
		
		switch(event)
		{
			case 1:
			case 2:		snprintf(snapshot_type, 16, "%s", types[0]);
						break;
			case 3:
			case 4:		snprintf(snapshot_type, 16, "%s", types[1]);
						break;
			case 5:		snprintf(snapshot_type, 16, "%s", types[2]);
						break;
			case 6:		snprintf(snapshot_type, 16, "%s", types[3]);
						break;
		}
		
		snprintf(snapshot, 128, "%s-%s", snapshot_time, snapshot_type);
  		char msg_string [256];
		int len;
        	len=sprintf (msg_string, "%s 1 %d info \"%s\" confidence=0.8 zoom=3 rotation=0 live-video-url=%s snapshot-path=%s", timestamp, event, texts[event-1], REMOTE_CAMERA_IP, snapshot);
        	zmq::message_t message(len);
        	snprintf ((char *) message.data(), len, "%s", msg_string);
        //snprintf ((char *) message.data(), 256, "%s 1 %d info \"%s\" confidence=0.8 zoom=3 rotation=0 live-video-url=%s snapshot-path=%s", timestamp, event, texts[event-1], REMOTE_CAMERA_IP, snapshot);
		//cout << (char *) message.data() << endl;
		socket.send(message);
		interval = rand() % MAX_INTERVAL_TIME + 1;					// random interval choosing
		//cout << "Interval: " << interval << " s" << endl;
		sleep(interval);
    }
    return 0;
}
