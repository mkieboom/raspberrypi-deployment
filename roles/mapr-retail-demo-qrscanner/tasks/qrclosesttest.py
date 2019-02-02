cat <<EOF > /qrclosesttest.py
# USAGE
# python3 /qrclosesttest.py


# import the necessary packages
#from imutils.video import VideoStream
#from pyzbar import pyzbar
#from subprocess import call
from subprocess import check_output
from jsonmerge import merge
#import argparse
#import datetime
#import imutils
#import time
#import cv2
import re

# construct the argument parser and parse the arguments
#print("[INFO] New QR code scanned: {}".format(barcodeData))

# Get the closest device
closestDevice = check_output(["/getdevice.sh"]).decode('utf-8')
print("[INFO] - {}".format(closestDevice))
#closestDeviceJSON = "{}".format(re.findall("{(.*?)}", closestDevice))
#print re.findall("<person>(.*?)</person>", closestDevice)


texta='{"email":"mkoeboom@mapr.com","deviceUuid":"8B26243D-98DA-4117-8FC3-43A5625495C9","latitude":"52.35533125973939","name":"2ha","longitude":"4.93801785135442"}'


resulta = merge(closestDevice, texta)
#closestDeviceJSON = re.search("'{(.+?)'", closestDevice).group(1)
print("[MERGE] - {}".format(resulta))


base = '{"foo": 1,"bar": [ "one" ],}'
head = '{"bar": [ "two" ],"baz": "Hello, world!"}'
resultb = merge(head,base)
print("[RESULT] - {}".format(resultb))

#print("[CLIENT] New QR code scanned: {}".format(result))

#csv.write("{},{},{}\n".format(datetime.datetime.now(),
#	barcodeData,closestDevice))
#csv.flush()

EOF