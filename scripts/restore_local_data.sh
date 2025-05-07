# bin/bash

# 3 out of 3 scripts to edit the label studio data.

# This script restores the label studio data in the local machine.
# The user should have run the use_label_studio_server_data_in_local.sh script before running this script.
# The aim of this script is to restore the label studio data in the local machine after the user has finished editing the data.

LOCAL_DIR="/home/machaves/.local/share/label-studio/" # The local directory where the label studio data should be stored
LABEL_STUDIO_VIRTUAL_ENVIROMENT="/home/machaves/Documents/CIGAIA/annotation_tool/label-studio" # Virtual environment path in local

# Copy the sqlite3 file from the temporal directory to the local
cd $LOCAL_DIR
scp -r temporal_delete_me_later/label_studio.sqlite3 .
rm -r temporal_delete_me_later

# Run label studio in the local to check that the data has been restored
source $LABEL_STUDIO_VIRTUAL_ENVIROMENT/bin/activate
label-studio start