#!/bin/bash

# Full list of devices
#CONNECTED_DEVICE_LIST=$(iw wlan0 station dump | egrep 'signal|Station' | awk '{ printf "%s ", $0 } !(NR%2) { print "" }' | awk '{print $(NF-2),$0}' | sort -nr )

# Returns the closest wifi client MAC address
CLOSEST_DEVICE=$(iw wlan0 station dump | egrep 'signal|Station' | awk '{ printf "%s ", $0 } !(NR%2) { print "" }' | awk '{print $(NF-2),$0}' | sort -nr | head -n 1)

# Get the mac address
DEVICE_MAC=$(echo $CLOSEST_DEVICE|grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')

# Get the device signal strength
DEVICE_SIGNAL=$(echo $CLOSEST_DEVICE|grep -oP '\[\K[^\]]+')

# Print a JSON containing the closest device MAC and signal strength
echo -n "{\"mac\":\"$DEVICE_MAC\",\"signalstrength\":\"$DEVICE_SIGNAL\"}"
