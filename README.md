# Prusa Raspberry PI Zero Config

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


## PI Setup

- Flash micro SD card with 32bit Raspberry Pi OS Lite.  Enable SSH and set network to connect to my wifi network.
- Update to latest packages (apt update/upgrade)
- Install `vim` `sudo apt install vim`
- set `etc/hostname` to `walleee-tv.home.arpa`
- Added my favorite alias: `ll, la, ..`

## Image Capture for Prusa Connect

### References

- [rpicam-still](https://www.raspberrypi.com/documentation/computers/camera_software.html#rpicam-still)
    - Installed by default when setting up RPi lite.
    - `rpicam-still --output test.jpg` worked the first time to create an image capture.

- Gist using as a general guide:  https://gist.github.com/cannikin/4954d050b72ff61ef0719c42922464e5 
    - found it in the details for this model:  https://www.printables.com/model/826864-raspicam-for-prusaconnect 

### Configuration















