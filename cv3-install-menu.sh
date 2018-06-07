#!/bin/bash
PROG_VER='ver 2.2'
# Script to assist with installing OpenCV3
# If problems are encountered exit to command to try to resolve
# Then retry menu pick again or continue to next step

#--------------------------- End of User Variables ---------------------------

OPENCV_VER='3.4.1'   # This needs to be a valid opencv3 version number
                     # See https://github.com/opencv/opencv/releases

INSTALL_DIR='/home/pi/tmp_cv3'    # Working folder for Download/Compile of opencv files
                                  # Note Use symbolic link to external drive mount point
                                  # if sd card too small  Min 5-6 GB Free Space is Needed

#--------------------------- End of User Variables ----------------------------

# System Created Variables
PROG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # folder location of this script
LOG_FILE="$PROG_DIR/cv3-log.txt"
BUILD_DIR=$INSTALL_DIR/opencv-$OPENCV_VER/build
# Get Total Memory
TOTAL_MEM=$(free -m | grep Mem | tr -s " " | cut -f 2 -d " ")
# Get Total Swap Memory
TOTAL_SWAP=$(free -m | grep Swap | tr -s " " | cut -f 2 -d " ")

#------------------------------------------------------------------------------
function do_Initialize ()
{
   # Create Log File if it Does Not Exist
   if [ ! -f $LOG_FILE ] ; then
      echo "$0 $PROG_VER OPENCV_VER=$OPENCV_VER" > $LOG_FILE
      uname -a >> $LOG_FILE
      echo " ----- Start CPU Info -----" >> $LOG_FILE
      cat /proc/cpuinfo >> $LOG_FILE
      echo "------ End CPU Info -------" >> $LOG_FILE
   fi

   # Set the number of cores for Compiling with make
   # 1G memory gets two cores otherwise only one both get 1024 MB Swap
   if [ "$TOTAL_MEM" -gt "512" ] ; then
      COMPILE_CORES="-j2"
   else
      COMPILE_CORES="-j1"
   fi
}

#------------------------------------------------------------------------------
function do_check_cv3_ver ()
{
   opencv_zip="https://github.com/Itseez/opencv/archive/$OPENCV_VER.zip"
   echo "Checking opencv version $OPENCV_VER  Wait ..."
   # Check if there is a url at the destination link
   wget -S --spider $opencv_zip 2>&1 | grep -q 'HTTP/1.1 200 OK'
   if [ $? -eq 0 ]; then
       echo "Variable OPENCV_VER=$OPENCV_VER Is a Valid opencv Version"
       sleep 4
   else
       echo "----------------- ERROR ------------------------"
       echo "File Not Found at $opencv_zip"
       echo "1 Check Internet Connection."
       echo "2 Check variable OPENCV_VER=$OPENCV_VER"
       echo "  Using url verify opencv zip release is valid"
       echo "  at https://github.com/opencv/opencv/releases"
       echo ""
       echo "Run command below to Edit this script file"
       echo ""
       echo "    nano $0"
       echo ""
       echo "Edit variable OPENCV_VER=$OPENCV_VER"
       echo "Change to a valid opencv release number eg 3.4.1"
       echo "------------------------------------------------"
       echo "Exit to Terminal Bye ..."
       exit 1
   fi
}

#------------------------------------------------------------------------------
function do_anykey ()
{
   echo ""
   read -p "Return to Main Menu? (y/n)? " choice
   case "$choice" in
     n|N ) echo "Exit to Terminal Bye ..."
           exit 1
           ;;
       * ) do_main_menu
           ;;
   esac
}

#------------------------------------------------------------------------------
function do_swap_check ()
{
    if [ "$TOTAL_SWAP" -gt "1000" ] ; then
        echo "Total Mem is $TOTAL_MEM MB so $TOTAL_SWAP MB Swap is OK" | tee -a $LOG_FILE
    else
        if [ ! -f "/etc/dphys-swapfile.bak" ] ; then
            echo "Temporarily Increase Swap Space to 1024 MB" | tee -a $LOG_FILE
            sudo cp /etc/dphys-swapfile /etc/dphys-swapfile.bak
            sudo cp $PROG_DIR/dphys-swapfile.1024 /etc/dphys-swapfile
            echo "Stop Swap  Wait ..."
            sudo /etc/init.d/dphys-swapfile stop
            echo "Start Swap Wait ..."
            sudo /etc/init.d/dphys-swapfile start
            echo "Done ..."
            TOTAL_SWAP=$(free -m | grep Swap | tr -s " " | cut -f 2 -d " ")
            echo "Total Mem $TOTAL_MEM MB Swap is Now OK at $TOTAL_SWAP MB" | tee -a $LOG_FILE
        fi
    fi
}

