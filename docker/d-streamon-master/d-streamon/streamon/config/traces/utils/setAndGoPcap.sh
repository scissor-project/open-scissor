#! /bin/bash

if [ -z "$1" ]; then
  echo
  echo "usage: $0 [INTERFACE] [IP-SOURCE] [IP-DEST] [MAC-SOURCE] [MAC-DEST]"
  echo
  echo "e.g. $0 eth0 10.0.0.100 10.0.0.101 9c:b6:d0:d1:83:71 08:00:27:38:0c:46 file.pcap"
  echo
  exit
fi
if [ -z "$2" ]; then
  echo
  echo "usage: $0 [INTERFACE] [IP-SOURCE] [IP-DEST] [MAC-SOURCE] [MAC-DEST] [FILE]"
  echo
  echo "e.g. $0 eth0 10.0.0.100 10.0.0.101 9c:b6:d0:d1:83:71 08:00:27:38:0c:46 file.pcap"
  echo
  exit
fi
if [ -z "$3" ]; then
  echo
  echo "usage: $0 [INTERFACE] [IP-SOURCE] [IP-DEST] [MAC-SOURCE] [MAC-DEST] [FILE]"
  echo
  echo "e.g. $0 eth0 10.0.0.100 10.0.0.101 9c:b6:d0:d1:83:71 08:00:27:38:0c:46 file.pcap"
  echo
  exit
fi
if [ -z "$4" ]; then
  echo
  echo "usage: $0 [INTERFACE] [IP-SOURCE] [IP-DEST] [MAC-SOURCE] [MAC-DEST] [FILE]"
  echo
  echo "e.g. $0 eth0 10.0.0.100 10.0.0.101 9c:b6:d0:d1:83:71 08:00:27:38:0c:46 file.pcap"
  echo
  exit
fi
if [ -z "$5" ]; then
  echo
  echo "usage: $0 [INTERFACE] [IP-SOURCE] [IP-DEST] [MAC-SOURCE] [MAC-DEST] [FILE]"
  echo
  echo "e.g. $0 eth0 10.0.0.100 10.0.0.101 9c:b6:d0:d1:83:71 08:00:27:38:0c:46 file.pcap"
  echo
  exit
fi
if [ -z "$6" ]; then
  echo
  echo "usage: $0 [INTERFACE] [IP-SOURCE] [IP-DEST] [MAC-SOURCE] [MAC-DEST] [FILE]"
  echo
  echo "e.g. $0 eth0 10.0.0.100 10.0.0.101 9c:b6:d0:d1:83:71 08:00:27:38:0c:46 file.pcap"
  echo
  exit
fi

tcpprep --port --cachefile=example.cache --pcap="$6"

tcprewrite --endpoints="$2":"$3" --enet-dmac="$5","$4" --enet-smac="$4","$5"  --cachefile=example.cache --infile="$6" --outfile=new.pcap

tcpreplay --intf1="$1" new.pcap
