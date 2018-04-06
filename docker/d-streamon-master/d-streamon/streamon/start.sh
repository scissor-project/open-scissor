#! /bin/bash

input="$1"

#id="$2"

if [ -z "$input" ]; then
    echo "No input file specified."
    exit 1
fi

cd scripts || exit

prefix=""

if [ "${input:0:1}" != '/' ];
then
	prefix="../"
fi

rm -f botstream.xml values.txt

python2 moin.py "$prefix$input" "$2"

res=$?

if [ $res != 0 ];
then
    echo 'Python script error, check input file (if exists)'
    exit
fi

mkdir -p ../packet/

mv -f botstream.xml ../packet/

mv -f values.txt ../packet/

cd ..

cp blockmon packet

rm -f FeatureLib.so

g++ -fPIC -shared -std=c++11 -Icore -Imessages -Ilib -Ilib/fc scripts/featurelib.cpp -o packet/FeatureLib.so

res=$?

if [ $res != 0  ]
then
    echo 'Compile error, check ' "$input" 'file'
    exit 1
fi

cd packet || exit

if [ -e alone.tar ]
then
    rm alone.tar
fi

tar -cvf alone.tar blockmon FeatureLib.so botstream.xml values.txt

echo "Packet Ready."
