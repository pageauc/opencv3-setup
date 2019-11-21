#!/bin/bash
PROG_VER='ver 3.82'

# Script to assist with installing OpenCV3
# If problems are encountered exit to command to try to resolve
# Then retry menu pick again or continue to next step

PROG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # folder location of this script
PROG_NAME=$(basename -- "$0" .sh)   # Extract Program Name minus .sh extension
PROG_CONF="$PROG_DIR/$PROG_NAME.conf"  # Setup program conf file name
CUR_OPENCV_VER=$(echo 'import cv2 ; ver = cv2.__version__ ; print(ver)' | python)

#------------------------------------------------------------------------------
function read_config_file ()
{
    if [ -f $PROG_CONF ] ; then
        source $PROG_CONF
    else
        whiptail --title "$PROG_CONF File NOT Found" --msgbox " \
     File $PROG_CONF
     Variable Configuration File NOT Found.
     Could Not Import $PROG_NAME variables

     A replacement file will be downloaded from GitHub
     at https://github.com/pageauc/opencv3-setup
    \
    " 0 0 0
        echo "Downloading replacement cv3-install-menu.conf file"
        wget -O cv3-install-menu.conf https://raw.github.com/pageauc/opencv3-setup/master/cv3-install-menu.conf
        echo "Restarting cv3-install-menu.sh"
        ./cv3-install-menu.sh
    fi
}

#------------------------------------------------------------------------------
function check_working_dir ()
{
    WORKING_DIR=$( dirname $INSTALL_DIR )
    echo "Checking File System type for $WORKING_DIR"
    if [ -d $WORKING_DIR ]; then
        df -PTh $WORKING_DIR | awk '{print $2}' | grep fat
        if [ $? -eq 0 ]; then
            whiptail --title "WARNING FAT System Not Supported" --msgbox " \
 $WORKING_DIR is a FAT File System.
 IMPORTANT: FAT Does Not Support symlinks
 that are Required to Compile opencv2
 Run SETTINGS Menu Pick to Edit $PROG_CONF File and
 Change WORKING_DIR variable to Point to a Non FAT File System.
 NOTE: Leave /tmp_cv3 Entry since Dir will be Created.
 \
 " 0 0 0
            do_main_menu
        fi
    else
        whiptail --title "$WORKING_DIR Working Dir NOT Found" --msgbox " \

 $WORKING_DIR Working Directory NOT Found.

 Run SETTINGS Menu Pick
 Edit INSTALL_DIR variable to Point to a Valid directory
 for downloading the opencv working files.

 NOTE: Leave /tmp_cv3 Entry at end of INSTALL_DIR variable
       since it will be Created if it Does Not Exist.
 \
 " 0 0 0
        do_main_menu
    fi
}

#------------------------------------------------------------------------------
function do_Initialize ()
{
   # System Created Variables
   LOG_FILE="$PROG_DIR/cv3-log.txt"
   BUILD_DIR=$INSTALL_DIR/opencv-$OPENCV_VER/build
   # Get Total Memory
   TOTAL_MEM=$(free -m | grep Mem | tr -s " " | cut -f 2 -d " ")
   # Get Total Swap Memory
   TOTAL_SWAP=$(free -m | grep Swap | tr -s " " | cut -f 2 -d " ")
   DATE=$(date)
   # Set the number of cores for Compiling
   # 1G mem gets 2 cores 512 mem gets 1 core, Both get 1024 MB Swap
   if [ "$TOTAL_MEM" -gt "512" ] ; then
      COMPILE_CORES="-j2"
   else
      COMPILE_CORES="-j1"
   fi

   # Create Log File if it Does Not Exist
   if [ ! -f $LOG_FILE ] ; then
      echo "$DATE" > $LOG_FILE
      echo "$0 $PROG_VER OPENCV_VER=$OPENCV_VER  written by Claude Pageau" >> $LOG_FILE
      echo "------------------------ Start of Log -----------------------" >> $LOG_FILE
      echo "" >> $LOG_FILE
      uname -a >> $LOG_FILE
      cat /proc/device-tree/model >> $LOG_FILE
      echo "" >> $LOG_FILE
      echo "$TOTAL_MEM MB Total RAM mem  Compile Cores Set to $COMPILE_CORES" >> $LOG_FILE
      echo "" >> $LOG_FILE
      echo " ----- Start CPU Info -----" >> $LOG_FILE
      cat /proc/cpuinfo >> $LOG_FILE
      echo "------ End CPU Info -------" >> $LOG_FILE
      echo "" >> $LOG_FILE
   fi
}