function do_swap_back ()
{
    if [ -f "/etc/dphys-swapfile.bak" ] ; then
        echo "Found File /etc/dphys-swapfile.bak" | tee -a $LOG_FILE
        echo "Returning Swap Settings Back Previous" | tee -a $LOG_FILE
        sudo cp /etc/dphys-swapfile.bak /etc/dphys-swapfile
        sudo rm /etc/dphys-swapfile.bak
        echo "Stop Swap  Wait ..."
        sudo /etc/init.d/dphys-swapfile stop
        echo "Start Swap Wait ..."
        sudo /etc/init.d/dphys-swapfile start
        echo "Done ..."
        TOTAL_SWAP=$(free -m | grep Swap | tr -s " " | cut -f 2 -d " ")
        echo "Total Mem=$TOTAL_MEM MB  Total Swap=$TOTAL_SWAP MB" | tee -a $LOG_FILE
    fi
}

#------------------------------------------------------------------------------
function do_rpi_update ()
{
   clear
   # Update Raspbian to Lastest Releases
   DATE=$(date)
   echo "$DATE STEP 1 - Update/Upgrade Raspbian Please Wait ..." | tee -a $LOG_FILE
   echo "$DATE sudo apt-get update    Please Wait ..." | tee -a $LOG_FILE
   START=$(date +%s)
   echo "-- Update Start: $DATE" | tee -a $LOG_FILE
   sudo apt-get -y update
   DATE=$(date)
   END=$(date +%s)
   DIFF=$((END - START))
   echo "-- Update End: $DATE" | tee -a $LOG_FILE
   echo "-- Update Took: $(($DIFF / 60)) min $(($DIFF % 60)) sec" | tee -a $LOG_FILE
   echo ""
   DATE=$(date)
   echo "$DATE sudo apt-get upgrade   Please Wait ..."
   START=$(date +%s)
   echo "-- Upgrade Start: $DATE" | tee -a $LOG_FILE
   sudo apt-get -y upgrade
   DATE=$(date)
   END=$(date +%s)
   DIFF=$((END - START))
   echo "-- Upgrade End: $DATE" | tee -a $LOG_FILE
   echo "-- Upgrade Took: $(($DIFF / 60)) min $(($DIFF % 60)) sec" | tee -a $LOG_FILE
   sudo apt-get -y autoremove
   echo ""
   echo "------------------ STEP 1 INSTRUCTIONS --------------------"
   echo "If there are Significant Changes then a Reboot Is Required."
   echo "After Reboot Run this menu script again and Select"
   echo "Menu Pick: 2 DEP Install Build Dependencies and Download Source"
   echo "-----------------------------------------------------------"
   read -p "Reboot Now? (y/n)? " choice
   case "$choice" in
     y|Y ) echo "yes"
           echo "Rebooting Now"
           sudo reboot
           ;;
       * ) do_cv3_dep
           ;;
  esac
}

