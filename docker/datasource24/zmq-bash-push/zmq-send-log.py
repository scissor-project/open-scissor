#!/usr/bin/python
import sys
import zmq
import time
import datetime
import getopt

#Help Function
def usage():
    print "Options:"
    print "  -d, --destination           sets the destination ip-address which is to be used for the zmq"
    print "                              transmissions"
    print "  -f, --format                sets the format maskt fot the timestamp which is going to be interpreted"
    print "                              The following options are currently available:" 
    print "                                 apache  -> Apache Server timestamp    [EEE MMM dd hh:mm:ss yyyy]"
    print "                                 B       -> Date Big-Endian            yyyy.MM.dd hh:mm:ss"
    print "                                 L       -> Date Little-Endian         dd.MM.yyyy hh:mm:ss"
    print "                                 sensors -> Custom sensor timestamp    MMM dd hh:mm:ss"
    print "                                 time    -> Custom time only timestamp hh:mm:ss,fff"
    print "                                 envtime -> Custom time used in SCISSOR dd.MM.yyyy hh:mm:ss,fff"
    print "  -F, --File                  sets the source file which data is going to be transmitted"
    print "  -h, --help                  display help message and exit"
    print "  -H, --Header                sets flag for supporting outputting files with header row"
    print "  -p, --port                  sets the port number which is to be used for the zmq transmissions"
    print "  -s, --speed                 sets the speed factor in which the script should be executed:"
    print "                              e.g. 1 = normal speed, 2 = double speed, 0.5 = half speed" 
    return

#Calculate sleep time
def calctime(line1, line2, tformat):
    
    if tformat == "L":
        #extract only the timestamp of the line 
        line1 = line1[:19]
        line2 = line2[:19] 
        
        #parse string to datetime, Mask is dd.MM.yyyy hh:mm:ss
        start = datetime.datetime.strptime(line1, "%d.%m.%Y %H:%M:%S")
        end = datetime.datetime.strptime(line2, "%d.%m.%Y %H:%M:%S")
    elif tformat == "B":
        #extract only the timestamp of the line 
        line1 = line1[:19]
        line2 = line2[:19] 
        
        #parse string to datetime, Mask is yyyy.MM.dd hh:mm:ss
        start = datetime.datetime.strptime(line1, "%Y.%m.%d %H:%M:%S")
        end = datetime.datetime.strptime(line2, "%Y.%m.%d %H:%M:%S")
    elif tformat == "apache":
         #extract only the timestamp of the line 
        line1 = line1[:26]
        line2 = line2[:26] 
        
        #parse string to datetime, Mask is aaa EEE MMM dd hh:mm:ss yyyy
        start = datetime.datetime.strptime(line1, "[%a %b %d %H:%M:%S %Y]")
        end = datetime.datetime.strptime(line2, "[%a %b %d %H:%M:%S %Y]")
    elif tformat == "sensor":
        #extract only the timestamp of the line 
        line1 = line1[:15]
        line2 = line2[:15] 
        
        #parse string to datetime, Mask is MMM dd hh:mm:ss
        start = datetime.datetime.strptime(line1, "%b %d %H:%M:%S")
        end = datetime.datetime.strptime(line2, "%b %d %H:%M:%S")
    elif tformat == "time":
        #extract only the timestamp of the line 
        line1 = line1[:12]
        line2 = line2[:12] 
        
        #parse string to datetime, Mask is hh:mm:ss.fff
        start = datetime.datetime.strptime(line1, "%H:%M:%S,%f")
        end = datetime.datetime.strptime(line2, "%H:%M:%S,%f")
    elif tformat == "envtime":
        #extract only the timestamp of the line 
        line1 = line1[:23]
        line2 = line2[:23] 
        
        #parse string to datetime, Mask is dd.MM.yyyy hh:mm:ss,fff
        start = datetime.datetime.strptime(line1, "%d.%m.%Y %H:%M:%S,%f")
        end = datetime.datetime.strptime(line2, "%d.%m.%Y %H:%M:%S,%f")
    elif tformat == "newenv":
        #extract only the timestamp of the line 
        line1 = line1.split()
        line2 = line2.split() 
	line1 = line1[1]
	line2 = line2[1]
        line1 = line1.split("+")
        line2 = line2.split("+")
	line1 = line1[0]
	line2 = line2[0]
        
        #parse string to datetime, Mask is dd.MM.yyyy hh:mm:ss,fff
        start = datetime.datetime.strptime(line1, "%Y-%m-%dT%H:%M:%S.%f")
        end = datetime.datetime.strptime(line2, "%Y-%m-%dT%H:%M:%S.%f")
   
    else:
        print "Entered paramter for --format <format> is not supported"    
        usage()
        sys.exit(2)
    
    #get delta t from start and end in seconds
    result = (end - start).total_seconds()
    return result