#------------------------------------------------------------------------------
function check_min_free_space ()
{
    # Check Free disk space is above minimum
    FREE=`df -k --output=avail "$PWD" | tail -n1`  # df -k not df -h
    if [[ $FREE -lt 1572864 ]]; then               # 1.5 GB
        WARNING_MSG="
 $FREE KB free disk space is less than 1.5 GB
 Not enough space for a 1 GB swap file plus extra

 Please Investigate Problem and Try Again.
 "
        do_anykey
    else
        echo "OK - $FREE KB free disk space Found." >> $LOG_FILE
    fi
}

#------------------------------------------------------------------------------
function do_check_cv3_ver ()
{
    opencv_zip="https://github.com/Itseez/opencv/archive/$OPENCV_VER.zip"
    echo "Internet Check OpenCV version $OPENCV_VER  Wait ..."
    echo ""
    # Check if there is a url at the destination link
    wget -S --spider $opencv_zip 2>&1 | grep -q 'HTTP/1.1 200 OK'
    if [ $? -eq 0 ]; then
        echo "STATUS"
        echo "Current Installed python OpenCV version is $CUR_OPENCV_VER"
        echo "Variable OPENCV_VER=$OPENCV_VER Is a Valid OpenCV Version"
        echo ""
        if [ "$CUR_OPENCV_VER" == "$OPENCV_VER" ] ; then
            echo "WARNING"
            echo "Looks Like You Have the Latest python OpenCV Version $CUR_OPENCV_VER"
        else
            echo "UPGRADE"
            echo "python OpenCV Version From $CUR_OPENCV_VER"
            echo "                       To  $OPENCV_VER"
        fi
        echo ""
        read -p "Press Enter to Continue to Menu" choice
    else
        whiptail --title "opencv version $OPENCV_VER Check Problem" --msgbox " \
 Could NOT verify opencv $OPENCV_VER version
 at $opencv_zip

 1 Check Internet Connection.
 2 Check variable OPENCV_VER=$OPENCV_VER
   Using url https://github.com/opencv/opencv/releases
   Verify opencv zip release is valid.

 If Required, Run SETTINGS Menu pick
 and Edit variable OPENCV_VER=$OPENCV_VER to a
 valid opencv release version

 NOTE: The current installed python OpenCV version is $CUR_OPENCV_VER
\
" 0 0 0
        do_main_menu
   fi
}