#------------------------------------------------------------------------------
function do_cv3_dep ()
{
   clear
   # Install opencv3 build dependencies
   echo "STEP 2 Install opencv $OPENCV_VER Build Dependencies"
   echo ""
   echo "This step will install opencv $OPENCV_VER Build Dependencies"
   echo "Then Download and unzip opencv source files to $INSTALL_DIR Folder"
   echo ""
   df -h
   echo ""
   echo "---------------- STEP 2 INSTRUCTIONS ---------------"
   echo "A Fresh Build Needs at Least 16GB SD with 5-6 GB Free. Free Space"
   echo "could be less depending on what dependencies are already installed"
   echo "If you are using a smaller system SD or are Low on Free Disk Space."
   echo "You can mount USB media and change variable INSTALL_DIR in this script."
   echo "Installs Will Take a While so be Patient ..."
   echo "----------------------------------------------------"
   read -p "Install Dep and Source? (y/n)? " choice
   case "$choice" in
    n|N ) do_main_menu
          ;;
      * ) echo ""
          ;;
   esac
   DATE=$(date)
   echo "$DATE STEP 2-1 Installing Dependencies  Please Wait ..." | tee -a $LOG_FILE
   echo ""
   START=$(date +%s)
   echo "-- apt-get-install Start: $DATE" | tee -a $LOG_FILE
   sudo apt-get install -y build-essential
   sudo apt-get install -y git
   sudo apt-get install -y cmake
   sudo apt-get install -y pkg-config
   sudo apt-get install -y libjpeg-dev
   sudo apt-get install -y libtiff5-dev
   sudo apt-get install -y libjasper-dev
   sudo apt-get install -y libpng12-dev
   sudo apt-get install -y libgtk2.0-dev
   sudo apt-get install -y libgstreamer0.10-0-dbg
   sudo apt-get install -y libgstreamer0.10-0
   sudo apt-get install -y libgstreamer0.10-dev
   sudo apt-get install -y libv4l-0
   sudo apt-get install -y libavcodec-dev
   sudo apt-get install -y libavformat-dev
   sudo apt-get install -y libswscale-dev
   sudo apt-get install -y libv4l-dev
   sudo apt-get install -y libxvidcore-dev
   sudo apt-get install -y libx264-dev
   sudo apt-get install -y libatlas-base-dev
   sudo apt-get install -y python2.7-dev
   sudo apt-get install -y python3-dev
   sudo apt-get install -y gfortran
   sudo apt-get install -y python-numpy
   sudo apt-get install -y python-scipy
   sudo apt-get install -y python-matplotlib
   sudo apt-get install -y default-jdk ant
   sudo apt-get install -y libgtkglext1-dev
   sudo apt-get install -y v4l-utils
   sudo apt-get install -y gphoto2
   DATE=$(date)
   END=$(date +%s)
   DIFF=$((END - START))
   echo "-- apt-get-install End: $DATE" | tee -a $LOG_FILE
   echo "-- apt-get-install Took: $(($DIFF / 60)) min $(($DIFF % 60)) sec" | tee -a $LOG_FILE
   echo "Perform sudo apt-get autoremove"
   echo ""
   sudo apt-get -y autoremove
   if [ ! -d $INSTALL_DIR ] ; then
       echo "Create dir $INSTALL_DIR"
       mkdir $INSTALL_DIR
   fi
   cd $INSTALL_DIR
   echo ""
   echo "Install pip"
   rm get-pip.py
   wget https://bootstrap.pypa.io/get-pip.py
   sudo python get-pip.py
   echo ""
   echo "Install numpy"
   sudo pip install numpy
   echo ""
   echo "$DATE Done Install of Build Essentials and Dependencies ..." | tee -a $LOG_FILE
   echo ""
   DATE=$(date)
   echo "$DATE STEP 2-2 Download and unzip opencv $OPENCV_VER Source Files" | tee -a $LOG_FILE
   echo ""
   START=$(date +%s)
   echo "-- opencv.zip Start: $DATE" | tee -a $LOG_FILE
   wget -O opencv.zip https://github.com/Itseez/opencv/archive/$OPENCV_VER.zip
   unzip -o opencv.zip
   DATE=$(date)
   END=$(date +%s)
   DIFF=$((END - START))
   echo "-- opencv.zip End: $DATE" | tee -a $LOG_FILE
   echo "-- opencv.zip Took: $(($DIFF / 60)) min $(($DIFF % 60)) sec" | tee -a $LOG_FILE
   echo ""
   DATE=$(date)
   echo "$DATE STEP 2-3 Download and unzip opencv $OPENCV_VER Contrib Files" | tee -a $LOG_FILE
   echo ""
   START=$(date +%s)
   echo "-- opencv.zip Start: $DATE" | tee -a $LOG_FILE
   wget -O opencv_contrib.zip https://github.com/Itseez/opencv_contrib/archive/$OPENCV_VER.zip
   unzip -o opencv_contrib.zip
   DATE=$(date)
   END=$(date +%s)
   DIFF=$((END - START))
   echo "-- opencv_contrib.zip End: $DATE" | tee -a $LOG_FILE
   echo "-- opencv_contrib.zip Took: $(($DIFF / 60)) min $(($DIFF % 60)) sec" | tee -a $LOG_FILE
   echo ""
   echo "Done Requirements for OpenCV $OPENCV_VER Source Build."
   echo ""
   df -h
   echo ""
   read -p "Proceed to STEP 3 COMPILE (y/n)? " choice
   case "$choice" in
     y|Y ) do_cv3_make
           ;;
      * ) do_main_menu
          ;;
   esac
}

