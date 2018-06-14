## Raspberry Pi Menu Driven OpenCV 3 Compile from Source Script
#### Whiptail menu enabled script to help compile opencv3 from source

![cv3-install-menu](https://github.com/pageauc/opencv3-setup/blob/master/menu.png)

## Quick Install
Step1 - Use mouse to highlight command below, Then right click copy on highlighted command     
Step2 - On a logged in RPI SSH terminal session right click paste then Enter to Run ***setup.sh*** script

    curl -L https://raw.github.com/pageauc/opencv3-setup/master/setup.sh | bash 

The curl comand will run the GitHub [setup.sh](https://github.com/pageauc/opencv3-setup/blob/master/setup.sh)
script that will install files and configure into the ***~/opencv3-setup*** folder.

***To Run***

    cd ~/opencv3-setup
    ./cv3-install-menu.sh

## Manual Install
From a logged in RPI SSH session or console terminal perform the following.
This will allow you to review the code before installing.

    cd ~
    wget -o setup.sh https://raw.github.com/pageauc/opencv3-setup/master/setup.sh
    more setup.sh
    chmod +x setup.sh
    ./setup.sh
    rm setup.sh
    cd ~/opencv3-setup
    ./cv3-install-menu.sh

## Prerequisites

* Basic knowledge of unix terminal commands.
There are some optional configuration steps that
must be done manually using nano.
* Patience since this will take a few hours
* Recent Jessie or Stretch Raspbian Release
* Working RPI 
* Working Internet connected to RPI WIFI or RJ45 cable
* RPI RAM Memory will be detected and make set for 1 or 2 cores
* RPI SWAP will be Detected and Temporarily set to 1024 MB
during compile make. After Compile Swap will be Returned to Orginal Config
* Recommended min 16GB SD card with at least 6 GB Free.
If Free disk space is low or You have a smaller system SD.
You can mount USB memory or hard disk and change the
INSTALL_DIR variable in this script to point to the new path.

To Check free disk space run

    df -h

## How To Run Menu

    cd ~/opencv3-setup
    ./cv3-install-menu.sh

Start at Step 1 and follow instructions.

## Operation
This menu driven install script will download, compile and install opencv3
from source code. Default is currently opencv ver 3.4.1

The ***cv3-install.menu.sh*** script and menu picks will

* Validate that OPENCV_VER variable setting is correct
* Create cv3-log.txt If It Does Not Exist. Records system information, date/times of steps including execution time.
* Update/upgrade Raspbian for Raspberry Pi
* Install build dependencies
* Download opencv3 source zip files and unzip
* Auto Detect RPI3 and set NEON compile directive for cmake to enhance cv3 performance
* Run ***cmake*** to configure build
* Temporarily Increase Swap memory to 1024 MB During make
* Auto Detect Total RAM memory and set compile cores. -j2 for 1 GB, -j1 for the Rest
* Run ***make*** to Compile opencv3 source code
* Run ***make install*** to install new opencv python files to production.
* Run optional ***make clean*** to clear build directory to force full recompile.
* DELETE menu pick to optionally recover disk space by deleting the ***tmp_cv3*** folder containing
opencv source and build files and folders.

## RAM Memory
If RPI has 1GB of RAM memory make will use 2 cores -j2, otherwise 1 core -j1
will be used. Both will have Swap Memory temporarily set to 1024 MB during
the make compile process step. At the end of the compile the original Swap
config will be returned.

## Disk Space
For a Full Build on a New OS
It is recommended you have a minimum 16GB SD card with at least 6GB free.
Less space may be needed depending on what dependencies are already
installed. You can recover most of the disk space after the build
by running the DELETE menu pick.

## Changing INSTALL_DIR 
***cv3-menu-install.sh*** will create a working or install folder per
***INSTALL_DIR***. This folder will store downloaded opencv source
and build files. Default location is ***/home/pi/tmp_cv3***  
You can change the opencv install location by editing
the cv3-install-menu.sh using nano and changing the
***INSTALL_DIR*** variable. Note the USB media must ***NOT be formatted as FAT*** since it
does not support symbolic links that are needed to compile opencv.
Use a unix or NTFS format to avoid a failed make compile.

In nano edit ***INSTALL_DIR*** variable where mnt is your mount path location
Note the ***tmp_cv3** folder will automatically be created when the menu
is restarted.  See sample mount instructions below.

    INSTALL_DIR='/home/pi/mnt/tmp_cv3'

ctrl-x y to save change and exit. Run ***cv3-install.menu.sh***
and the script will create the ***/home/pi/mnt/tmp_cv3*** folder
on the mounted USB drive. To check free disk space run

    df -h
    
## Changing OPENCV_VER
The opencv version number can also be change using the
***OPENCV_VER*** variable.  The version number will be verified at launch
against repo at https://github.com/Itseez/opencv/archive/
See  https://github.com/opencv/opencv/releases
and https://github.com/opencv/opencv_contrib/releases for valid zip versions

## Menuing
From the main menu select ***1 UPDATE* menu pick.  Follow Instructions that
will guide you through the menu steps.  If there are errors you can
exit to the terminal to review output messages.  Problems will most likely
be related to Disk Space or Memory problems.    

You will be asked to reboot during some installation steps.
If you answer yes on successful completion of a step, you will be
sent to the next step otherwise you will be sent to the terminal
to review errors or back to the main menu as appropriate.
You may see warnings or not found messages and this is normal.  
 Eg tesseract (OCR) Not Found.

Users will be prompted to review output for errors and elect to continue.
You can repeat a particular step from the menu if required after
correcting or resolving any issues or errors.

## Logging
A log file called ***cv3_log.txt*** will be created to record system
information and the date/time and details for each operation.  
Review the log to check how long various steps took to complete.
On exit you will be prompted if you want to clear the log file.
A backup copy will be saved to ***cv3_log.txt.bak***. A new log will be created
. The log can span multiple sessions. You must intentionally clear the log
from the LOG menu or per commands below to clear.

    cd ~/opencv3-setup
    cp cv3-log.txt cv3-log.txt.bak
    rm cv3-log.txt

## Mount External USB Storage
***IMPORTANT*** If there is limited space on the Raspbian SD card
you may want to change ***INSTALL_DIR*** variable to point to
an external storage drive.

    cd ~/opencv3-setup
    nano cv3-install-menu.sh

Change the ***INSTALL_DIR*** variable to point to the desired mount location
or a symbolic link to the desired external storage device. ctrl-x y to save
and exit nano. See example mount commands below.

For more details on mounting external USB storage   
see https://www.htpcguides.com/properly-mount-usb-storage-raspberry-pi/

Sample commands to mount and use an external ntfs USB hard drive.
Plug ntfs formatted disk into a RPI USB slot.  From SSH or terminal session
use sample commands below. (Note) modify to suit your conditions

    cd ~
    sudo apt-get update
    sudo apt-get install ntfs-3g   # Make sure ntfs support installed
    sudo fdisk -l                  # will list drive if installed
    cd ~/
    mkdir /media/usb_cv3
    sudo mount -t ntfs-3g /dev/sda1 /media/usb_cv3
    df -h   #check space on usb device
    cd ~/opencv-setup
    nano cv3-install-menu.sh
    
in nano edit the variable per below.  ctrl-x y to save and exit.

    INSTALL_DIR='/media/usb_cv3/tmp_cv3'

## Testing Build
To Test build run for python or python3. See Example below

    python3

At the >>> python prompt enter the following

    import cv2
    cv2.__version__

You should see output indicating the opencv version installed.
Press ctrl-d to exit python interpreter

See my other github repo at https://github.com/pageauc
for various opencv motion and opencv camera projects.

## Credits
Script Steps Based on GitHub Repo
https://github.com/Tes3awy/OpenCV-3.2.0-Compiling-on-Raspberry-Pi

For Additional Details See https://github.com/pageauc/opencv3-setup

Have Fun
Claude Pageau
YouTube Channel https://www.youtube.com/user/pageaucp
GitHub Repo https://github.com/pageauc

