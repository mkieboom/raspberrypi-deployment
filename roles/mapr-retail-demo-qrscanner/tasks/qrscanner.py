# USAGE
# python3 qrscanner.py

# source: https://www.pyimagesearch.com/2018/05/21/an-opencv-barcode-and-qr-code-scanner-with-zbar/

# import the necessary packages
from imutils.video import VideoStream
from pyzbar import pyzbar
#from subprocess import call
from subprocess import check_output
from jsonmerge import merge
import argparse
import datetime
import imutils
import time
import cv2
import re

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-q", "--outputqrcode", type=str, default="/tmp/qrcode.json",
	help="path to output json file containing scanned barcode")
ap.add_argument("-c", "--outputclosest", type=str, default="/tmp/closest.json",
	help="path to output json file containing closest device")
args = vars(ap.parse_args())


# initialize the video stream and allow the camera sensor to warm up
print("[INFO] starting video stream...")
# Use a USB connected Webcam
vs = VideoStream(src=0).start()
# Use the Raspberry Pi camera
#vs = VideoStream(usePiCamera=True).start()
time.sleep(2.0)

found = set()

# loop over the frames from the video stream
while True:
	# grab the frame from the threaded video stream and resize it to
	# have a maximum width of 400 pixels
	frame = vs.read()
	#frame = imutils.resize(frame, width=400)
	frame = imutils.resize(frame, width=400, inter=cv2.INTER_CUBIC)

	# find the barcodes in the frame and decode each of the barcodes
	barcodes = pyzbar.decode(frame)



	# loop over the detected barcodes
	for barcode in barcodes:
		# extract the bounding box location of the barcode and draw
		# the bounding box surrounding the barcode on the image
		(x, y, w, h) = barcode.rect
		cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 0, 255), 2)

		# the barcode data is a bytes object so if we want to draw it
		# on our output image we need to convert it to a string first
		barcodeData = barcode.data.decode("utf-8")
		barcodeType = barcode.type

		# draw the barcode data and barcode type on the image
		text = "{} ({})".format(barcodeData, barcodeType)
		cv2.putText(frame, text, (x, y - 10),
			cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)

		if barcodeData not in found:
			print("[INFO] New QR code scanned: {}".format(barcodeData))

			# Get the closest device
			closestDevice = check_output(["/qrscanner_closestdevice.sh"]).decode('utf-8')
			#closestDeviceJSON = "\{{}\}".format(re.findall("{(.*?)}", closestDevice))
			#result = merge(barcodeData, closestDevice)

			# Store the scanned qr code
			outputqrcode = open(args["outputqrcode"], "w")
			outputqrcode.write("{}".format(barcodeData))
			outputqrcode.flush()
			outputqrcode.close()

			# Capture the closest Wifi device and store it
			outputclosest = open(args["outputclosest"], "w")
			outputclosest.write("{}".format(closestDevice))
			outputclosest.flush()
			outputclosest.close()

			# Upload to the MapR cluster
			uploadToCluser = check_output(["/upload_scanned_devices.sh"]).decode('utf-8')

			found.add(barcodeData)

	# show the output frame
	cv2.imshow("Barcode Scanner", frame)
	key = cv2.waitKey(1) & 0xFF
 

	# if the q key was pressed, break from the loop
	if key == ord("q"):
		break

# close the output CSV file do a bit of cleanup
print("[INFO] cleaning up...")
cv2.destroyAllWindows()
vs.stop()