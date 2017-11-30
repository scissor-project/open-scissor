#!/usr/bin/python
import sys
import zmq
import getopt

#Help Function
def usage():
    print "Options:"
    print "  -h, --help                  display help message and exit"
    print "  -p, --port                  sets the port number for listening to potential zmq transmissions"
    print "  -s, --source                sets the source ip-address for the incoming zmq transmissions"
    return

try:
    opts, args = getopt.getopt(sys.argv[1:], 'p:s:h', ['port=', 'source=', 'help'])
except getopt.GetoptError:
    usage()
    sys.exit(2)
    
#Read values of input parameters
for opt, arg in opts:
    if opt in ('-h', '--help'):
        usage()
        sys.exit(2)
    elif opt in ('-p', '--port'):
        p_port = arg
    elif opt in ('-s', '--source'):
        p_source = arg
    else:
        usage()
        sys.exit(2)

#Throw error if source is not handed over 
if 0 == dir().count('p_source'):
    print "Mandatory parameter --source <ip-address> is missing."    
    usage()
    sys.exit(2)
#Throw error if port is not handed over 
if 0 == dir().count('p_port'):
    print "Mandatory parameter --port <number> is missing."    
    usage()
    sys.exit(2)

#Listen on the desired Port
context = zmq.Context()
sock = context.socket(zmq.PULL)
sock.bind("tcp://" + p_source + ":" + p_port)

#Print messages to console
while True:
    message= sock.recv()
    print message