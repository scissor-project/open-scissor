BEGIN {
	paramA[2] = "Sensor2"
	paramA[3] = "RSSI"
	paramA[4] = "RSSI"
	paramA[5] = "RSSI"
	paramA[6] = "RSSI"
	paramA[7] = "RSSI"
	
	paramB[2] = "RSSI"
	paramB[3] = "Sensor1"
	paramB[4] = "RSSI"
	paramB[5] = "RSSI"
	paramB[6] = "RSSI"
	paramB[7] = "RSSI"
	paramB[8] = "RSSI"
	paramB[9] = "RSSI"
	paramB[10] = "RSSI"

	paramC[2] = "RSSI"
	paramC[3] = "RSSI"
	paramC[4] = "RSSI"
	paramC[5] = "RSSI"
	paramC[6] = "Temperature"

	paramD[2] = "RSSI"
	paramD[3] = "Sensor1"
	paramD[4] = "RSSI"
	paramD[5] = "RSSI"
	paramD[6] = "RSSI"
	paramD[7] = "Temperature"


	host = "host1"

	ant[1] = "Ant1"
	ant[2] = "Ant2"
	ant[3] = "Ant3"
	ant[0] = "Ant4"

	tagA[2] = "110110110110110110110110"
	tagA[3] = "CC0CC0CC0CC0CC0CC0CC0CC0"
	tagA[4] = "CC2CC2CC2CC2CC2CC2CC2CC2"
	tagA[5] = "B4B4B4B4B4B4B4B4B4B4B4B4"
	tagA[6] = "A2A2A2A2A2A2A2A2A2A2A2A2"
	tagA[7] = "AD1213014B89578E59000040"
	
	tagB[2] = "124124124124124124124124"
	tagB[3] = "124124124124124124124124"
	tagB[4] = "AD1213014B88DF915E000033"
	tagB[5] = "AD1213014B89F18F5D000053"
	tagB[6] = "AD1213014B889F8F5B00002C"
	tagB[7] = "AD1213014B7BF7905C0000CB"
	tagB[8] = "AD1213014B89578E59000040"
	tagB[9] = "CC0CC0CC0CC0CC0CC0CC0CC0"
	tagB[10] = "CC2CC2CC2CC2CC2CC2CC2CC2"

	tagC[2] = "CC0CC0CC0CC0CC0CC0CC0CC0"
        tagC[3] = "CC2CC2CC2CC2CC2CC2CC2CC2"
	tagC[4] = "E3E3E3E3E3E3E3E3E3E3E3E3"
	tagC[5] = "010101010101010101010101"
	tagC[6] = "010101010101010101010101"

	tagD[2] = "888888888888888888888888"
        tagD[3] = "888888888888888888888888"
	tagD[4] = "CC0CC0CC0CC0CC0CC0CC0CC0"
        tagD[5] = "CC2CC2CC2CC2CC2CC2CC2CC2"
	tagD[6] = "122122122122122122122122"
	tagD[7] = "122122122122122122122122"

}

# TS HOST READER F3F3F3 RSSI=-69
# TS HOST READER 2222 T=20
# TS HOST READER 6666 S1=X S2=Y

NR > 5 {
	#print "numFields: " NF
	prefix=$1 " " host " " ant[(NR-5)%4]
	new_line=1


	if (((NR-5)%4) == 1) {
		for (i = 2; i <= NF-1; i++) {
			if ($i != 0 && $i != -1000) {
				output = prefix " " tagA[i] " " paramA[i] "=" $i
				print output
			}
		}
	}
	if (((NR-5)%4) == 2) {
		for (i = 2; i <= NF-1; i++) {
			if ($i != 0 && $i != -1000) {
				output = prefix " " tagB[i] " " paramB[i] "=" $i
				print output
			}
		}
	}
	if (((NR-5)%4) == 3) {
		for (i = 2; i <= NF-1; i++) {
			if ($i != 0 && $i != -1000) {
				output = prefix " " tagC[i] " " paramC[i] "=" $i
				print output
			}
		}
	}
	if (((NR-5)%4) == 0) {
		for (i = 2; i <= NF-1; i++) {
			if ($i != 0 && $i != -1000) {
				output = prefix " " tagD[i] " " paramD[i] "=" $i
				print output
			}
		}
	}
}