#------------------------------------------------------------------------------
function do_cv3_cmake ()
{
   if [ ! -d $INSTALL_DIR ] ; then
       clear
       echo "---------- STEP 3-1 ERROR --------------"
       echo " $INSTALL_DIR Director Not Found."
       echo " You Need to Run STEP 2 DEP Menu Pick"
       echo " in Order to Install Dependencies"
       echo " and Download Opencv3 Source Files"
       echo "--------------------------------------"
       read -p "Proceed to STEP 2 DEP (y/n)? " choice
       case "$choice" in
         y|Y ) do_cv3_dep
               ;;
          * ) do_main_menu
              ;;
       esac
   fi
   cd $INSTALL_DIR
   clear
   DATE=$(date)
   echo "$DATE STEP 3-1 Run cmake Prior to Compiling opencv $OPENCV_VER with make -j1" | tee -a $LOG_FILE
   echo ""
   if [ ! -d "$BUILD_DIR" ] ; then
     echo "Create build directory $BUILD_DIR"
     mkdir $BUILD_DIR
   fi
   cd $BUILD_DIR
   echo "------------- STEP 3 INSTRUCTIONS -----------------"
   echo " cmake Will Take a Few Minutes ...."
   echo " At End of cmake You Will See a Messages"
   echo " Configuring done and Generating done"
   echo " These Will Take a While to Finish"
   echo " So Be Patient ....."
   echo "---------------------------------------------------"
   read -p "Start cmake Now (y/n)? " choice
   case "$choice" in
     n|N ) do_cv3_make
           ;;
       * ) echo "$DATE STEP 3-1 Run cmake for opencv $OPENCV_VER" | tee -a $LOG_FILE
           ;;
   esac
   START=$(date +%s)
   echo "-- cmake Start: $DATE" | tee -a $LOG_FILE
   cat /proc/device-tree/model | grep -aq "Raspberry Pi 3"
   if [ $? -eq 0 ]; then
       # This optimizes for Raspberry Pi 3 Models but is turned off for RPI B+
       echo "-- cmake Compile for Non Raspberry Pi 3 ENABLE NEON=ON" | tee -a $LOG_FILE
       cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_C_EXAMPLES=OFF \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D OPENCV_EXTRA_MODULES_PATH=$INSTALL_DIR/opencv_contrib-$OPENCV_VER/modules \
        -D BUILD_EXAMPLES=ON \
        -D ENABLE_NEON=ON ..
   else
       echo "-- cmake Compile for Raspberry Pi 3 ENABLE NEON=OFF" | tee -a $LOG_FILE
       cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_C_EXAMPLES=OFF \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D OPENCV_EXTRA_MODULES_PATH=$INSTALL_DIR/opencv_contrib-$OPENCV_VER/modules \
        -D BUILD_EXAMPLES=ON \
        -D ENABLE_NEON=OFF ..
   fi
   echo "----------------------- End of cmake Messages -------------------------"
   DATE=$(date)
   END=$(date +%s)
   DIFF=$((END - START))
   echo "-- cmake End: $DATE" | tee -a $LOG_FILE
   echo "-- cmake Took: $(($DIFF / 60)) min $(($DIFF % 60)) sec" | tee -a $LOG_FILE
   echo "---------- STEP 3-1 INSTRUCTIONS ------------"
   echo " 1- Review cmake messages above for Errors"
   echo " 2- Check that Python 2 and Python 3 sections"
   echo "    Have directory path entries"
   echo " 3- Check cvconfig.h points to a build folder"
   echo " 4- Last Messages should say"
   echo "-- Configuring done"
   echo "-- Generating done"
   echo "-- build files have been written to: ..."
   echo "---------------------------------------------"
   read -p "Was cmake Successful (y/n)? " choice
   case "$choice" in
     n|N ) echo "------------ STEP 3-1 INSTRUCTIONS ---------------"
           echo "If cmake Failed. Investigate Problem and Try again"
           echo "You Can Run make clean to Clear Existing cmake"
           echo "and force a full compile from scratch"
           echo "Otherwise Compile Will Continue Where It Left Off"
           echo "Once you Resolve make Error Issues."
           echo "--------------------------------------------------"
           read -p "(optional) Run make clean (y/n)? " choice
           case "$choice" in
             y|Y ) echo "Running sudo make clean"
                   sudo make clean
                   echo "Done make clean"
                   echo "Ready to Try Full cmake Once Problems Resolved."
                   do_anykey
                   ;;
               * ) echo "Use Existing make build Files"
                   echo "Exit to Terminal to Review Errors"
                   exit 1
                   ;;
           esac
         ;;
     * ) do_cv3_make
         ;;
   esac
}

