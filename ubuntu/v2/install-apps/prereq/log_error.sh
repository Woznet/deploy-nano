#!/bin/bash

log_error() {
    echo "Error occurred in $1, check $LOGFILE for details." >&2
    echo "Error in $1" >> $LOGFILE
}

