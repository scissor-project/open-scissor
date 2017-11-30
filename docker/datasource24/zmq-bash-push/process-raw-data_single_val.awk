BEGIN {
	param[2] = "RSSI"
	param[3] = "T"
	param[4] = "S1"
	param[5] = "S2"
	param[6] = "RSSI"
	param[7] = "RSSI"
	param[8] = "T"
	param[9] = "S2"
	param[10] = "RSSI"
	param[11] = "S1"
	param[12] = "S1"
	param[13] = "T"

	host = "host1"

	ant[1] = "Ant1"
	ant[2] = "Ant2"
	ant[3] = "Ant3"
	ant[0] = "Ant4"

	tag[2] = "F3F3F3F3F3F3F3F3F3F3F3F3"
	tag[3] = "22222222222222222222"
	tag[4] = "666666666666666666666"
	tag[5] = "666666666666666666666"
	tag[6] = "F8F8F8F8F8F8F8F8F8F8F8F8"
	tag[7] = "F1F1F1F1F1F1F1F1F1F1F1F1"
	tag[8] = "444444444444444444444"
	tag[9] = "444444444444444444444"
	tag[10] = "A2A2A2A2A2A2A2A2A2A2A2A2"
	tag[11] = "33333333333333333333"
	tag[12] = "555555555555555555555"
	tag[13] = "110110110110110110110"

}

# TS HOST READER F3F3F3 RSSI=-69
# TS HOST READER 2222 T=20
# TS HOST READER 6666 S1=X S2=Y

NR > 2 {
	#print "numFields: " NF
	prefix=$1 " " host " " ant[(NR-2)%4]
	new_line=1

	for (i = 2; i <= NF; i++) {
		if ($i != 0 && $i != -1000) {
			if (i == 2) {
				output = prefix " " tag[i] " " param[i] "=" $i
				print output
			} else {  
				output = prefix " " tag[i] " " param[i] "=" $i
				print output
			}
		}
	}
}
