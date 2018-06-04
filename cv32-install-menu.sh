#!/bin/bash
# Script to assist with installing OpenCV3
# If problems are encountered exit to command to try to resolve
# Then retry menu pick again or continue to next step
ver="ver 0.52"

install_dir='/home/pi/tmp_cv3'    # Working folder for Download/Compile of opencv files
                                  # Note Use symbolic link to external drive mnt if sd card too small
if [ ! -d $install_dir ] ; then
    echo "Create dir $install_dir"
    mkdir $install_dir
fi

#------------------------------------------------------------------------------
function do_anykey ()
{
   echo "Press Enter to Return to Main Menu"
   echo "or e)xit to Exit to Terminal session"
   read -p "Press (Enter/e)? " choice
   case "$choice" in
      e|E ) echo "User Exited Menu to Terminal."
            echo "Bye"
            exit 1
            ;;
        * ) echo "Return to Main Menu"
            ;;
   esac
}

#------------------------------------------------------------------------------
function do_rpi_update ()
{
   cd $install_dir
   # Update Raspbian to Lastest Releases
   echo "Updating Raspbian Please Wait ..."
   echo "---------------------------------"
   sudo apt-get -y update
   echo "Done Raspbian Update ...."
   echo "Upgrading Raspbian Please Wait ..."
   echo "---------------------------------"
   sudo apt-get -y upgrade
   sudo apt-get -y autoremove
   echo "Done Raspbian Upgrade ..."
   echo ""
   echo "After a Reboot rerun this script and Select"
   echo "Menu Pick: OpenCV 3.2.0 Install Build Dependencies and Download Source"
   echo "-----------------------------------------------------------------------"
   echo "If there were Significant Changes then Reboot Recommended"
   echo ""
   read -p "Reboot Now? (y/n)? " choice
   case "$choice" in
     y|Y ) echo "yes"
           echo "Rebooting Now"
           sudo reboot
           ;;
     n|N ) echo "Back to Main Menu"
           ;;
       * ) echo "invalid Selection"
           ;;
  esac
}

#------------------------------------------------------------------------------
function do_cv3_dep ()
{
   cd $install_dir
   # Install opencv3 build dependencies
   echo "Installing opencv 3.2.0 build and run dependencies"
   echo "--------------------------------------------------"
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
   sudo apt-get install -y libv4l-0 libv4l-dev
   sudo apt-get install -y libavcodec-dev
   sudo apt-get install -y libavformat-dev
   sudo apt-get install -y libswscale-dev
   sudo apt-get install -y libv4l-dev
   sudo apt-get install -y libxvidcore-dev
   sudo apt-get install -y libx264-dev
   sudo apt-get install -y libatlas-base-dev
   sudo apt-get install -y gfortran
   sudo apt-get install -y python-numpy
   sudo apt-get install -y python-scipy
   sudo apt-get install -y python-matplotlib
   sudo apt-get install -y default-jdk ant
   sudo apt-get install -y libgtkglext1-dev
   sudo apt-get install -y v4l-utils
   sudo apt-get install -y gphoto2
   sudo apt-get -y autoremove
   wget https://bootstrap.pypa.io/get-pip.py
   sudo python get-pip.py
   sudo apt-get install -y python2.7-dev
   sudo pip install numpy
   echo "Done Install of Build Essentials and Dependencies ..."
   echo "-----------------------------------------------------"
   echo "Download and unzip opencv 3.2.0 Source Files"
   echo "-----------------------------------------------------"
   wget -O opencv.zip https://github.com/Itseez/opencv/archive/3.2.0.zip
   unzip opencv.zip
   wget -O opencv_contrib.zip https://github.com/Itseez/opencv_contrib/archive/3.2.0.zip
   unzip opencv_contrib.zip
   echo "Done Install of Build Essentials, Dependencies and OpenCV 3.2.0 Source."
   echo "Next Step Select Menu Pick:  OpenCV3 3.2.0 Run cmake and make"
   do_anykey
}

