#!/usr/bin/python
import sys
import zmq
import time
import getopt
import random 

#Help Function
def usage():
    print "Options:"
    print "  -d, --destination           sets the destination ip-address which is to be used for the zmq"
    print "                              transmissions"
    print "  -f, --file                  sets the source file which data is going to be transmitted "
    print "  -h, --help                  display help message and exit"
    print "  -i, --interval              sets the waiting intervall time in seconds between the transmissions"  
    print "  -m, --min                   sets the minimum waiting time in seconds which is allowed between the"
    print "                              transmissions"
    print "  -p, --port                  sets the port number which is to be used for the zmq transmissions"
    print "  -x, --max                   sets the minimum waiting time in seconds which is allowed between the"
    print "                              transmissions"
    return

#Random Generator
def genrand(tmin, tmax):
    result = random.uniform(float(tmin), float(tmax))
    return result

#Look for input paramaters    
try:
    opts, args = getopt.getopt(sys.argv[1:], 'm:x:d:p:F:i:h', ['min=', 'max=', 'destination=', 'port=', 'File=', 'interval=', 'help'])
except getopt.GetoptError:
    usage()
    sys.exit(2)
    
#Read values of input parameters
for opt, arg in opts:
    if opt in ('-h', '--help'):
        usage()
        sys.exit(2)
    elif opt in ('-m', '--min'):
        p_min = arg
    elif opt in ('-x', '--max'):
        p_max = arg
    elif opt in ('-d', '--destination'):
        p_dest = arg
    elif opt in ('-p', '--port'):
        p_port = arg
    elif opt in ('-F', '--File'):
        p_file = arg
    elif opt in ('-i', '--interval'):
        p_interval = arg
    else:
        usage()
        sys.exit(2)
 
#Throw error if file is not handed over
if 0 == dir().count('p_file'):
    print "Mandatory parameter --File <file-name> is missing."    
    usage()
    sys.exit(2)
#Throw error if destination is not handed over 
if 0 == dir().count('p_dest'):
    print "Mandatory parameter --destination <ip-address> is missing."    
    usage()
    sys.exit(2)
#Throw error if port is not handed over 
if 0 == dir().count('p_port'):
    print "Mandatory parameter --port <number> is missing."    
    usage()
    sys.exit(2)
#Set default value for p_interval
if 0 == dir().count('p_interval'):
    p_interval = -1
#Set default value for p_min
if 0 == dir().count('p_min'):
    p_min = 0
#Set default value for p_max
if 0 == dir().count('p_max'):
    p_max = 0

#Open connection to zmq client at the desired destination   
context = zmq.Context()
zmq_socket = context.socket(zmq.PUSH)
zmq_socket.connect("tcp://" + p_dest + ":" + p_port)     

#Read in file line for line and push every line after a random timeout to the destination
fobj = open(p_file)

for line in fobj:
    zmq_socket.send(line.rstrip())
    if p_interval < 0:
        time.sleep(genrand(p_min, p_max))
    else:
        time.sleep(float(p_interval))
        
fobj.close()
 
sys.exit(0)