#------------------------------------------------------------------------------
function do_anykey ()
{
    if (whiptail --title "WARNING" \
    --yes-button "Back" --no-button "Exit" --yesno " \
$WARNING_MSG
\
" 0 0) \
    then
      do_main_menu
    else
      exit
    fi
}

#------------------------------------------------------------------------------
function do_swap_check ()
{
    if [ "$TOTAL_SWAP" -gt "1000" ] ; then
        echo "Total Mem is $TOTAL_MEM MB so $TOTAL_SWAP MB Swap is OK" | tee -a $LOG_FILE
    else
        if [ ! -f "/etc/dphys-swapfile.bak" ] ; then
            check_min_free_space
            echo "Temporarily Increase Swap Space to 1024 MB" | tee -a $LOG_FILE
            sudo cp /etc/dphys-swapfile /etc/dphys-swapfile.bak
            sudo cp $PROG_DIR/dphys-swapfile.1024 /etc/dphys-swapfile
            echo "Stop Swap  Wait ...  "
            sudo /etc/init.d/dphys-swapfile stop
            echo "Start Swap. First Time Might Take a While so Be Patient ..."
            sudo /etc/init.d/dphys-swapfile start
            echo "Done ..."
            TOTAL_SWAP=$(free -m | grep Swap | tr -s " " | cut -f 2 -d " ")
            echo "Total Mem $TOTAL_MEM MB Swap is Now OK at $TOTAL_SWAP MB" | tee -a $LOG_FILE
        fi
    fi
}

#------------------------------------------------------------------------------
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
  if [ -d "$INSTALL_DIR/opencv-$OPENCV_VER" ] ; then
    if (whiptail --title "Folder Already Exists" \
    --yes-button "Back" --no-button "Repeat"  --yesno " \
 WARNING
 $INSTALL_DIR/opencv-$OPENCV_VER
 Folder Already Exists.

 If a Previous Install was Successful,
 Do You Really Want to Repeat Install of
 opencv Dependencies and Source Files Again?
 \
 " 0 0) \
    then
      do_main_menu
    else
      do_cv3_dep_install
    fi
  else
     do_cv3_dep_install
  fi
}

#------------------------------------------------------------------------------
function do_cv3_dep_install ()
{
   check_min_free_space
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
   sudo apt-get install -y libtiff-dev
   sudo apt-get install -y libjasper-dev
   sudo apt-get install -y libpng-dev
   sudo apt-get install -y libavcodec-dev
   sudo apt-get install -y libavformat-dev
   sudo apt-get install -y libswscale-dev
   sudo apt-get install -y libgtk2.0-dev
   sudo apt-get install -y libgstreamer0.10-0-dbg
   sudo apt-get install -y libgstreamer0.10-0
   sudo apt-get install -y libgstreamer0.10-dev
   sudo apt-get install -y libv4l-0
   sudo apt-get install -y libv4l-dev
   sudo apt-get install -y libxvidcore-dev
   sudo apt-get install -y libgtk-3-dev
   sudo apt-get install -y libx264-dev
   sudo apt-get install -y libqtgui4
   sudo apt-get install -y libcanberra-gtk*
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
   sudo apt-get install -y python-pip
   sudo apt-get install -y python3-pip
   sudo apt-get install -y ntfs-3g
   DATE=$(date)
   END=$(date +%s)
   DIFF=$((END - START))
   echo "-- apt-get-install End: $DATE" | tee -a $LOG_FILE
   echo "-- apt-get-install Took: $(($DIFF / 60)) min $(($DIFF % 60)) sec" | tee -a $LOG_FILE
   echo "Perform sudo apt-get autoremove and clean"
   echo ""
   sudo apt-get -y autoremove
   sudo apt-get clean
   if [ ! -d $INSTALL_DIR ] ; then
       echo "Create dir $INSTALL_DIR"
       mkdir -p $INSTALL_DIR
       if [ $? -ne 0 ] ; then
          WARNING_MSG="
 Could Not Create Dir at $INSTALL_DIR
 Check permissions
 If on a mounted Device make sure
 1- Device is mounted and is NOT FAT32
 2- Device Must be writeable by Pi user.
    Check ownership and permissions

 Exit to Terminal to Investigate
 "
          do_anykey
       fi
   fi
   cd $INSTALL_DIR
   echo ""
   echo "Install pip"
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
   rm opencv.zip
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
   rm opencv_contrib.zip
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
     y|Y ) do_cv3_cmake
           ;;
      * ) do_main_menu
          ;;
   esac
}

#------------------------------------------------------------------------------
function do_cv3_compile_menu ()
{
  cd $INSTALL_DIR
  clear
  if [ ! -d "$BUILD_DIR" ] ; then
    echo "Create build directory $BUILD_DIR"
    mkdir -p $BUILD_DIR
  fi
  cd $BUILD_DIR
  SELECTION=$(whiptail --title "COMPILE OpenCV Menu from $CUR_OPENCV_VER to $OPENCV_VER" --menu "Arrow/Enter Selects or Tab Key" 0 0 0 --cancel-button Quit --ok-button Select \
  "1 CMAKE" "Required unless a previous cmake was successful" \
  "2 MAKE" "Run/Continue make compile if a previous cmake was successful" \
  "3 CLEAN" "Run a make clean to Force compile from Start (Lose Previous Progress)" \
  "q BACK" "Back to Main Menu"  3>&1 1>&2 2>&3)

  RET=$?
  if [ $RET -eq 1 ]; then
    exit 0
  elif [ $RET -eq 0 ]; then
    case "$SELECTION" in
      1\ *) do_cv3_cmake
            ;;
      2\ *) do_cv3_make
            ;;
      3\ *) do_make_clean
            ;;
      q\ *) cd $PROG_DIR
            do_main_menu
            ;;
         *) whiptail --msgbox "Programmer error: unrecognised option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running selection $SELECTION" 20 60 1
  fi
}