#------------------------------------------------------------------------------
function do_cv3_compile ()
{
   cd $install_dir
   echo "Running cmake prior to compiling opencv 3.2.0"
   echo "---------------------------------------------"
   build_dir=$install_dir/opencv-3.2.0/build
   if [ ! -d "$build_dir" ] ; then
     echo "Create build directory $build_dir"
     mkdir $build_dir
   fi
   cd $build_dir
   echo "cmake Will Take a Few minutes ...."
   echo "Note: At configuring done step you may have to wait a while"
   echo "so be patient ...."
   echo "---------------------------------------------"
   read -p "Press Enter to Continue"

   cmake -D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
	-D INSTALL_C_EXAMPLES=OFF \
	-D INSTALL_PYTHON_EXAMPLES=ON \
	-D OPENCV_EXTRA_MODULES_PATH=$install_dir/opencv_contrib-3.2.0/modules \
	-D BUILD_EXAMPLES=ON \
	-D ENABLE_NEON=ON ..

    echo "---------------------------------------"
    echo " Review cmake messages above for Errors"
    echo "---------------------------------------"
    echo "y) Starts compile of opencv 3.2.0 from source"
    echo "n) Does a make clean ready for next cmake attempt, once problem resolved."
    read -p "Was cmake Successful (y/n)? " choice
    echo "---------------------------------------"
    case "$choice" in
        y|Y ) echo "IMPORTANT"
              echo "---------"
              echo "Compile of openCV ver 3.2.0 will take approx 3 to 4 hours ...."
              echo "Once Compile is started go for a nice long walk"
              echo "or Binge watch Game of Thrones or Something Else....."
              echo ""
              make -j1
              echo "--------------------------------------------"
              echo " Check above for Compile Errors"
              echo "--------------------------------------------"
              echo "If Errors Please Investigate Problem"
              echo "If OK Select Menu Pick: Run make install"
              do_anykey
              ;;
        n|N ) echo "If cmake Failed. Investigate Problem and Try again"
              sudo make clean
              echo "Done make clean"
              echo "Ready to Try full compile once problem resolved."
              do_anykey
              ;;
          * ) echo "invalid Selection"
              ;;
    esac
}

#------------------------------------------------------------------------------
function do_cv3_install ()
{
    echo "Perform OpenCV 3.2.0 make install"
    echo "---------------------------------"
    if [ -d "$install_dir/opencv-3.2.0/build" ] ; then
      cd $install_dir/opencv-3.2.0/build
      sudo make install
      sudo ldconfig
      echo "Reboot to Complete Install of OpenCV 3.2.0"
      echo ""
      read -p "Reboot Now? (y/n)? " choice
      case "$choice" in
         y|Y ) echo "yes"
               echo "Rebooting Now"
               sudo reboot
               ;;
         n|N ) echo "Back To Main Menu"
               ;;
           * ) echo "invalid Selection"
               ;;
      esac
    else
      echo "Error- Directory Not Found  /home/pi/opencv-3.2.0/build"
      echo "Go Back to Earlier Menu Step"
      echo "----------------------------"
      do_anykey
      return 1
    fi
}

#------------------------------------------------------------------------------
function do_cv3_cleanup ()
{
    echo "------------------------------------------"
    echo "Remove OpenCV 3.2.0 Source Folders and zip files (optional)"
    echo ""
    read -p "Remove Now? (y/n)? " choice
    case "$choice" in
       y|Y ) echo "yes"
             cd $install_dir
             cd ..
             sudo rm -R $install_dir
             echo "Done Removing $install_dir Source Folders and zip files .."
             do_anykey
             ;;
       n|N ) echo "Back To Main Menu"
             ;;
         * ) echo "invalid Selection"
             ;;
   esac

}

#------------------------------------------------------------------------------
function do_about()
{
  whiptail --title "About" --msgbox " \
                OpenCV 3.2.0 Install Menu Assist
                  written by Claude Pageau

This Menu will help install opencv 3.2.0 if required
You will be asked to reboot during installation.

Run Menu Pick Selections in order and verify successful completion
before progressing to next step. This install is configured for
a single core Raspberry Pi make -j1.  Modify this script at
approx line 150 to use more than one core.
Change parameter to -j2 after the make command.

For Additional Details See https://github.com/pageauc/opencv3-setup

Script Steps Based on GitHub Repo
https://github.com/Tes3awy/OpenCV-3.2.0-Compiling-on-Raspberry-Pi

             Good Luck

\
" 35 70 35
}

#------------------------------------------------------------------------------
function do_main_menu ()
{
  SELECTION=$(whiptail --title "opencv 3.2.0 Install Assist $ver" --menu "Arrow/Enter Selects or Tab Key" 20 70 10 --cancel-button Quit --ok-button Select \
  "a " "Raspbian Update and Upgrade" \
  "b " "Install Build Dependencies and Download Source" \
  "c " "Run cmake and make (compile Takes 3-4 hours)" \
  "d " "Run make install" \
  "e " "Remove Source Folders and zip Files (optional)" \
  "f " "About" \
  "q " "Quit Menu Back to Console"  3>&1 1>&2 2>&3)

  RET=$?
  if [ $RET -eq 1 ]; then
    exit 0
  elif [ $RET -eq 0 ]; then
    case "$SELECTION" in
      a\ *) do_rpi_update
            do_main_menu ;;
      b\ *) do_cv3_dep
            do_main_menu ;;
      c\ *) do_cv3_compile
            do_main_menu ;;
      d\ *) do_cv3_install
            do_main_menu ;;
      e\ *) do_cv3_cleanup
            do_main_menu ;;
      f\ *) do_about
            do_main_menu ;;
      q\ *) echo "NOTE"
            echo "After OpenCV 3.2.0 Installation is Complete"
            echo "      Reboot to Finalize Install"
            echo "      Then Test OpenCV 3.2.0"
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


