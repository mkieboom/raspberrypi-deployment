#!/bin/bash

cat /tmp/qrcode.json | jq -r '(.rows[]|[.datetime,.client_mac,.signal_strength])|@tsv'

cat /tmp/qrcode.json | jq -r '.email,.deviceUuid'

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

# Cleanup
# rm -rf /tmp/qrcode.json
# rm -rf /tmp/closest.json