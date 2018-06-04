## Raspberry Pi Menu Driven OpenCV 3 Compile from Source Script
#### Whiptail menu enabled script to help compile opencv3 from source  

![cv3-install-menu](https://github.com/pageauc/opencv-setup/blob/master/menu.png)

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
Less space may be needed depending on what dependencies are already
installed. RPI needs 1GB or RAM memory 

You can change the opencv install location by editing 
the cv3-install-menu.sh using nano and changing the
***install_dir*** variable.

The opencv version number can also be change using the
***opencv_ver*** variable.  The version number will be verified at launch
against repo at https://github.com/Itseez/opencv/archive/
See  https://github.com/opencv/opencv/releases     
and https://github.com/opencv/opencv_contrib/releases for valid zip versions    

You will be asked to reboot during some installation steps.
If you answer yes on successful completion of a step, you will be
sent to the next step otherwise you will be sent to the terminal
to review errors or back to the main menu as appropriate.

For Additional Details See https://github.com/pageauc/opencv3-setup
Script Steps Based on GitHub Repo
https://github.com/Tes3awy/OpenCV-3.2.0-Compiling-on-Raspberry-Pi

Users will be prompted to review output for errors and elect to continue.  You can repeat a
particular step from the menu if required to correct any errors.

***cv3-menu-install.sh*** will create a working or install folder per
***install_dir***. This folder will store downloaded opencv source
and build files. Default location is ***/home/pi/tmp_cv3*** 
 
***IMPORTANT*** If there is limited space on the Raspbian SD card
you may want to change ***install_dir*** variable to point to
an external storage drive.

    cd ~/opencv3-setup
    nano opencv3-install-menu.sh   

Change the ***install_dir*** variable to point to the desired mount location
or a symbolic link to the desired external storage device. ctrl-x y to save
and exit nano. For more details see example mount commands below.

Sample commands to mount and use an external ntfs USB hard drive.
Plug ntfs formatted disk into a RPI USB slot.  From SSH or terminal session
use sample commands below. (Note) modify to suit your conditions

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
on the mounted USB drive. To check free disk space run

    df -h 
    
## Credits
This install is based on   
https://github.com/Tes3awy/OpenCV-3.2.0-Compiling-on-Raspberry-Pi    
 
Have Fun   
Claude Pageau    
YouTube Channel https://www.youtube.com/user/pageaucp   
GitHub Repo https://github.com/pageauc