#------------------------------------------------------------------------------
function do_cv3_cmake ()
{
   if [ ! -d "$BUILD_DIR" ] ; then
      echo "Create build directory $BUILD_DIR"
      mkdir -p $BUILD_DIR
   fi
   cd $BUILD_DIR
   if [ ! -d $INSTALL_DIR ] ; then
       clear
       if (whiptail --title "$INSTALL_DIR Director Not Found" \
 --yes-button "Back" --no-button "Run DEP"  --yesno "\

 $INSTALL_DIR Director Not Found.

 You Need to Run STEP 2 DEP Menu Pick
 in Order to Install Dependencies
 and Download Opencv3 Source Files.

 \
 " 0 0) \
        then
          do_main_menu
        else
          do_cv3_dep
        fi
   fi

   if (whiptail --title "cmake INSTRUCTIONS" \
 --yes-button "Back" --no-button "Run cmake"  --yesno "\

 cmake will scan opencv dependencies, source directory tree
 and customize for the Raspberry Pi environment.  This must be done
 before a make compile can be performed.

 You will see Failed, not found, no package, Etc messages during cmake.
 This is normal and not fatal. Fatal errors will normally
 stop cmake before completion.

 If cmake is OK Last Messages should say
 -- Configuring done
 -- Generating done
 -- Build files have been written to: ...

 Note: These will take a while to complete so be patient ...

 \
 " 0 0) \
   then
      do_cv3_compile_menu
   else
      clear
      DATE=$(date)
      echo "$DATE STEP 3-1 Run cmake Prior to Compiling opencv $OPENCV_VER with make -j1" | tee -a $LOG_FILE
   fi
   START=$(date +%s)
   cat /proc/device-tree/model
   echo ""
   echo "-- cmake Start: $DATE" | tee -a $LOG_FILE
   cat /proc/device-tree/model | grep -aq "Raspberry Pi 4"
   if [ $? -eq 0 ]; then
       echo "-- cmake Compile for Raspberry Pi 4 ENABLE NEON=ON" | tee -a $LOG_FILE
       cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D OPENCV_EXTRA_MODULES_PATH=$INSTALL_DIR/opencv_contrib-$OPENCV_VER/modules \
        -D ENABLE_NEON=ON \
        -D ENABLE_VFPV3=ON \
        -D BUILD_TESTS=OFF \
        -D OPENCV_ENABLE_NONFREE=ON \
        -D INSTALL_PYTHON_EXAMPLES=OFF \
        -D BUILD_EXAMPLES=OFF ..
   else
       cat /proc/device-tree/model | grep -aq "Raspberry Pi 3"
       if [ $? -eq 0 ]; then
           # This optimizes for Raspberry Pi 3 Models
           echo "-- cmake Compile for Raspberry Pi 3 ENABLE NEON=ON" | tee -a $LOG_FILE
           cmake -D CMAKE_BUILD_TYPE=RELEASE \
            -D CMAKE_INSTALL_PREFIX=/usr/local \
            -D INSTALL_C_EXAMPLES=OFF \
            -D INSTALL_PYTHON_EXAMPLES=OFF \
            -D OPENCV_EXTRA_MODULES_PATH=$INSTALL_DIR/opencv_contrib-$OPENCV_VER/modules \
            -D BUILD_EXAMPLES=OFF \
            -D ENABLE_NEON=ON ..
       else
           echo "-- cmake Compile for Raspberry Pi 2 ENABLE NEON=OFF" | tee -a $LOG_FILE
           cmake -D CMAKE_BUILD_TYPE=RELEASE \
            -D CMAKE_INSTALL_PREFIX=/usr/local \
            -D INSTALL_C_EXAMPLES=OFF \
            -D INSTALL_PYTHON_EXAMPLES=OFF \
            -D OPENCV_EXTRA_MODULES_PATH=$INSTALL_DIR/opencv_contrib-$OPENCV_VER/modules \
            -D BUILD_EXAMPLES=OFF ..
       fi
   fi
   echo "----------------------- End of cmake Messages -------------------------"
   echo ""
   DATE=$(date)
   END=$(date +%s)
   DIFF=$((END - START))
   echo "-- cmake End: $DATE" | tee -a $LOG_FILE
   echo "-- cmake Took: $(($DIFF / 60)) min $(($DIFF % 60)) sec" | tee -a $LOG_FILE
   echo "---------- cmake INSTRUCTIONS ------------"
   echo " NOTE: Most Not Found or Failed Messages are Normal"
   echo " 1- Review cmake messages above for Errors"
   echo " 2- Check that Python 2 and Python 3 sections"
   echo "    Have directory path entries"
   echo " 3- Check if errors reported."
   echo " 4- Last Messages should say"
   echo "-- Configuring done"
   echo "-- Generating done"
   echo "-- Build files have been written to: ..."
   echo "---------------------------------------------"
   read -p "Was cmake Successful (y/n)? " choice
   case "$choice" in
     n|N ) echo "Exit to Terminal to Resolve Problems"
           exit 1
           ;;
     * ) do_cv3_make
         ;;
   esac
}

