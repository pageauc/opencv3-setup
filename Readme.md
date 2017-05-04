# Raspberry Pi OpenCV3 3.0.0 Semi Automatic Compile from Source
#### Whiptail menu enabled script to compile opencv3 from source for Raspberry Pi  

### Introduction
This Bash script uses a whiptail menu to assist users who want to compile opencv 3.0.0 from source.
It will update/upgrade Raspberry Pi, Install build dependencies, download source, perform a cmake and compile source.
Users will be prompted to review output for errors and elect to continue.  They can also repeat a particular step from
the menu as required

### How to Install

#### Quick Install   
Easy Install of sonic-track onto a Raspberry Pi Computer with latest Raspbian.
This is a whiptail menu system that allows install of opencv3 if required 

    curl -L https://raw.github.com/pageauc/opencv3-setup/master/setup.sh | bash

From a computer logged into the RPI via ssh (Putty) session use mouse to highlight command above, right click, copy.  
Then select ssh(Putty) window, mouse right click, paste.  The command should 
download the install menu script.

#### Manual Install   
From logged in RPI SSH session or console terminal perform the following.

    wget https://raw.github.com/pageauc/opencv3-setup/master/setup.sh
    chmod +x setup.sh
    ./setup.sh

### Opencv3 Install (if required)
Menu system to install opencv3 on the latest RPI Jessie disto. I have written a menu driven
install script called cv3-setup.sh.  Use this if you do not have opencv3 already installed.  
cv3-setup.sh menu picks allow updating, installing dependencies, downloads, cmake, compile and make install of opencv 3.0.0.
I tried opencv 3.2.0 but had errors so it is best to stick with 3.0.0 per this script.
To Run the whiptail menu setup script.  From a logged in ssh or terminal session run

    cd ~/opencv3-setup
    ./cv3-setup.sh    
 
You will be asked to reboot at certain steps.  

More information is available here http://www.pyimagesearch.com/2015/10/26/how-to-install-opencv-3-on-raspbian-jessie/ 
    
Have Fun   
Claude Pageau    
YouTube Channel https://www.youtube.com/user/pageaucp   
GitHub Repo https://github.com/pageauc

