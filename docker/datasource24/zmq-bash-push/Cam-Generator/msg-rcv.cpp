//
//  Message receiver in C++
//  Connects SUB socket to tcp://localhost:8892
//
#include <zmq.hpp>
#include <string>
#include <iostream>
#include <time.h>

using namespace std;

int main () {
    //  Prepare our context and PUB socket
    zmq::context_t context (1);
    zmq::socket_t socket (context, ZMQ_SUB);
    socket.connect ("tcp://localhost:8892");

	const char *filter = "1";
    socket.setsockopt(ZMQ_SUBSCRIBE, filter, strlen (filter));
	
    while (1)
	{
        zmq::message_t message;

		socket.recv(&message);
		
		cout << static_cast<char*>(message.data()) << endl;
    }
    return 0;
}