#------------------------------------------------------------------------------
function do_make_clean ()
{
   if (whiptail --title "make clean INSTRUCTIONS" \
 --yes-button "Back" --no-button "Clean"  --yesno " \

 make clean will clear the current compile status
 and force a full compile from the beginning.
 This may be necessary if there were issues
 with a previous make compile.

 \
 " 0 0 0 ) \
   then
       do_cv3_compile_menu
   else
       echo "Running make clean"
       echo "------------------"
       sudo make clean
       echo "Completed make clean"
       echo "Next compile will start from beginning"
       read -p "Press Return to Continue" choice
       do_cv3_compile_menu
   fi
}

#------------------------------------------------------------------------------
function do_cv3_make ()
{
   if (whiptail --title "make INSTRUCTIONS" \
 --yes-button "Back" --no-button "Run make"  --yesno " \

 A full make compile of openCV $OPENCV_VER will take many hours ...
 A single core RPI with 512 MB RAM can take approx 27 hours
 A quad core RPI with 1 GB of RAM can take 3 - 6 hours
 Note: Starting dphys-swapfile service may take a while ....

 RAM=$TOTAL_MEM MB  Run make $COMPILE_CORES

 Once Compile is started, Percentage complete will be displayed.
 Go for a nice Long Walk, Binge watch Game of Thrones or Something Else .....

 \
 " 0 0 0 ) \
   then
       do_cv3_compile_menu
   else
       do_swap_check
       TOTAL_SWAP=$(free -m | grep Swap | tr -s " " | cut -f 2 -d " ")
       DATE=$(date)
       echo "$DATE STEP 3-2 Start Compile of opencv $OPENCV_VER" | tee -a $LOG_FILE
   fi
   START=$(date +%s)
   echo "-- make $COMPILE_CORES  RAM=$TOTAL_MEM  SWAP=$TOTAL_SWAP" | tee -a $LOG_FILE
   echo "-- make Start: $DATE" | tee -a $LOG_FILE
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
       * ) WARNING_MSG="
 When Errors Resolved, Retry Step 3 COMPILE Menu Pick
 Note make will Continue where it Left Off
 Exit to Terminal to Review Errors
 "
           do_anykey
           ;;
   esac
}

#------------------------------------------------------------------------------
function do_cv3_install ()
{
    if [ -d "$INSTALL_DIR/opencv-$OPENCV_VER/build" ] ; then
       clear
       if (whiptail --title "make install INSTRUCTIONS" \
 --yes-button "Back" --no-button "Run make install"  --yesno " \

 This Step will copy the compiled code to the Required System Folders

 WARNING - Do NOT run this unless you have successfully completed
           STEP 3 COMPILE
 \
 " 0 0 0 ) \
       then
           do_main_menu
       fi
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
       if (whiptail --title "Reboot Required" \
 --yes-button "Back" --no-button "Reboot"  --yesno " \

 You Need to Reboot to Complete Install
 of python OpenCV $open_ver

 \
 " 0 0 0 ) \
       then
           do_main_menu
       else
           sudo reboot
       fi
    else
       whiptail --title "WARNING Dir Not Found $INSTALL_DIR/opencv-$OPENCV_VER/build" --msgbox " \

 WARNING: Directory Not Found $INSTALL_DIR/opencv-$OPENCV_VER/build
 You Need to Run Step 2 or 3 to Install Source Files or Compile.

 \
 " 0 0 0
       do_main_menu
    fi
}

#------------------------------------------------------------------------------
function do_cv3_cleanup ()
{
    clear
    if [ ! -d $INSTALL_DIR ] ; then
        whiptail --title "WARNING" --msgbox " \
 $INSTALL_DIR Directory NOT Found
 You May Need to Run MENU PICK 2 DEP
 If You Have Not Previously Done This.
\
" 0 0 0
        do_main_menu
    fi
    echo "Step 5 - Delete OpenCV $OPENCV_VER Source Folders and zip files (optional)"
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
             read -p "Press Enter Key To Continue" choice
             ;;
       n|N ) do_main_menu
             ;;
         * ) echo "invalid Selection"
             ;;
    esac
    echo ""
    echo "Current System Disk Status"
    df -h
    read -p "Press Enter Key to Continue" choice
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
    echo "Restart Menu to Implement Changes"
    echo ""
    echo "    ./cv3-install-menu.sh"
    echo "Restarting cv3-install-menu.sh"
    read -p "Press Enter to Continue" choice
    ./cv3-install-menu.sh
  fi
}

#------------------------------------------------------------------------------
function do_log ()
{
  if [ -f "$LOG_FILE" ] ; then
     stty igncr  # Suppress cr
     cat $LOG_FILE | more -d
     echo ""
     echo "------------------ End of Log -----------------"
     echo ""
     stty -igncr
     echo "Note: Copy of Log will be Saved as $LOG_FILE.bak"
     echo "------------------------------------------------"
     read -p "Delete Log File (y/n)? " choice
     case "$choice" in
       y|Y ) cp $LOG_FILE $LOG_FILE.bak
             rm $LOG_FILE
             echo "Deleted $LOG_FILE"
             echo "Saved Copy to $LOG_FILE.bak"
             echo "------------------------------------------------"
             read -p "Press Enter To Return to Main Menu" choice
             do_Initialize
             do_main_menu
             ;;
         * ) do_main_menu
             ;;
     esac
  else
     echo ""
     echo "Log File Not Found $LOG_FILE"
     echo ""
     read -p "Press Enter To Return to Main Menu" choice
  fi
}

