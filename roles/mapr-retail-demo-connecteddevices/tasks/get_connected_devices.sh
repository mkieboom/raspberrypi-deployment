#!/bin/bash

# This script captures all connected Wifi devices
# Devices are stored in /mapr-retail-demo/sensors-connecteddevices-db

# Get the RPI Sensor name (hostname)
SENSOR_NAME=$(hostname)

# Get the cluster IP
MAPR_CLUSTER_IP=$(cat /mapr_cluster_ip.txt)
# Construct the rest call to StreamSets running on the MapR Cluster
MAPR_CLUSTER_REST_ENDPOINT="http://$MAPR_CLUSTER_IP:8001/sensorsconnecteddevices"

while true
do
  # Current Date Time
  DATETIME=`date '+%Y-%m-%d %H:%M:%S'`

  # Get all connected devices
  CONNECTED_DEVICE_LIST=$(iw wlan0 station dump | egrep 'signal|Station' | awk '{ printf "%s ", $0 } !(NR%2) { print "" }' | awk '{print $(NF-2),$0}')

  # Check if connected device list is empty or not
  if [ -z "$CONNECTED_DEVICE_LIST" ]
  then
    echo "$DATETIME - No wifi clients connected"

      # No devices connected, upload empty json document
      DEVICE_MAC=""
      DEVICE_SIGNAL=""

      # Create a JSON message
      DEVICE_JSON="{\"_id\":\"$DATETIME$DEVICE_MAC\", \"datetime\": \"$DATETIME\", \"sensor\": \"$SENSOR_NAME\", \"mac\": \"$DEVICE_MAC\", \"signal\": \"$DEVICE_SIGNAL\"}"
      echo $DEVICE_JSON
      echo $DEVICE_JSON > /tmp/device.json

      # Upload to MapR Cluster
      curl $MAPR_CLUSTER_REST_ENDPOINT -H 'X-SDC-APPLICATION-ID: mapr' -H 'Content-Type: application/json' -d @/tmp/device.json

  else

    # Loop through all connected devices and push them to the MapR cluster
    while read -r CONNECTED_DEVICE; do

      # Get the connected device MAC and signal strenght
      DEVICE_MAC=$(echo $CONNECTED_DEVICE|grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')
      DEVICE_SIGNAL=$(echo $CONNECTED_DEVICE|grep -oP '\[\K[^\]]+')

      # Create a JSON message
      DEVICE_JSON="{\"_id\":\"$DATETIME$DEVICE_MAC\", \"datetime\": \"$DATETIME\", \"sensor\": \"$SENSOR_NAME\", \"mac\": \"$DEVICE_MAC\", \"signal\": \"$DEVICE_SIGNAL\"}"
      echo $DEVICE_JSON
      echo $DEVICE_JSON > /tmp/device.json

      # Upload to MapR Cluster
      curl $MAPR_CLUSTER_REST_ENDPOINT -H 'X-SDC-APPLICATION-ID: mapr' -H 'Content-Type: application/json' -d @/tmp/device.json

    done <<< "$CONNECTED_DEVICE_LIST"
  fi

  # Sleep and start over again
  sleep 3

done