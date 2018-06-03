#!/bin/bash
# Convenient opencv3 install script written by Claude Pageau 1-Jul-2016
ver="0.30"
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
echo "-------------------------------------------------------------"
echo "      opencv33-setup setup.sh script ver $ver"
echo "Install or Upgrade opencv3-setup.sh "
echo "-------------------------------------------------------------"
echo "1 - Downloading opencv33-setup github repo files"
echo ""

wget -O cv33-setup.sh https://raw.github.com/pageauc/opencv3-setup/master/cv33-setup.sh
wget -O setup.sh https://raw.github.com/pageauc/opencv3-setup/master/setup.sh
wget -O Readme.md https://raw.github.com/pageauc/opencv3-setup/master/Readme.md
  
echo "Done Download"
echo "-------------------------------------------------------------"
echo "2 - Make Required Files Executable"
echo ""
chmod +x *sh
echo "Done Permissions"
echo "-------------------------------------------------------------"
echo "To Run OpenCV3 Menu Install Script"
echo ""
echo "    cd ~/opencv3-setup"
echo "    ./cv33-setup.sh"
echo ""
echo $DEST_DIR "Good Luck Claude ..."
echo "Bye"

