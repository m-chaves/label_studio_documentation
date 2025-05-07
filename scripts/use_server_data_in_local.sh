#!/bin/bash

# 1 out of 3 scripts to edit the label studio data.

# This script creates a back up of the label studio data in the local machine.
# Then it brings the label studio data from the server to the local machine and runs label studio in the local machine.
# The aim of this script is to use the label studio data in the local machine (for editing purposes).
# Once the user is done with the editing, the user can run the transfer_label_studio_data_to_server.sh script to transfer the data back to the server.
# And there will be a copy of the Label Studio local data in a temporal directory.

LOCAL_DIR="/home/machaves/.local/share/label-studio/"
SERVER="machaves@sparks-vm3.i3s.unice.fr"
LABEL_STUDIO_VIRTUAL_ENVIROMENT="/home/machaves/Documents/CIGAIA/annotation_tool/label-studio"

# Go to the location of the label_studio.sqlite3 in local
cd $LOCAL_DIR

# Create a temporal directory
mkdir temporal_delete_me_later

# Create a copy of label_studio.sqlite3 in the temporal directory
scp label_studio.sqlite3 temporal_delete_me_later

# Copy the sqlite3 file from the server to the local
scp "$SERVER:$LOCAL_DIR/label_studio.sqlite3" .

# Run label studio in the local
cd $LABEL_STUDIO_ENVIROMENT_DIR
source $LABEL_STUDIO_VIRTUAL_ENVIROMENT/bin/activate
label-studio start

