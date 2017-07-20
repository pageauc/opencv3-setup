## Raspberry Pi Menu Driven OpenCV3 3.2.0 Compile from Source Script
#### Whiptail menu enabled script to help compile opencv3 from source  

### Introduction
This Bash script uses a whiptail menu to assist users who want to compile opencv 3.2.0 from source.
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

### How to Run
This is a whiptail Menu system to assist with installation of opencv3 on the latest RPI Jessie disto. I have written this menu driven
install script called cv3-setup.sh to make compiling cv3 from source easier. Use this if you do not have opencv3 already installed.  
cv3-setup.sh menu picks allow updating, installing dependencies, downloads, cmake, compile and make install of opencv 3.2.0.
I tried opencv 3.2.0 but had errors so it is best to stick with 3.2.0 per this script.
To Run the whiptail menu setup script.  From a logged in ssh or terminal session run

    cd ~/opencv3-setup
    ./cv3-setup.sh    
 
You will be asked to reboot at certain steps.  

This install is based on https://github.com/Tes3awy/OpenCV-3.2.0-Compiling-on-Raspberry-Pi 
    
Have Fun   
Claude Pageau    
YouTube Channel https://www.youtube.com/user/pageaucp   
GitHub Repo https://github.com/pageauc

