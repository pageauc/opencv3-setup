#!/bin/bash
# Convenient opencv3 install script written by Claude Pageau 1-Jul-2016
ver="2.5"
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

wget -O cv3-install-menu.sh https://raw.github.com/pageauc/opencv3-setup/master/cv3-install-menu.sh
wget -O cv3-install-menu.conf https://raw.github.com/pageauc/opencv3-setup/master/cv3-install-menu.conf
wget -O Readme.md https://raw.github.com/pageauc/opencv3-setup/master/Readme.md
wget -O dphys-swapfile.1024 https://raw.github.com/pageauc/opencv3-setup/master/dphys-swapfile.1024
echo "Done Download
-------------------------------------------------------------
2 - Make Required Files Executable"

chmod +x *sh

# Delete existing setup.sh and Force running setup from github repo curl command
if [ -f "setup.sh" ] ; then
    rm setup.sh
fi

echo "Done Permissions
-------------------------------------------------------------
IMPORTANT - It is recommended you have a minimum size
            16GB system SD card with at least 6GB Free
            or mount USB Storage Media or Drive and
            edit opencv_dir variable in this script.
            See Readme.md for Details

    cd ~/opencv3-setup
    ./cv3-install-menu.sh

See ABOUT Menu Pick and Readme.md for more Details.
https://github.com/pageauc/opencv3-setup

Good Luck Claude ...
Bye"