#------------------------------------------------------------------------------
function do_auto ()
{
    clear
    if (whiptail --title "AUTO Install INSTRUCTIONS" \
    --yes-button "Back" --no-button "Run Auto"  --yesno " \
 This Auto Install will perform a complete opencv
 unattended build including

 1 Raspbian update/upgrade with No Reboot
 2 Install Dependencies and opencv source files
 3 Perform opencv cmake
 4 Perform opencv make compile
 5 Perform python opencv make install (if make successful)

 NOTE: You will Need to Run DELETE menu pick Manually.
       Also, This Unattended Build will Not Log Activity.
       During cmake and make you will see Failed, not found,
       no package Etc messages. This is normal and Not Fatal.
       Fatal errors will stop compile.

 Be Patient ...
 \
 " 0 0) \
    then
      do_main_menu
    else
      check_min_free_space
    fi
    read_config_file
    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get install -y build-essential
    sudo apt-get install -y git
    sudo apt-get install -y cmake
    sudo apt-get install -y pkg-config
    sudo apt-get install -y libjpeg-dev
    sudo apt-get install -y libtiff-dev
    sudo apt-get install -y libjasper-dev
    sudo apt-get install -y libpng-dev
    sudo apt-get install -y libavcodec-dev
    sudo apt-get install -y libavformat-dev
    sudo apt-get install -y libswscale-dev
    sudo apt-get install -y libgtk2.0-dev
    sudo apt-get install -y libgstreamer0.10-0-dbg
    sudo apt-get install -y libgstreamer0.10-0
    sudo apt-get install -y libgstreamer0.10-dev
    sudo apt-get install -y libv4l-0
    sudo apt-get install -y libv4l-dev
    sudo apt-get install -y libxvidcore-dev
    sudo apt-get install -y libgtk-3-dev
    sudo apt-get install -y libx264-dev
    sudo apt-get install -y libqtgui4
    sudo apt-get install -y libcanberra-gtk*
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
    sudo apt-get install -y python-pip
    sudo apt-get install -y python3-pip
    sudo apt-get install -y ntfs-3g
    sudo pip install numpy
    sudo pip3 install numpy
    sudo apt-get -y autoremove
    sudo apt-get clean
    mkdir -p $INSTALL_DIR
    cd $INSTALL_DIR
    wget -O opencv.zip https://github.com/Itseez/opencv/archive/$OPENCV_VER.zip
    unzip -o opencv.zip
    rm opencv.zip
    wget -O opencv_contrib.zip https://github.com/Itseez/opencv_contrib/archive/$OPENCV_VER.zip
    unzip -o opencv_contrib.zip
    rm opencv_contrib.zip
    if [ ! -d "$BUILD_DIR" ] ; then
        mkdir -p $BUILD_DIR
    fi
    cd $BUILD_DIR
    cat /proc/device-tree/model | grep -aq "Raspberry Pi 4"
    if [ $? -eq 0 ]; then
       echo "-- cmake Compile for Raspberry Pi 4 ENABLE NEON=ON" | tee -a $LOG_FILE
       cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D OPENCV_EXTRA_MODULES_PATH=$INSTALL_DIR/opencv_contrib-$OPENCV_VER/modules \
        -D ENABLE_NEON=ON \
        -D ENABLE_VFPV3=ON \
        -D BUILD_TESTS=OFF \
        -D OPENCV_ENABLE_NONFREE=ON \
        -D INSTALL_PYTHON_EXAMPLES=OFF \
        -D BUILD_EXAMPLES=OFF ..
    else
       cat /proc/device-tree/model | grep -aq "Raspberry Pi 3"
       if [ $? -eq 0 ]; then
           # This optimizes for Raspberry Pi 3 Models
           echo "-- cmake Compile for Raspberry Pi 3 ENABLE NEON=ON" | tee -a $LOG_FILE
           cmake -D CMAKE_BUILD_TYPE=RELEASE \
            -D CMAKE_INSTALL_PREFIX=/usr/local \
            -D INSTALL_C_EXAMPLES=OFF \
            -D INSTALL_PYTHON_EXAMPLES=OFF \
            -D OPENCV_EXTRA_MODULES_PATH=$INSTALL_DIR/opencv_contrib-$OPENCV_VER/modules \
            -D BUILD_EXAMPLES=OFF \
            -D ENABLE_NEON=ON ..
       else
           echo "-- cmake Compile for Raspberry Pi 2 ENABLE NEON=OFF" | tee -a $LOG_FILE
           cmake -D CMAKE_BUILD_TYPE=RELEASE \
            -D CMAKE_INSTALL_PREFIX=/usr/local \
            -D INSTALL_C_EXAMPLES=OFF \
            -D INSTALL_PYTHON_EXAMPLES=OFF \
            -D OPENCV_EXTRA_MODULES_PATH=$INSTALL_DIR/opencv_contrib-$OPENCV_VER/modules \
            -D BUILD_EXAMPLES=OFF ..
       fi
    fi
    make $COMPILE_CORES
    if [ -f "/etc/dphys-swapfile.bak" ] ; then
        sudo cp /etc/dphys-swapfile.bak /etc/dphys-swapfile
        sudo rm /etc/dphys-swapfile.bak
        sudo /etc/init.d/dphys-swapfile stop
        sudo /etc/init.d/dphys-swapfile start
        TOTAL_SWAP=$(free -m | grep Swap | tr -s " " | cut -f 2 -d " ")
    fi
    cd $PROG_DIR
    echo "Compile Complete.  Check Above for Errors"
    echo "If Compile Failed Select n to Exit to Terminal"
    echo "To Review Error Messages."
    echo ""
    read -p "Was Compile Successful y/n? " choice
    case "$choice" in
       y|Y ) sudo make install
             sudo ldconfig
             echo "Auto Install is Complete"
             echo "Unless Errors were Reported"
             echo 'import cv2 ; ver = cv2.__version__ ; print("python2 current opencv version is %s" % ver) ' | python2
             echo 'import cv2 ; ver = cv2.__version__ ; print("python3 current opencv version is %s" % ver) ' | python3
             echo "Reboot to update opencv"
             echo "Test python opencv version per commands using"
             echo "the appropriate python interpreter"
             echo ""
             echo "python2 or python3"
             echo "at the python interpreter prompt enter the following commands"
             echo ""
             echo ">>> import cv2"
             echo ">>> cv2.__version__"
             echo ""
             echo "Verify version then Press ctrl-d to exit"
             echo "See Readme.md How to Test Build section for more details"
             exit
             ;;
         * ) echo "Exit to Terminal Due to Errors"
             exit 1
             ;;
    esac
}

