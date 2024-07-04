#!/bin/bash

error_exit() {
    echo "Error occurred, check $LOGFILE for details." >&2
    exit 1
}
