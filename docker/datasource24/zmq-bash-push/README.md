# ZeroMQ Test Scripts

This Repository provides a set of scripts for sending messages mostly in the form of text files and logs with the help of the ZeroMQ protocol over the network.

## zmq-send-log

The script zmq-send-log.py reads the provided file line for line in and sends every line according to the timestamps which are to be found in the file itself over the network.
To process longer files for testing purposes in a shorter period of time there is the option to speed up the waiting period between the transmissions. For more detailed information see below in the subitem usage.

### Usage

The following parameters are available when calling the script:

* Destination
`-d, --destination` *(mandatory)*  
sets the destination ip-address which is to be used for the ZMQ transmissions

* Format
`-f, --format` *(optional)*  
Sets the format mask for the timestamp which is going to be interpreted. The following options are available:  
  * `apache`  -> Apache Server timestamp  *[EEE MMM dd hh:mm:ss yyyy]*
  * `B`       -> Data Big-Endian          *yyyy.MM.dd hh:mm:ss*
  * `L`       -> Date Little-Endian       *dd.MM.yyyy hh:mm:ss*
  * `sensors` -> Custom sensor timestamp  *MMM dd hh:mm:ss*

* File
`-F, --File` *(mandatory)*            
Sets the path for the source file which data is going to be transmitted

* Help
`-h, --help`                  
Display help message and exit

* Header
`-H, --Header` *(optional)*  
Sets flag for supporting outputting files with header row. This is recommended when the first row of the file does not contain any timestamps but instead e.g. the column definitions   

* Port
`-p, --port` *(mandatory)*              
Sets the port number which is to be used for the ZMQ transmissions

* Speed
`-s, --speed` *(optional)*         
Sets the speed factor in which the script should be executed. This factor can be any decimal number:
1 = normal speed, 2 = double speed, 0.5 = half speed 


A possible script call could look like this:

```shell
./zmq-send-log.py -F log_environment-sensors -d logstash -p 8888 -f sensor -s 2
```

## zmq-send-random

The script zmq-send-random.py reads the provided file line for line in and sends every line after a random generated waiting time over the network.
There is also an fixed interval mode available. This script should be used for new files where there is yet no format mask for the correct parsing available. For more detailed information see below in the subitem usage.

### Usage

The following parameters are available when calling the script:

* Destination
`-d, --destination` *(mandatory)*  
Sets the destination ip-address which is to be used for the ZMQ transmissions  

* File
`-F, --File` *(mandatory)*    
Sets the path for the source file which data is going to be transmitted

* Help
`-h, --help` 
Display help message and exit  

* Interval
`-i, --interval` *(optional)*  
Sets the waiting intervall time in seconds between the transmissions

* Minimum waiting time
`-m, --min` *(optional)*  
Sets the minimum waiting time in seconds which is allowed between the transmissions

* Port
`-p, --port` *(mandatory)*  
Sets the port number which is to be used for the ZMQ transmissions

* Maximum waiting time
`-x, --max` *(optional)*  
Sets the minimum waiting time in seconds which is allowed between the transmissions 


A possible script call could look like this:

```shell
./zmq-send-random.py -F log_environment-sensors -d logstash -p 8888 -m 0.5 -x 3
```

## zmq-listen

The script zmq-send-listen.py provides a simple ZMQ listener which outputs every incoming message to the console. It is primary used for debugging during the development process of the other python scripts.
For more detailed information see below in the subitem usage.

### Usage

The following parameters are available when calling the script:

* Help
`-h, --help`                  
Display help message and exit  

* Port
`-p, --port` *(mandatory)*  
Sets the port number for listening to potential ZMQ transmissions

* Source
`-s, --source` *(mandatory)*  
Sets the source ip-address for the incoming ZMQ transmissions


A possible script call could look like this:

```shell
./zmq-listen.py -s logstash -p 8888
```

## zmq-bash-push (deprecated)

Very simple script to send ZeroMQ messages on the Linux command line

Based on the example by Daniel Lundin http://zeromq.org/bindings:bash, just rearranged to read stdin.

### Usage

    echo hello world! |./zmq-push.sh localhost 8080

Or send a file (one message per line). Be carefull not to send lines longer than 255 bytes.

    cat README.md |./zmq-push.sh localhost 8080

It sends each line read from stdin to a PULL socket listening on port 8080