#------------------------------------------------------------------------------
function do_cv3_make ()
{
   if [ ! -d "$BUILD_DIR" ] ; then
      echo "----------- STEP 3-2 ERROR -----------"
      echo "Could Not Find Build Folder $BUILD_DIR"
      echo "--------------------------------------"
      read -p "STEP 3-2 Press Enter to Run cmake " choice
      do_cv3_cmake
   fi
   echo "--------------- STEP 3-2 INSTRUCTIONS --------------------"
   echo "Full Compile of openCV $OPENCV_VER will take many hours ..."
   echo "A single core RPI with 512 MB RAM can take approx 27 hours"
   echo "A quad core RPI with 1 GB of RAM can take 3 - 6 hours"
   echo "RAM=$TOTAL_MEM MB  Run make $COMPILE_CORES"
   echo ""
   echo "Once Compile is started, Go for a nice Long Walk"
   echo "or Binge watch Game of Thrones or Something Else....."
   echo "-----------------------------------------------------------"
   read -p "Start Compile Now? (y/n)? " choice
   case "$choice" in
     y|Y ) do_swap_check
           TOTAL_SWAP=$(free -m | grep Swap | tr -s " " | cut -f 2 -d " ")
           DATE=$(date)
           echo "$DATE STEP 3-2 Start Compile of opencv $OPENCV_VER" | tee -a $LOG_FILE
           START=$(date +%s)
           echo "-- make $COMPILE_CORES  RAM=$TOTAL_MEM  SWAP=$TOTAL_SWAP" | tee -a $LOG_FILE
           echo "-- mqke Start: $DATE" | tee -a $LOG_FILE
           make $COMPILE_CORES
           echo "--------------- End of make $COMPILE_CORES Messages ----------------"
           DATE=$(date)
           END=$(date +%s)
           DIFF=$((END - START))
           do_swap_back
           TOTAL_SWAP=$(free -m | grep Swap | tr -s " " | cut -f 2 -d " ")
           echo "-- make $COMPILE_CORES  RAM=$TOTAL_MEM  SWAP=$TOTAL_SWAP" | tee -a $LOG_FILE
           echo "-- make End: $DATE" | tee -a $LOG_FILE
           echo "-- make Took:  $(($DIFF / 60)) min $(($DIFF % 60)) sec" | tee -a $LOG_FILE
           echo "----------- STEP 3-2 INSTRUCTIONS --------------"
           echo "1- 1f Compile make $COMPILE_CORES is 100 percent"
           echo "   Proceed to STEP 4 make install"
           echo "2- If Less than 100 percent Complete"
           echo "   Record Errors and Investigate Problem."
           echo "------------------------------------------------"
           read -p "Was make Compile Successful? (y/n)? " choice
           case "$choice" in
             y|Y ) do_cv3_install
                   ;;
               * ) echo "When Errors Resolve Retry 3 COMPILE Menu Pick"
                   echo "Note make will Continue where it Left Off"
                   echo "Exit to Terminal to Review Errors Bye ..."
                   exit 1
                   ;;
           esac
           ;;
       * ) do_main_menu
           ;;
   esac
}

