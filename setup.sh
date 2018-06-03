#!/bin/bash
# Convenient opencv3 install script written by Claude Pageau 1-Jul-2016
ver="0.50"
DEST_DIR='opencv3-setup'  # Default folder install location

cd ~
if [ -d "$DEST_DIR" ] ; then
  STATUS="Upgrade"
  echo "Upgrade files"
else
  echo "New Install"
  STATUS="New Install"
  mkdir -p $DEST_DIR
  echo "$DEST_DIR Folder Created"
fi

cd $DEST_DIR
INSTALL_PATH=$( pwd )

# Remember where this script was launched from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "
-------------------------------------------------------------
      setup.sh script ver $ver
      Install or Upgrade opencv3
-------------------------------------------------------------
1 - Downloading opencv3-setup github repo files"

wget -O cv32-install-menu.sh https://raw.github.com/pageauc/opencv3-setup/master/cv32-install-menu.sh
wget -O cv33-install-menu.sh https://raw.github.com/pageauc/opencv3-setup/master/cv33-install-menu.sh
wget -O Readme.md https://raw.github.com/pageauc/opencv3-setup/master/Readme.md

echo "Done Download
-------------------------------------------------------------
2 - Make Required Files Executable"

chmod +x *sh

echo "
Done Permissions
-------------------------------------------------------------
To Run Appropiate OpenCV3 Menu Install Script

WARNING -  It is recommended you have a minimum size
           16GB SD card with at least 5GB free or mounted storage drive

    cd ~/opencv3-setup

    ./cv32-install-menu.sh
or
    ./cv33-install-menu.sh"

echo $DEST_DIR "Good Luck Claude ..."
echo "Bye"