#Look for input paramaters    
try:
    opts, args = getopt.getopt(sys.argv[1:], 'd:p:f:F:s:h:H', ['destination=', 'port=', 'format=', 'File=', 'speed=', 'help', 'Header'])
except getopt.GetoptError:
    usage()
    sys.exit(2)
    
#Read values of input parameters
for opt, arg in opts:
    if opt in ('-h', '--help'):
        usage()
        sys.exit(2)
    elif opt in ('-d', '--destination'):
        p_dest = arg
    elif opt in ('-p', '--port'):
        p_port = arg
    elif opt in ('-f', '--format'):
        p_format = arg
    elif opt in ('-F', '--File'):
        p_file = arg
    elif opt in ('-H', '--Header'):
        p_header = 1
    elif opt in ('-s', '--speed'):
        p_speed = arg
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
 #Set default value for p_speed
if 0 == dir().count('p_speed'):
    p_speed = 1
 #Set default value for p_format
if 0 == dir().count('p_format'):
    p_format = "sensor"
#Set default value for p_header
if 0 == dir().count('p_header'):
    p_header = 0
 
#Open connection to zmq client at the desired destination   
context = zmq.Context()
zmq_socket = context.socket(zmq.PUSH)
zmq_socket.connect("tcp://" + p_dest + ":" + p_port)     

#Define flag and counter
counter = 0
isFirstRound = 1

#Read in file line for line and push every line according to the delta t of the next line to the destination
fobj = open(p_file)
for line in fobj:
    
    #It is needed to read in three lines bevor starting to send
    if isFirstRound == 1:
        if p_header == 1:    
            if counter < 1:
                #Get header line
                firstLine = line.rstrip()
                
                #Send header line only if not empty
                if firstLine and not firstLine.isspace():
                    zmq_socket.send(firstLine)
                    counter += 1
            elif counter < 2:
                #Get first data line
                firstLine = line.rstrip()
                
                #Only if not empty count up
                if firstLine and not firstLine.isspace():
                    counter += 1
            else:
                #Get second data line
                secondLine = line.rstrip()
                
                #Only if not empty count up
                if secondLine and not secondLine.isspace():
                    counter += 1
                    isFirstRound = 0
            
            #Two data lines have been read out -> clear to send first data line 
            if counter == 3:
                
                #Check if firstLine is Empty
                zmq_socket.send(firstLine)
                twait = (calctime(firstLine, secondLine, p_format) / float(p_speed))
                    
                time.sleep(twait)
                firstLine = secondLine
        else:
            if counter < 1:
                #Get first data line
                firstLine = line.rstrip()
                
                #Only if not empty count up
                if firstLine and not firstLine.isspace():
                    counter += 1
            else:
                #Get second data line
                secondLine = line.rstrip()
                
                #Only if not empty count up
                if secondLine and not secondLine.isspace():
                    counter += 1
                    isFirstRound = 0
            
            #Two data lines have been read out -> clear to send first data line 
            if counter == 2:
                
                zmq_socket.send(firstLine)
                twait = (calctime(firstLine, secondLine, p_format) / float(p_speed))
                    
                time.sleep(twait)
                firstLine = secondLine
    else:
       #After first round normal flow -> compare and send
       
       secondLine = line.rstrip()
      
       #Send only if both lines are not empty
       if firstLine and not firstLine.isspace() and secondLine and not secondLine.isspace():
       
           zmq_socket.send(firstLine)
           twait = (calctime(firstLine, secondLine, p_format) / float(p_speed))  
           
           time.sleep(twait)
       
           #Move up lines
           firstLine = secondLine
       else:
           #If first line is empty move up lines
           if secondLine and not secondLine.isspace():
               firstLine = secondLine
               
#Transmit last line -> no time calculation is neeeded
zmq_socket.send(firstLine)

#Close file object      
fobj.close()

#Exit success
sys.exit(0)