#------------------------------------------------------------------------------
function do_about()
{
  whiptail --title "About" --msgbox " \
$0 $PROG_VER written by Claude Pageau
See GitHub https://github.com/pageauc/opencv3-setup

This is a menu driven install script to download and
compile opencv3 from source code. Default is opencv 3.3.0
To change OPENCV_VER variable nano edit the
$PROG_CONF file.
The OPENCV_VER variable will be verified at
https://github.com/Itseez/opencv/archive/
when this menu script is run.

Prerequisites
1 - RPI 2 or 3 Connected to Working Internet Connection
2 - Recent Jessie or Stretch Raspbian Release.
    Earlier versions like wheezy not tested but may work.
    Recommended min 16GB SD card with at least 6 GB Free.
    If Free disk space is Low or You have a Small system SD.
    You can mount a NON FAT format eg ext4 or NTFS
    USB memory stick or hard disk and change the
    INSTALL_DIR variable in $PROG_CONF file
    to point to the new path.

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
  cd $PROG_DIR
  SELECTION=$(whiptail --title "OpenCV Compile Assist from $CUR_OPENCV_VER to $OPENCV_VER" --menu "Arrow/Enter Selects or Tab Key" 0 0 0 --cancel-button Quit --ok-button Select \
  "1 UPDATE" "Run Raspbian Update and Upgrade" \
  "2 DEP" "Install Build Dependencies and Download Source" \
  "3 COMPILE $OPENCV_VER" "Run cmake and make $COMPILE_CORES (be patient)" \
  "4 INSTALL $OPENCV_VER" "Run make install (Copy Files to production)" \
  "5 DELETE" "$INSTALL_DIR Source Folder and Files" \
  "6 SETTINGS" "nano Edit cv3-install-menu.conf File" \
  "7 UPGRADE" "Program Files From GitHub" \
  "8 LOG" "View Log File cv3-log.txt" \
  "9 ABOUT" "Information About This Program" \
  "A AUTO" "Unattended Install (Do You Feel Lucky)" \
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
      3\ *) do_cv3_compile_menu
            do_main_menu ;;
      4\ *) do_cv3_install
            do_main_menu ;;
      5\ *) do_cv3_cleanup
            do_main_menu ;;
      6\ *) nano cv3-install-menu.conf
            read_config_file
            do_check_cv3_ver
            check_working_dir
            do_main_menu ;;
      7\ *) do_upgrade
            echo "Upgrade Complete. Restart $0"
            exit 0 ;;
      8\ *) do_log
            do_main_menu ;;
      9\ *) do_about
            do_main_menu ;;
      A\ *) do_auto ;;
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
read_config_file
do_check_cv3_ver
check_working_dir
do_Initialize
do_main_menu


