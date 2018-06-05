#!/bin/bash
# Script to assist with installing OpenCV3
# If problems are encountered exit to command to try to resolve
# Then retry menu pick again or continue to next step
prog_ver='ver 1.1'

opencv_ver='3.4.1'   # This needs to be a valid opencv3 version number
                     # See https://github.com/opencv/opencv/releases

install_dir='/home/pi/tmp_cv3'    # Working folder for Download/Compile of opencv files
                                  # Note Use symbolic link to external drive mount point
                                  # if sd card too small  Min 5-6 GB Free Space is Needed

function validate_url(){
  if [[ `wget -S --spider $1  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

clear
echo "$0 $prog_ver    written by Claude Pageau"
echo ""
opencv_zip='https://github.com/Itseez/opencv/archive/$opencv_ver.zip'
echo "Checking opencv version $opencv_ver"
if `validate_url $opencv_zip`; then
    echo "Variable opencv_ver=$opencv_ver Is a Valid opencv Version"
    sleep 4
else
    echo "OpenCV $opencv_zip Does Not Exist"
    echo "Make sure variable opencv_ver=$opencv_ver"
    echo "is correct opencv version"
    echo ""
    echo "use nano to edit opencv_ver=$opencv_ver to a valid opencv version"
    echo "also check internet connection."
    echo ""
    read -p "Press Enter to Exit" choice
    exit 1
fi

#------------------------------------------------------------------------------
function do_anykey ()
{
   echo ""
   read -p "Return to Main Menu? (y/n)? " choice
   case "$choice" in
     n|N ) echo "Quit to Terminal"
           exit 1
           ;;
       * ) do_main_menu
           ;;
   esac
}

#------------------------------------------------------------------------------
function do_rpi_update ()
{
   clear
   # Update Raspbian to Lastest Releases
   echo "STEP 1 - Update/Upgrade Raspbian Please Wait ..."
   echo ""
   echo "sudo apt-get update    Please Wait ..."
   echo ""
   sudo apt-get -y update
   echo "Done Raspbian Update ...."
   echo ""
   echo "sudo apt-get upgrade   Please Wait ..."
   echo ""
   sudo apt-get -y upgrade
   sudo apt-get -y autoremove
   echo ""
   echo "Done Raspbian Upgrade ..."
   echo ""
   echo "After a Reboot Run this menu script and Select"
   echo "Menu Pick: 2 DEP Install Build Dependencies and Download Source"
   echo ""
   echo "If there were Significant Changes then Reboot Recommended"
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
   echo "STEP 2 - Install opencv $opencv_ver Build Dependencies"
   echo ""
   echo "This step will install opencv $opencv_ver Build Dependencies"
   echo "Then Download and unzip opencv source files to $install_dir Folder"
   echo ""
   df -h
   echo ""
   echo "A Fresh Build Needs at Least 16GB SD with 5-6 GB Free. Free Space"
   echo "could be less depending on what dependencies are already installed"
   echo "If you are using a smaller system SD or are Low on Free Disk Space."
   echo "You can mount USB media and change variable install_dir in this script."
   echo "Installs Will Take a While so be Patient ..."
   read -p "Continue? (y/n)? " choice
   case "$choice" in
    n|N ) do_main_menu
          ;;
      * ) echo ""
          ;;
   esac
   echo "STEP 2-1 Installing Dependencies  Please Wait ..."
   echo ""
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
   echo "Perform sudo apt-get autoremove"
   echo ""
   sudo apt-get -y autoremove
   if [ ! -d $install_dir ] ; then
       echo "Create dir $install_dir"
       mkdir $install_dir
   fi
   cd $install_dir
   echo ""
   echo "Install pip"
   rm get-pip.py
   wget https://bootstrap.pypa.io/get-pip.py
   sudo python get-pip.py
   echo ""
   echo "Install numpy"
   sudo pip install numpy
   echo ""
   echo "Done Install of Build Essentials and Dependencies ..."
   echo ""
   echo "STEP 2-2 Download and unzip opencv $opencv_ver Source Files"
   echo ""
   wget -O opencv.zip https://github.com/Itseez/opencv/archive/$opencv_ver.zip
   unzip -o opencv.zip
   echo ""
   echo "STEP 3-3 Download and unzip opencv $opencv_ver Contrib Files"
   echo ""
   wget -O opencv_contrib.zip https://github.com/Itseez/opencv_contrib/archive/$opencv_ver.zip
   unzip -o opencv_contrib.zip
   echo ""
   echo "Done Requirements for OpenCV $opencv_ver Source Build."
   echo ""
   df -h
   echo ""
   read -p "Proceed to STEP 3 COMPILE (y/n)?" choice
   case "$choice" in
     y|Y ) do_cv3_compile
           ;;
      * ) do_main_menu
          ;;
   esac
}

#------------------------------------------------------------------------------
function do_cv3_compile ()
{
   if [ ! -d $install_dir ] ; then
       echo "ERROR - $install_dir Director Not Found"
       echo "        Retry Previous STEP 2 DEP Menu Pick"
       do_anykey
   fi
   cd $install_dir
   clear
   echo "STEP 3 Run cmake Prior to Compiling opencv $opencv_ver with make -j1"
   echo ""
   build_dir=$install_dir/opencv-$opencv_ver/build
   if [ ! -d "$build_dir" ] ; then
     echo "Create build directory $build_dir"
     mkdir $build_dir
   fi
   cd $build_dir
   echo "Current Folder is"
   pwd
   echo ""
   echo "            IMPORTANT"
   echo "cmake Will Take a Few Minutes ...."
   echo "At End of cmake You Will See a Message"
   echo "configuring done"
   echo "It Will Take a While to Finish So Be Patient ....."
   echo ""
   read -p "Press Enter to Continue"

   cmake -D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
	-D INSTALL_C_EXAMPLES=OFF \
	-D INSTALL_PYTHON_EXAMPLES=ON \
	-D OPENCV_EXTRA_MODULES_PATH=$install_dir/opencv_contrib-$opencv_ver/modules \
	-D BUILD_EXAMPLES=ON \
	-D ENABLE_NEON=ON ..

    echo "---------------------------------------"
    echo ""
    echo " Review cmake messages above for Errors"
    echo " Check that Python 2 and Python 3 sections"
    echo " Have directory path entries"
    echo " Also Check cvconfig.h points to a build folder"
    echo " Last Messages should say"
    echo "-- Configuring done"
    echo "-- Generating done"
    echo "-- build files have been written to:"
    echo ""
    echo "---------------------------------------"
    echo ""
    read -p "Was cmake Successful (y/n)? " choice
    echo ""
    case "$choice" in
        y|Y ) echo "IMPORTANT"
              echo ""
              echo "Full Compile of openCV $opencv_ver will take approx 3 to 4 hours ...."
              echo "Once Compile is started, Go for a nice Long Walk"
              echo "or Binge watch Game of Thrones or Something Else....."
              echo ""
              read -p "Start Compile Now? (y/n)? " choice
              case "$choice" in
                y|Y ) echo "Start Compile of opencv $opencv_ver"
                      make -j1
                      echo "--------------------------------------------"
                      echo " Check above for Compile Errors"
                      echo "--------------------------------------------"
                      echo "If Errors Found Please Investigate Problem"
                      read -p "Was Compile make Successful? (y/n)? " choice
                      case "$choice" in
                        y|Y ) do_cv3_install
                              ;;
                          * ) exit 1
                              ;;
                      esac
                      ;;
                  * ) do_main_menu
                      ;;
              esac
              ;;
        * ) echo "If cmake Failed. Investigate Problem and Try again"
            echo "You Can Run make clean to Clear Existing cmake"
            echo "and force a full compile from scratch"
            echo "Otherwise Compile Will Continue Where It Left Off"
            echo "Once you Resolve make Error Issues."
            echo ""
            read -p "Run make clean (y/n)? " choice
            case "$choice" in
              n|N ) echo "No make clean Performed"
                    echo "Exit to Terminal to Review cmake Messages."
                    exit 1
                    ;;
                * ) echo "Running sudo make clean"
                    sudo make clean
                    echo "Done make clean"
                    echo "Ready to Try Full cmake Once Problems Resolved."
                    exit 1
                    ;;
            esac
            ;;
    esac
}

#------------------------------------------------------------------------------
function do_cv3_install ()
{
    clear
    echo "STEP 4 - Perform OpenCV $opencv_ver make install"
    echo ""
    echo "This Step will copy the compiled code to the system folders"
    echo "WARNING - Do NOT run this unless you have successfully completed"
    echo "          STEP 3 COMPILE"
    read -p "Run make install Now? (y/n)? " choice
    case "$choice" in
       y|Y ) echo "Running make install"
             echo ""
             ;;
         * ) do_main_menu
             ;;
    esac
    if [ -d "$install_dir/opencv-$opencv_ver/build" ] ; then
      cd $install_dir/opencv-$opencv_ver/build
      sudo make install
      sudo ldconfig
      echo "Reboot to Complete Install of OpenCV $open_ver"
      read -p "Reboot Now? (y/n)? " choice
      case "$choice" in
         y|Y ) echo "Rebooting Now to Enable Changes"
               sudo reboot
               ;;
           * ) do_main_menu
               ;;
      esac
    else
      echo "ERROR- Directory Not Found  /home/pi/opencv-$opencv_ver/build"
      echo "Go Back to Earlier Menu STEP"
      echo ""
      do_anykey
    fi
}

#------------------------------------------------------------------------------
function do_cv3_cleanup ()
{
    clear
    echo "5 - Delete OpenCV $opencv_ver Source Folders and zip files (optional)"
    echo ""
    echo "Current System Disk Status"
    df -h
    echo ""
    echo "Temporary Source Files are in $install_dir Folder"
    echo "You can DELETE this folder and recover disk space"
    du -sh $install_dir
    echo ""
    read -p "DELETE $install_dir Now? (y/n) " choice
    case "$choice" in
       y|Y ) read -p "Are you Sure? (y/n)" choice
             case "$choice" in
                y|Y ) echo ""
                      echo "BEFORE - Disk Space Status"
                      df -h
                      echo "Deleting $install_dir"
                      ;;
                  * ) do_main_menu
                      ;;
             esac
             cd $install_dir
             cd ..
             sudo rm -R $install_dir
             echo ""
             echo "AFTER - Disk Space Status"
             df -h
             echo "Done Removing $install_dir Source Folders and zip files .."
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
               --yesno "Upgrade opencv_setup Files from GitHub.\n" 0 0 0 \
               --yes-button "upgrade" \
               --no-button "Cancel" ); then
    curlcmd=('/usr/bin/curl -L curl -L https://raw.github.com/pageauc/opencv3-setup/master/setup.sh | bash')
    eval $curlcmd
    echo "Done Upgrade/Refresh. Restart Menu"
    exit 1
  fi
}

#------------------------------------------------------------------------------
function do_about()
{
  whiptail --title "About" --msgbox "\
$0 $prog_ver written by Claude Pageau
GitHub https://github.com/pageauc/opencv3-setup

This is a menu driven install script to download and
compile opencv3 from source code. Default is opencv 3.3.0
To change opencv_ver variable use nano to edit this script.
The opencv_ver variable will be verified at
https://github.com/Itseez/opencv/archive/
when this menu script is run.

Prerequisites
1 - RPI connected to Working Internet Connection
2 - Recent Jessie or Stretch Raspbian Release
    Recommended min 16GB SD card with at least 6 GB Free.
    if Free disk space is low or You have a smaller system SD.
    You can mount USB memory or hard disk and change the
    install_dir variable in this script to point to the new path.

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
  SELECTION=$(whiptail --title "opencv $opencv_ver Compile Assist" --menu "Arrow/Enter Selects or Tab Key" 20 70 10 --cancel-button Quit --ok-button Select \
  "1 UPDATE" "Run Raspbian Update and Upgrade" \
  "2 DEP" "Install Build Dependencies and Download Source" \
  "3 COMPILE $opencv_ver" "Run cmake and make (Takes 3-4 hours)" \
  "4 INSTALL $opencv_ver" "Run make install (Copy Files to production)" \
  "5 DELETE" "$install_dir Source Folder and Files" \
  "6 UPGRADE" "$0 $prog_ver Files from GitHub" \
  "7 ABOUT" "Information about this program" \
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
      3\ *) do_cv3_compile
            do_main_menu ;;
      4\ *) do_cv3_install
            do_main_menu ;;
      5\ *) do_cv3_cleanup
            do_main_menu ;;
      6\ *) do_upgrade
            do_main_menu ;;
      7\ *) do_about
            do_main_menu ;;
      q\ *) echo "NOTE"
            echo "After OpenCV Installation is Complete"
            echo "      Reboot to Finalize Install"
            echo "      Then Test OpenCV $opencv_ver"
            echo ""
            echo "If Testing is Successful"
            echo "      You can Remove opencv source folders and zip files"
            echo "Good Luck ..."
            exit 0 ;;
         *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running selection $SELECTION" 20 60 1
  fi
}

do_main_menu


