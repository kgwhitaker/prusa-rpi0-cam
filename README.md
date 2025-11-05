# Prusa Raspberry PI Zero Camera Config

When I had setup my trusty Prusa MK3S way back in the day, I had installed a Raspberry Pi Zero W in it so I could use a camera and other fun control options.  I recently brought new life into the printer by installing the MK3.5S upgrade.  As part of that upgrade, I lost the functionality of the Raspberry Pi.  Most importantly I lost the camera so I could monitor my prints from the next room.

At first I tried a few streaming options that let me essentially use the RPi Zero as an IP cam, but did not find them satisfactory.  The one that I got running OK was constantly running the RPi at 98% CPU.  Not good for something that will be mostly idle in between prints.  Ultimately, I decided to simply do a still image capture and interface it with Prusa Connect and give myself a little web page to monitor things so I did not need to log in to Prusa Connect to see the status of my prints.

So, this setup:
- Takes a static image every 10 seconds from the camera attached to the RPi Zero.
- Uploads the image to Prusa Connect every 10 seconds.  
- The script will only capture an image and upload if it is actively printing something.
- Exposes a small web page so you can watch things locally.

** There is no security on the web page.  Be sure this is only on your local network! **

### References and Attribution

- I used this Gist using as a general guide for setting up this configuration:  https://gist.github.com/cannikin/4954d050b72ff61ef0719c42922464e5 
    - I found it in the details for this model:  https://www.printables.com/model/826864-raspicam-for-prusaconnect 
    - Thanks to [@Chris_Schumi](https://www.printables.com/@Chris_Schumi) and to [@cannikin](https://gist.github.com/cannikin) for posting these.

- The docs for the tools provided by Raspberry Pi can be found here: https://www.raspberrypi.com/documentation/computers/camera_software.html#rpicam-apps
    - Installed by default when setting up RPi lite and using `rpicam-still --output test.jpg` worked the first time to create an image capture on my setup.

## PI Setup

- Flash micro SD card with 32bit Raspberry Pi OS Lite.  Enable SSH and set network to connect to your wifi network.
- Update the RPi to latest packages (`sudo apt update -y && sudo apt upgrade -y `)

## Setup Image Capture for Prusa Connect

### Configuration

The prerequisites for this installation are:
- You have a Raspberry Pi Zero W running and you can log in to it.
- Your camera is connected and when you run `rpicam-jpeg -o test.jpg` a jpeg is created from your camera.
- You have `git` installed or other means of getting the files in this repo to your Raspberry Pi Zero.
- You have logged in to Prusa Connect and created a camera for your 3D printer by selecting *Add new other camera* and have the token for it.
- You have the Prusa Link credentials from your printer.  In my case, I got it from the printer LCD screen by navigating to the network section.  
    - You have also validated those credentials by connecting to the Prusa Link connection of your printer.

#### Install Dependencies
- Install `jq`.  This is used to check if the printer is currently printing or not when queried locally.
    - `sudo apt install jq`
- Install [lighttpd](https://www.lighttpd.net).  This is used for the local web page.
    - `sudo apt install lighttpd`
    - `service lighttpd force-reload`


#### Install the `prusa-cam` Script
- Copy `prusa-cam` from this repo to your `/usr/bin` directory as `sudo` 
    - `sudo cp prusa-cam /usr/bin`
    - Make sure that it is executable: `sudo chmod +x /usr/bin/prusa-cam`
- Create your secrets file (see `example_secrets` in this repo.)
    - Create a directory `/etc/prusa-cam` 
    - Put the secrets file in `/etc/prusa-cam` and name it `.secrets`.
    - Ensure that permissions on this file are restricted to `root`:
        - `sudo chmod 600 /etc/prusa-cam/.secrets`

#### Test the `prusa-cam` Script

At this point, you should be able to confirm that the script will capture an image from your camera and send it to PrusaConnect.  

From your home directory, run the script:
```
    sudo prusa-cam /etc/prusa-cam/.secrets
```

The script should start up and show something like this:
```
Starting Image Capture for Prusa Connect

HTTP_URL: https://connect.prusa3d.com/c/snapshot
DELAY_SECONDS: 10
LONG_DELAY_SECONDS: 60
FINGERPRINT: <redacted>
PRINTER_HOSTNAME: <redacted>
PRINTER_USERNAME: maker
2025-11-03 17:14:31 Printer is not printing.
2025-11-03 17:14:41 Printer is not printing.
```

If you start a print, it should start uploading images:

```
Stream configuration adjusted
[2:13:45.034709435] [8493]  INFO Camera camera.cpp:1215 configuring streams: (0) 1296x972-YUV420/sYCC (1) 1296x972-SGBRG10_CSI2P/RAW
[2:13:45.037864407] [8495]  INFO RPI vc4.cpp:615 Sensor: /base/soc/i2c0mux/i2c@1/ov5647@36 - Selected sensor format: 1296x972-SGBRG10_1X10/RAW - Selected unicam format: 1296x972-pGAA/RAW
Mode selection for 800:600:12:P
    SGBRG10_CSI2P,640x480/0 - Score: 1560
    SGBRG10_CSI2P,1296x972/0 - Score: 1217
    SGBRG10_CSI2P,1920x1080/0 - Score: 1566.67
    SGBRG10_CSI2P,2592x1944/0 - Score: 1784
Stream configuration adjusted
[2:13:45.599879572] [8493]  INFO Camera camera.cpp:1215 configuring streams: (0) 800x600-YUV420/sYCC (1) 1296x972-SGBRG10_CSI2P/RAW
[2:13:45.617471421] [8495]  INFO RPI vc4.cpp:615 Sensor: /base/soc/i2c0mux/i2c@1/ov5647@36 - Selected sensor format: 1296x972-SGBRG10_1X10/RAW - Selected unicam format: 1296x972-pGAA/RAW
Still capture image received
```

#### Configure `prusa-cam` as a Service

- Copy the `prusa-cam.service` file to `/etc/sytemd/system`
    - `sudo cp prusa-cam.service /etc/systemd/system`
- Reload *systemd*: `sudo systemctl daemon-reload`
- Start the service: `sudo systemctl restart prusa-cam.service`
- Verify it is running OK:  `sudo systemctl status prusa-cam.service`. Should look something like:
```
$ sudo systemctl status prusa-cam.service
● prusa-cam.service - Prusa Cam Service - send stills to PrusaConnect
     Loaded: loaded (/etc/systemd/system/prusa-cam.service; enabled; preset: enabled)
     Active: active (running) since Mon 2025-11-03 17:39:26 PST; 4s ago
 Invocation: 9dc77428c14d4e62a699a86802648873
   Main PID: 9596 (prusa-cam)
      Tasks: 2 (limit: 386)
        CPU: 1.642s
     CGroup: /system.slice/prusa-cam.service
             ├─9596 /bin/bash /usr/bin/prusa-cam /etc/prusa-cam/.secrets
             └─9615 sleep 10

Nov 03 17:39:26 walleee-tv.home.arpa systemd[1]: Started prusa-cam.service - Prusa Cam Service - send stills to PrusaConnect.
```
- Enable the service so that it runs on bootup.
    - `sudo systemctl enable prusa-cam.service`

#### `prusa-cam` Logs

- Standard Out and Standard Error are put into the `systemd` journal.
- You can view the logs by issuing the command `journalctl -u prusa-cam.service`
- You can tail (follow) the log output by issuing the command `journalctl -f -u prusa-cam.service`.

#### Setup a Local Web Page

In order to see the image locally without going out to Prusa Connect, this creates a simple web page that you can view directly.

- Confirm that the server is running by navigating to `http://<your RPi hostname here>`
    - You should see the place holder page for *Lighttpd*.  
- Copy the contents of the `html` folder in this repo to `/var/www/html` on your Raspberry Pi Zero
- Again open your browser to `http://<your RPi hostname here>`.  You should see an image and the date/time that the image was created.
