#!/bin/bash

#
# Shared logging helpers for prusa-rpi0-cam scripts.
#



#
# Logs a message with a timestamp.
#
log() {
    printf '%s %s\n' "$(date +"%Y-%m-%d %H:%M:%S")" "$*"
}

#
# Logs an error with a timestamp.
#
log_err() {
    printf '%s %s\n' "$(date +"%Y-%m-%d %H:%M:%S")" "$*" >&2
}

