## Raspberry Pi Menu Driven OpenCV 3 Compile from Source Script
#### Whiptail menu enabled script to help compile opencv3 from source  

## Quick Install   
Easy Install of opencv3-setup onto a Raspberry Pi Computer with Recent Raspbian Jessie Build.
This is a whiptail menu system that allows install of opencv 3.2.0 or 3.3.0

    curl -L https://raw.github.com/pageauc/opencv3-setup/master/setup.sh | bash

From a computer logged into the RPI via ssh (Putty) session      
* use mouse to highlight command above, right click, copy.     
*  Then select ssh(Putty) window, mouse right click, paste.   
The command should download and run the install setup.sh script.

***To Run***

    cd ~/opencv3-setup
    ./cv3-install-menu.sh

## Manual Install   
From a logged in RPI SSH session or console terminal perform the following.

    wget https://raw.github.com/pageauc/opencv3-setup/master/setup.sh
    chmod +x setup.sh
    ./setup.sh
    cd ~/opencv3-setup
    chmod +x *.sh
    ./cv3-install-menu.sh

## Prerequisites

* Basic knowledge of unix terminal commands.
There are some optional configuration steps that 
must be done manually using nano.  
* Patience since this will take a few hours  
* Working RPI connected to Internet
* RPI with 1GB of memory with a single CPU core or better
* Recent Jessie or Stretch Raspbian Release
* Recommended min 16GB SD card with at least 6 GB Free.
If Free disk space is low or You have a smaller system SD.
You can mount USB memory or hard disk and change the
install_dir variable in this script to point to the new path.
  
To Check free disk space run

    df -h

## How To Run Menu

    cd ~/opencv3-setup
    ./cv3-install-menu.sh

Start at Step 1 and follow instructions.

## Operation
This menu driven install script will download and
compile opencv3 from source code. Default is opencv 3.3.0
The ***cv3-install.menu.sh*** script and menu picks will

* Validate that opencv_ver variable setting is correct 
* Update/upgrade Raspbian for Raspberry Pi
* Install build dependencies
* Download opencv3 source zip files and unzip
* Run ***cmake*** to configure build
* Run ***make*** to Compile opencv3 source code
* Run ***make install*** to install new opencv python files
* Run ***make clean*** to Delete Source directory to release disk space (optional). 

## Instructions
For a Full Build on a New OS
It is recommended you have a minimum 16GB SD card with at least 6GB free.
Less Space will be needed depending on what dependencies are already
installed.  You can change the opencv install location by editing
the opencv3-install-menu.sh using nano and changing the variable
opencv_dir.  The opencv version number can also be change using the
opencv_ver variable.  The version number will be verified at launch
with repo at https://github.com/Itseez/opencv/archive/
You will be asked to reboot during some installation steps.
If you answer yes to successful completion of a step, you will be
sent to the next step otherwise you will be sent to the terminal
to review errors or back to the main menu as appropriate.
For Additional Details See https://github.com/pageauc/opencv3-setup
Script Steps Based on GitHub Repo
https://github.com/Tes3awy/OpenCV-3.2.0-Compiling-on-Raspberry-Pi

Users will be prompted to review output for errors and elect to continue.  You can repeat a
particular step from the menu if required to correct any errors.

A temporary working folder will be created per ***cv3-menu-install.sh***
***install_dir*** variable to store the downloaded opencv
and source and build files. The Default location is /home/pi/tmp_cv3.  
***IMPORTANT*** If there is limited space on the Raspbian SD card
you may want to create a symbolic link to an external drive
or memory stick.  Then edit 

    cd ~/opencv3-setup
    nano opencv3-install-menu.sh   

and change the ***install_dir*** variable to point to the symbolic link
for the external storage device.  ctrl-x y to save and exit nano. 
see example below mount command below

Sample commands to mount and use an external ntfs USB hard drive.
plug ntfs formatted disk into RPI USB slot

    cd ~
    sudo apt-get update
    sudo apt-get install ntfs-3g   # Make sure ntfs support installed
    sudo fdisk -l                  # will list drive if installed
    cd ~/
    mkdir mnt
    sudo mount -t ntfs-3g /dev/sda1 /home/pi/mnt
    cd ~/opencv-setup
    nano cv3-install-menu.sh

In nano edit ***install_dir*** variable per

    install_dir='/home/pi/mnt/tmp_cv3'

ctrl-x y to save change and exit. Run ***cv3-install.menu.sh***
and the script will create the ***/home/pi/mnt/tmp_cv3*** folder
on the mounted USB drive mount. To check free disk space run

    df -h 
    
## Credits
This install is based on   
https://github.com/Tes3awy/OpenCV-3.2.0-Compiling-on-Raspberry-Pi    
 
Have Fun   
Claude Pageau    
YouTube Channel https://www.youtube.com/user/pageaucp   
GitHub Repo https://github.com/pageauc

