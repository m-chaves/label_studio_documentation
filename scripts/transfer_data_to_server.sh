#!/bin/bash

# 2 out of 3 scripts to edit the label studio data.

# DANGER: This script overwrites the data in the server with the data in the local machine.

# This script transfers files to a remote server using scp.
# The files are transferred to the server's directory where the Label Studio project's data is stored.
# Both the label_studio.sqlite3 file and the media directory are necessary for the project to work.

# Define the destination server and directory
SERVER="machaves@sparks-vm3.i3s.unice.fr" # the server address
DEST_DIR="/home/machaves/.local/share/label-studio/" # the destination directory in the server
LOCAL_DIR="/home/machaves/.local/share/label-studio" # the local directory where the label studio data is stored (in this case is it the same as the destination directory but that is not always the case)

# Transfer the files
scp $LOCAL_DIR/label_studio.sqlite3 "$SERVER:$DEST_DIR"


