# Prusa Raspberry PI Zero Camera Config

Tracks scripts and documentation for configuring a Raspberry Pi Zero W to use with a Prusa MK3.5

## Discarded Solutions

### Streaming Video using `ffmpeg` and others; 
    - Could not get it to work with my RPi and camera, maybe my hardware is too old.  Level of effort exceeded my patience.
### Web UI Setup
- Using the project:  https://github.com/monkeymademe/CamUI
    - Install dependencies:

```
sudo apt install python3-flask
sudo apt install -y python3-picamera2 --no-install-recommends # Installs a reduced set appropriate for a lite install.
```

- Installed the CamUI project using git clone.
    - Used the 2.0.1 branch.  Using main was buggy on Safari.

```
git clone https://github.com/monkeymademe/CamUI.git
git switch v2.0.1
```

This worked, but it was pulling 98% CPU on the RPi constantly.  Cutting down on resolution and framerate using the UI got it responsive enough, but decided it was not worth it.  

Decided to just use PrusaConnect and static images for now.

## PI Setup

- Flash micro SD card with 32bit Raspberry Pi OS Lite.  Enable SSH and set network to connect to my wifi network.
- Update to latest packages (apt update/upgrade)
- Install `vim` `sudo apt install vim`
- set `etc/hostname` to `walleee-tv.home.arpa`
- Added my favorite alias: `ll, la, ..`
- Install `git`
- Install `jq` <-- Needed for the script to check status of the printer.

## Image Capture for Prusa Connect

### References

- [rpicam-still](https://www.raspberrypi.com/documentation/computers/camera_software.html#rpicam-still)
    - Installed by default when setting up RPi lite.
    - `rpicam-still --output test.jpg` worked the first time to create an image capture.

- Gist using as a general guide:  https://gist.github.com/cannikin/4954d050b72ff61ef0719c42922464e5 
    - found it in the details for this model:  https://www.printables.com/model/826864-raspicam-for-prusaconnect 

### Configuration

The starting point for this configuration is that you have a Raspberry Pi Zero W running and you can log on to it.  Further, your camera is connected and when you run `rpicam-jpeg -o test.jpg' a jpeg is created from your camera.  You have `git` installed or other means of getting
the files to your Raspberry Pi Zero.

#### Install Dependencies
- Install `jq`.  This is used to check if the printer is currently printing or not when queried locally.
    - `sudo apt install jq`

#### Install the `prusa-cam` Script
- Copy `prusa-cam` from this repo to your `/usr/bin` directory as `sudo` 
    - `sudo cp prusa-cam /usr/bin`
    - Make sure that it is executable: `sudo chmod +x /usr/bin/prusa-cam`
- Create your secrets file (see `example_secrets` in this repo.)
    - Create a directory `/etc/prusa-cam` Put the secrets file in `/etc/prusa-cam` and name it `.secrets`.
    - ensure that permissions on this file are restricted to `root`:
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

- Copy the prusa-cam.service file to `/etc/sytemd/system`
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

- Standard Out and Standard Error are put into /var/log/prusa-cam.log
- you can tail that log to see what is happening
    - `tail -f /var/log/prusa-cam.log` 













 
















