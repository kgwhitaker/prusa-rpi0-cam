#!/bin/bash

# Set default values for environment variables
: "${HTTP_URL:=https://connect.prusa3d.com/c/snapshot}"
: "${DELAY_SECONDS:=10}"
: "${LONG_DELAY_SECONDS:=60}"

# Read the secrets file and export variables
if [ -f .secrets ]; then
    set -a
    source .secrets
    set +a
else
    echo "Secrets file '.secrets' must exist and contain the following values."
    echo "FINGERPRINT=<a UUID unique to this camera instance>"
    echo "CAMERA_TOKEN=<token assigned by Prusa Connect>"
    echo "PRINTER_HOSTNAME=<hostname or IP of your printer>"
    echo "PRINTER_USERNAME=<your PrusaLink user name (not your PrusaConnect user e.g. 'maker')"
    echo "PRINTER_PASSWORD=<your PrusaLink password (again, not PrusaConnect)"
    exit 1
fi

echo "Starting Image Capture for Prusa Connect\n"
echo "HTTP_URL: $HTTP_URL"
echo "DELAY_SECONDS: $DELAY_SECONDS"
echo "LONG_DELAY_SECONDS: $LONG_DELAY_SECONDS"
echo "FINGERPRINT: $FINGERPRINT"
echo "PRINTER_HOSTNAME: $PRINTER_HOSTNAME"
echo "PRINTER_USERNAME: $PRINTER_USERNAME"

while true; do

    DELAY=$DELAY_SECONDS

    # Check to see if the printer is printing...
    PRINT_STATUS=$(curl -s --digest -u $PRINTER_USERNAME:$PRINTER_PASSWORD "$PRINTER_HOSTNAME/api/v1/status" | jq -r '.printer.state')
    if [ $? -ne 0 ]; then
        echo "*** ERROR getting printer status.  Will retry in ${LONG_DELAY_SECONDS}s..."
        DELAY=$LONG_DELAY_SECONDS
    else 
        # Upload a still image if we're printing.
        if [ "$PRINT_STATUS" == "PRINTING" ]; then
            # Image capture.
            # -q = JPEG quality.  Keep it low for file size reasons, -t is timeout. 1 = 1 sec, so command runs quickly.
            rpicam-jpeg -q 50 --width 800 --height 600 -t 1 -o /tmp/3d_still.jpg
            # If no error, upload it.
            if [ $? -eq 0 ]; then
                # POST the image to the HTTP URL using curl
                curl -k -X PUT "$HTTP_URL" \
                    -H "accept: */*" \
                    -H "content-type: image/jpg" \
                    -H "fingerprint: $FINGERPRINT" \
                    -H "token: $CAMERA_TOKEN" \
                    --data-binary "@/tmp/3d_still.jpg" \
                    --no-progress-meter \
                    --compressed

                # Reset delay to the normal value
                DELAY=$DELAY_SECONDS
            else
                echo "Error capturing image.  Will retry in ${LONG_DELAY_SECONDS}s..."
                # Set delay to the longer value
                DELAY=$LONG_DELAY_SECONDS
            fi
        else 
            echo "Printer is not printing."
        fi
    fi
    
    echo "Delay: $DELAY"
    sleep "$DELAY"
done