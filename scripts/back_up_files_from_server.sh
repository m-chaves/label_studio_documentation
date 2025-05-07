#!/bin/bash

# This script transfers files from a remote server using scp.
# This intends to back up the data in the server to the local machine.

# Define the source server and directory
SERVER="machaves@sparks-vm3.i3s.unice.fr" # the server address
SOURCE_DIR="/home/machaves/.local/share/label-studio/" # the source directory in the server
LOCAL_DIR="./data/label_studio_back_up" # the destination directory on the local machine

# Transfer the files
scp "$SERVER:$SOURCE_DIR/label_studio.sqlite3" "$LOCAL_DIR"