#------------------------------------------------------------------------------
function do_cv3_install ()
{
    clear
    DATE=$(date)
    echo "$DATE STEP 4 - Perform OpenCV $OPENCV_VER make install"
    echo "--------------- STEP 4 INSTRUCTIONS ----------------------------"
    echo "This Step will copy the compiled code to the system folders"
    echo "WARNING - Do NOT run this unless you have successfully completed"
    echo "          STEP 3 COMPILE"
    echo "----------------------------------------------------------------"
    read -p "Run make install Now? (y/n)? " choice
    case "$choice" in
       y|Y ) echo "Running make install  Wait ...."
             echo ""
             ;;
         * ) do_main_menu
             ;;
    esac
    if [ -d "$INSTALL_DIR/opencv-$OPENCV_VER/build" ] ; then
       cd $INSTALL_DIR/opencv-$OPENCV_VER/build
       DATE=$(date)
       echo "$DATE STEP 4 Start make install of opencv $OPENCV_VER" | tee -a $LOG_FILE
       START=$(date +%s)
       echo "-- make install Start: $DATE" | tee -a $LOG_FILE
       sudo make install
       sudo ldconfig
       DATE=$(date)
       END=$(date +%s)
       DIFF=$((END - START))
       echo "-- make install End: $DATE" | tee -a $LOG_FILE
       echo "-- make install Took:  $(($DIFF / 60)) min $(($DIFF % 60)) sec" | tee -a $LOG_FILE
       echo "--------------- STEP 4 INSTRUCTIONS -------------"
       echo "You Need to Reboot to Complete Install of OpenCV $open_ver"
       echo "-------------------------------------------------"
       read -p "Reboot Now? (y/n)? " choice
       case "$choice" in
          y|Y ) echo "Rebooting Now to Enable Changes"
                sudo reboot
                ;;
            * ) do_main_menu
                ;;
       esac
    else
       echo "------------------ STEP 4 ERROR ---------------------"
       echo " Directory Not Found $INSTALL_DIR/opencv-$OPENCV_VER/build"
       echo " You Need to Go Back to Step 2 to Install Source Files"
       echo "-----------------------------------------------------"
       read -p "Proceed to STEP 2 DEP (y/n)? " choice
       case "$choice" in
         y|Y ) do_cv3_dep
               ;;
          * ) do_main_menu
              ;;
       esac
    fi
}

#------------------------------------------------------------------------------
function do_cv3_cleanup ()
{
    clear
    if [ ! -d $INSTALL_DIR ] ; then
        echo "----------- STEP 5 ERROR -------------------"
        echo " Could Not File $INSTALL_DIR"
        echo " You Need to Run MENU PICK 2 DEP "
        echo " If You Have Not Previously Done This"
        echo "--------------------------------------------"
        do_anykey
    fi
    echo "5 - Delete OpenCV $OPENCV_VER Source Folders and zip files (optional)"
    echo ""
    echo "Current System Disk Status"
    df -h
    echo "------------- STEP 5 INSTRUCTIONS ---------------"
    echo "Temporary Source Files are in $INSTALL_DIR Folder"
    echo "You can DELETE this Folder and recover disk space"
    du -sh $INSTALL_DIR
    echo "-------------------------------------------------"
    read -p "DELETE $INSTALL_DIR Now? (y/n) " choice
    case "$choice" in
       y|Y ) read -p "Are you Sure? (y/n) " choice
             case "$choice" in
                y|Y ) echo ""
                      echo "BEFORE - Disk Space Status"
                      df -h
                      echo "Deleting $INSTALL_DIR"
                      ;;
                  * ) do_main_menu
                      ;;
             esac
             cd $INSTALL_DIR
             cd ..
             sudo rm -R $INSTALL_DIR
             echo ""
             echo "AFTER - Disk Space Status"
             df -h
             echo "Done Removing $INSTALL_DIR Source Folders and zip files .."
             do_anykey
             ;;
       n|N ) echo "Back To Main Menu"
             ;;
         * ) echo "invalid Selection"
             ;;
    esac
    echo ""
    echo "Current System Disk Status"
    df -h
    do_anykey
}

