#!/bin/bash
# Script to assist with installing sonic-track and OpenCV3
# If problems are encountered exit to command to try to resolve
# Then retry menu pick again or continue to next step
# version 0.20

function do_anykey ()
{
   echo "------------------------------"
   echo "  Review messages for Errors"
   echo "  Exit to Console to Resolve"
   echo "------------------------------"   
   read -p "M)enu E)xit ?" choice
   case "$choice" in
      m|M ) echo "Back to Main Menu"
       ;;
      e|E ) echo "Install Aborted. Bye"
            exit 1
       ;;
        * ) echo "invalid Selection"
            exit 1 ;;
   esac
}

function do_rpi_update ()
{
   cd ~/   
   # Update Raspian to Lastest Releases
   echo "Updating Raspbian Please Wait ..."
   echo "---------------------------------"    
   sudo apt-get update
   echo "Upgrading Rasbian Please Wait ..."
   echo "---------------------------------"    
   sudo apt-get upgrade
   # Perform rpi-update
   echo "updating Raspbian rpi-update"
   echo "----------------------------"    
   sudo rpi-update
   echo "----------------------------"    
   echo "It is Time to Reboot after"
   echo "updating Raspbian Jessie"
   echo "----------------------------"    
   read -p "Reboot Now? (y/n)?" choice
   case "$choice" in 
     y|Y ) echo "yes"
           echo "Rebooting Now"
           sudo reboot
           ;;
     n|N ) echo "Back To Main Menu"
           ;;
       * ) echo "invalid Selection"
           exit 1
           ;;
  esac
}

function do_cv3_dep ()
{
   cd ~/
   # Install opencv3 build dependencies
   echo "Installing opencv3 build and run dependencies"
   echo "---------------------------------------------"       
   sudo apt-get install -y build-essential git cmake pkg-config
   sudo apt-get install -y libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev
   sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
   sudo apt-get install -y libxvidcore-dev libx264-dev
   sudo apt-get install -y libgtk2.0-dev
   sudo apt-get install -y libatlas-base-dev gfortran
   sudo apt-get install -y python2.7-dev python3-dev     
   wget https://bootstrap.pypa.io/get-pip.py
   sudo python get-pip.py
   sudo pip install numpy
   echo "Download and unzip opencv 3.0.0"
   echo "-------------------------------"    
   # Install opencv3 ver 3.0.0 download and unzip
   wget -O opencv.zip https://github.com/Itseez/opencv/archive/3.0.0.zip 
   unzip opencv.zip 
   do_anykey
}

function do_cv3_install ()
{
   cd ~/
   echo "cmake prior to compiling opencv 3.0.0"
   echo "-------------------------------------"
   echo "This will take a few minutes ...."   
   # Compile opencv3 for RPI
   cd ~/opencv-3.0.0/
   mkdir build
   cd build
   cmake -D CMAKE_BUILD_TYPE=RELEASE \
         -D CMAKE_INSTALL_PREFIX=/usr/local \
         -D INSTALL_C_EXAMPLES=OFF \
         -D INSTALL_PYTHON_EXAMPLES=ON \
         -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib-3.0.0/modules \
         -D BUILD_EXAMPLES=ON ..
      echo "--------------------------------" 
      echo " Check if cmake above had errors"
      echo "--------------------------------" 
      echo "n exits to console"
      read -p "Was cmake successful y/n ?" choice
      case "$choice" in
        y|Y ) echo "Compiling openCV3 ver 3.0.0"
              echo "This will take approx 1h 40 min"      
              make -j4
              echo "------------------------------------"  
              echo " Check if opencv compile had errors "
              echo "------------------------------------"               
              read -p "Was Compile Successful y/n ?" choice
              case "$choice" in            
                y|Y ) echo "Installing opencv 3.0.0"
                      sudo make install
                      ;;
                n|N ) echo "Please Investigate Problem and Try Again"
                      exit 1
                      ;;
                  * ) echo "invalid Selection"
                      exit 1
                      ;;  
              esac                      
            ;;
        n|N ) echo "cmake failed so Investigate Problem and Try again"
              exit 1
              ;;
          * ) echo "invalid Selection"
              exit 1
              ;;
      esac
}


#------------------------------------------------------------------------------
function do_about()
{
  whiptail --title "About" --msgbox " \
   sonic-track project Install Assist
      written by Claude Pageau

This Menu will help install opencv3 if required

To Run sonic-track
depending on how you have things configured
Run

cd ~/sonic-track
./sonic-track.sh                    

             Good Luck 
\
" 35 70 35
}


#------------------------------------------------------------------------------
function do_main_menu ()
{
  SELECTION=$(whiptail --title "sonic-track opencv3 Install" --menu "Arrow/Enter Selects or Tab Key" 20 70 10 --cancel-button Quit --ok-button Select \
  "a " "Raspbian Jessie Update, Upgrade and rpi-update" \
  "b " "OpenCV3 Install Build Dependencies and Download Source" \
  "c " "OpenCV3 Make, Compile and Install" \
  "d " "sonic-track Edit config.py Settings" \
  "e " "About" \
  "q " "Quit Menu Back to Console"  3>&1 1>&2 2>&3)

  RET=$?
  if [ $RET -eq 1 ]; then
    exit 0
  elif [ $RET -eq 0 ]; then
    case "$SELECTION" in
      a\ *) do_rpi_update ;;
      b\ *) do_cv3_dep ;;
      c\ *) do_cv3_install ;; 
      d\ *) nano ~/sonic-track/config.py ;;
      e\ *) do_about ;;
      q\ *) echo "To Run sonic-track run the following commands"
            echo ""
            echo "cd ~/sonic-track"
            echo "./sonic-track.sh"
            echo ""
            echo "Good Luck ..."
            exit 0 ;;
         *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running selection $SELECTION" 20 60 1
  fi
}

while true; do
   do_main_menu
done

