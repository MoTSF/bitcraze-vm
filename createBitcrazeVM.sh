#!/bin/bash
ISO_FILE="xubuntu-14.04.4-desktop-i386.iso"
ISO_URL="http://se.archive.ubuntu.com/mirror/cdimage.ubuntu.com/xubuntu/releases/14.04/release/$ISO_FILE"

PACKER_FILE="bitcrazeVM_xubuntu-14.04.4-desktop.json"
PACKER_URL="https://releases.hashicorp.com/packer/0.8.6/packer_0.8.6_linux_386.zip"

PACKER_FILE1=bitcrazeVM_xubuntu-14.04.4-desktop_createVM.json
PACKER_FILE2=bitcrazeVM_xubuntu-14.04.4-desktop_provisionVM.json

GCC_ARM_FILE="gcc-arm-none-eabi-4_9-2014q4-20141203-linux.tar.bz2"
GCC_ARM_URL="https://launchpad.net/gcc-arm-embedded/4.9/4.9-2014-q4-major/+download/$GCC_ARM_FILE"

ECLIPSE_FILE="eclipse-cpp-mars-1-linux-gtk.tar.gz"
ECLIPSE_URL="http://saimei.acc.umu.se/mirror/eclipse.org/technology/epp/downloads/release/mars/1/$ECLIPSE_FILE"

ECLIPSE_GNU_ARM_PLUGIN_FILE="ilg.gnuarmeclipse.repository-2.12.1-201604190915.zip"
ECLIPSE_GNU_ARM_PLUGIN_URL="https://github.com/gnuarmeclipse/plug-ins/releases/download/v2.12.1-201604190915/$ECLIPSE_GNU_ARM_PLUGIN_FILE"

OPENOCD_FILE="gnuarmeclipse-openocd-debian32-0.9.0-201505190955.tgz"
OPENOCD_URL="https://github.com/gnuarmeclipse/openocd/releases/download/gae-0.9.0-20150519/$OPENOCD_FILE"

CONTENT_DIR="contentForVM/"

OVA_FILE=BitcrazeVM.ova

#Download ISO image (only if it's not already downloaded)
if [ -f "$ISO_FILE" ]
then
  echo "$ISO_FILE found. Continuing..."
else
  echo "$ISO_FILE not found. Starting download..."
  wget $ISO_URL
fi

#Install packer (only if it's not already installed)
if type "packer" > /dev/null
then
  echo "Packer already installed. Continuing..."
else
  echo "Packer is not installed. Installing..."
  wget $PACKER_URL
  unzip packer*.zip -d $HOME/packer
  sudo ln -s $HOME/packer/packer /usr/bin/packer
  rm packer*.zip
fi

#Download GCC ARM (63MB) (only if it's not already downloaded)
if [ -f "$CONTENT_DIR$GCC_ARM_FILE" ]
then
  echo "$CONTENT_DIR$GCC_ARM_FILE found. Continuing..."
else
  echo "$CONTENT_DIR$GCC_ARM_FILE not found. Starting download..."
  wget -P $CONTENT_DIR $GCC_ARM_URL
fi


#Download Pycharm (130MB) (only if it's not already downloaded)
if [ -f "$CONTENT_DIR$PYCHARM_FILE" ]
then
  echo "$CONTENT_DIR$PYCHARM_FILE found. Continuing..."
else
  echo "$CONTENT_DIR$PYCHARM_FILE not found. Starting download..."
  wget -P $CONTENT_DIR $PYCHARM_URL
fi

#Download Eclipse (182MB) (only if it's not already downloaded)
if [ -f "$CONTENT_DIR$ECLIPSE_FILE" ]
then
  echo "$CONTENT_DIR$ECLIPSE_FILE found. Continuing..."
else
  echo "$CONTENT_DIR$ECLIPSE_FILE not found. Starting download..."
  wget -P $CONTENT_DIR $ECLIPSE_URL
fi

#Download Eclipse GNU ARM plugin (6MB) (only if it's not already downloaded)
if [ -f "$CONTENT_DIR$ECLIPSE_GNU_ARM_PLUGIN_FILE" ]
then
  echo "$CONTENT_DIR$ECLIPSE_GNU_ARM_PLUGIN_FILE found. Continuing..."
else
  echo "$CONTENT_DIR$ECLIPSE_GNU_ARM_PLUGIN_FILE not found. Starting download..."
  wget -P $CONTENT_DIR $ECLIPSE_GNU_ARM_PLUGIN_URL
fi

#Download OpenOCD 0.9 (3MB) (only if it's not already downloaded)
if [ -f "$CONTENT_DIR$OPENOCD_FILE" ]
then
  echo "$CONTENT_DIR$OPENOCD_FILE found. Continuing..."
else
  echo "$CONTENT_DIR$OPENOCD_FILE not found. Starting download..."
  wget -P $CONTENT_DIR $OPENOCD_URL
fi

# Compressing eclipse project files in one tgz
pushd .
echo "Compressing eclipse-project-files.tar.gz"
cd $CONTENT_DIR/eclipse-project-files
tar -czf ../eclipse-project-files.tar.gz *
popd

#Run packer
echo "Running packer..."
export PACKER_LOG=1

#If OVA already exists, skip VM creation step
if [ -f "output-virtualbox-iso/$OVA_FILE" ]
then
  echo "OVA file found. Skipping VM creation..."
else
  echo "OVA file not found. Starting VM creation..."
  export PACKER_LOG_PATH="packerlog_create.txt"
  packer build $PACKER_FILE1
fi
echo "Starting VM provisioning..."
export PACKER_LOG_PATH="packerlog_provision.txt"
packer build $PACKER_FILE2
