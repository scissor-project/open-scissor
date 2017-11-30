#!/bin/bash

if [ $# -ne 1 ]
then
    echo "usage: $0 file"
    echo "e.g. $0 env-favignana/Test_new_format_10_events.txt"
    exit 1
fi

FILE=$1

awk '{print $5}' "$FILE" | sort -n | uniq -c