#------------------------------------------------------------------------------
function do_upgrade()
{
  if (whiptail --title "GitHub Upgrade speed-cam" \
               --yesno "Upgrade opencv3_setup Files from GitHub.\n" 0 0 0 \
               --yes-button "upgrade" \
               --no-button "Cancel" ); then
    curlcmd=('/usr/bin/curl -L curl -L https://raw.github.com/pageauc/opencv3-setup/master/setup.sh | bash')
    eval $curlcmd
    echo "Done $PROG_NAME Upgrade/Refresh"
    echo "Restart Menu to Implement Changes Bye ..."
    echo ""
    echo "    ./cv3-install-menu.sh"
    exit 1
  fi
}

#------------------------------------------------------------------------------
function do_log ()
{
  if [ -f "$LOG_FILE" ] ; then
     more $LOG_FILE
     do_main_menu
  else
     echo "Log File Not Found $LOG_FILE"
     do_anykey
     do_main_menu
  fi
}

#------------------------------------------------------------------------------
function do_about()
{
  whiptail --title "About" --msgbox "\
$0 $PROG_VER written by Claude Pageau
GitHub https://github.com/pageauc/opencv3-setup

This is a menu driven install script to download and
compile opencv3 from source code. Default is opencv 3.3.0
To change OPENCV_VER variable use nano to edit this script.
The OPENCV_VER variable will be verified at
https://github.com/Itseez/opencv/archive/
when this menu script is run.

Prerequisites
1 - RPI 2 or 3 Connected to Working Internet Connection
2 - Recent Jessie or Stretch Raspbian Release
    Recommended min 16GB SD card with at least 6 GB Free.
    if Free disk space is low or You have a smaller system SD.
    You can mount USB memory or hard disk and change the
    INSTALL_DIR variable in this script to point to the new path.

Instructions
You will be asked to reboot during some installation steps.
If you answer yes to successful completion of a step, you will be
sent to the next step otherwise you will be sent to the terminal
to review errors or back to the main menu as appropriate.
For Additional Details See https://github.com/pageauc/opencv3-setup
Script Steps Based on GitHub Repo
https://github.com/Tes3awy/OpenCV-3.2.0-Compiling-on-Raspberry-Pi
                      Good Luck
\
" 0 0 0
}

#------------------------------------------------------------------------------
function do_main_menu ()
{
  SELECTION=$(whiptail --title "opencv $OPENCV_VER Compile Assist" --menu "Arrow/Enter Selects or Tab Key" 20 70 10 --cancel-button Quit --ok-button Select \
  "1 UPDATE" "Run Raspbian Update and Upgrade" \
  "2 DEP" "Install Build Dependencies and Download Source" \
  "3 COMPILE $OPENCV_VER" "Run cmake and make $COMPILE_CORES" \
  "4 INSTALL $OPENCV_VER" "Run make install (Copy Files to production)" \
  "5 DELETE" "$INSTALL_DIR Source Folder and Files" \
  "6 UPGRADE" "$0 $PROG_VER Files from GitHub" \
  "7 LOG" "View Log File cv3-log.txt" \
  "8 ABOUT" "Information about this program" \
  "q QUIT" "Exit This Menu Program"  3>&1 1>&2 2>&3)

  RET=$?
  if [ $RET -eq 1 ]; then
    exit 0
  elif [ $RET -eq 0 ]; then
    case "$SELECTION" in
      1\ *) do_rpi_update
            do_main_menu ;;
      2\ *) do_cv3_dep
            do_main_menu ;;
      3\ *) do_cv3_cmake
            do_main_menu ;;
      4\ *) do_cv3_install
            do_main_menu ;;
      5\ *) do_cv3_cleanup
            do_main_menu ;;
      6\ *) do_upgrade
            do_main_menu ;;
      7\ *) do_log
            do_main_menu ;;
      8\ *) do_about
            do_main_menu ;;
      q\ *) echo ""
            echo "$0 $PROG_VER    written by Claude Pageau"
            echo "Bye ..."
            exit 0 ;;
         *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running selection $SELECTION" 20 60 1
  fi
}

clear
echo "$0 $PROG_VER    written by Claude Pageau"
echo ""
do_check_cv3_ver
do_Initialize
do_main_menu


