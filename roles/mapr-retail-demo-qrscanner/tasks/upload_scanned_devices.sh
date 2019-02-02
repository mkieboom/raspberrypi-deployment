#!/bin/bash

# Get the cluster IP
MAPR_CLUSTER_IP=$(cat /mapr_cluster_ip.txt)
# Construct the rest call to StreamSets running on the MapR Cluster
MAPR_CLUSTER_REST_ENDPOINT="http://$MAPR_CLUSTER_IP:8001/qrscanneddevices"

# Construct json
echo '{' > /tmp/qrscanned_device.json

# _id
echo -n '"_id":' >> /tmp/qrscanned_device.json
cat /tmp/qrcode.json | jq '._id' >> /tmp/qrscanned_device.json
echo -n ',' >> /tmp/qrscanned_device.json

# email
echo -n '"email":' >> /tmp/qrscanned_device.json
cat /tmp/qrcode.json | jq '.email' >> /tmp/qrscanned_device.json
echo -n ',' >> /tmp/qrscanned_device.json

# name
echo -n '"name":' >> /tmp/qrscanned_device.json
cat /tmp/qrcode.json | jq '.name' >> /tmp/qrscanned_device.json
echo -n ',' >> /tmp/qrscanned_device.json

# deviceUuid
echo -n '"deviceUuid":' >> /tmp/qrscanned_device.json
cat /tmp/qrcode.json | jq '.deviceUuid' >> /tmp/qrscanned_device.json
echo -n ',' >> /tmp/qrscanned_device.json

# datetime
echo -n '"datetime":' >> /tmp/qrscanned_device.json
cat /tmp/qrcode.json | jq '.datetime' >> /tmp/qrscanned_device.json
echo -n ',' >> /tmp/qrscanned_device.json

# mac
echo -n '"mac":' >> /tmp/qrscanned_device.json
cat /tmp/closest.json | jq '.mac' >> /tmp/qrscanned_device.json
echo -n ',' >> /tmp/qrscanned_device.json

# signalstrength
echo -n '"signalstrength":' >> /tmp/qrscanned_device.json
cat /tmp/closest.json | jq '.signalstrength' >> /tmp/qrscanned_device.json

# Close the json file
echo '}' >> /tmp/qrscanned_device.json

# Upload the json file
curl $MAPR_CLUSTER_REST_ENDPOINT -H 'X-SDC-APPLICATION-ID: mapr' -H 'Content-Type: application/json' -d @/tmp/qrscanned_device.json

# Cleanup
rm -rf /tmp/qrcode.json
rm -rf /tmp/closest.json