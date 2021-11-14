#!/bin/bash
# author: Xiao Shang
# note: Install Swift on Ubuntu 20.04
# ref url: https://swift.org/download/#using-downloads
# chmod +x ./install.sh
# ./install.sh
# run as root

LOG_FILE=swift_install_log.txt
exec 3>&1 1>>${LOG_FILE} 2>&1 # Writing outputs to log file(log.txt)

echo "Install Swift on Ubuntu 20.04." 1>&3
echo "ref: Install Swift on Ubuntu 20.04" 1>&3

#
echo "Preparing step I: update and upgrade." 1>&3
apt update && apt upgrade -y
#
echo "Preparing step II: Install required dependencies." 1>&3
apt-get install -y \
          binutils \
          git \
          gnupg2 \
          libc6-dev \
          libcurl4 \
          libedit2 \
          libgcc-9-dev \
          libpython2.7 \
          libsqlite3-0 \
          libstdc++-9-dev \
          libxml2 \
          libz3-dev \
          pkg-config \
          tzdata \
          uuid-dev \
          zlib1g-dev

echo "5 steps." 1>&3

echo "Step 1. Download the latest binary release above." 1>&3

URL=https://swift.org
VER=5.5.1
PLATFORM=ubuntu2004
PLATFORMSRC=ubuntu20.04
SWIFT_NAME=swift-${VER}
VERSION=${SWIFT_NAME}-RELEASE
TOOLCHAIN_NAME=${VERSION}-${PLATFORMSRC}
TOOLCHAIN_TAR=${TOOLCHAIN_NAME}.tar.gz
TOOLCHAIN_URL=${URL}/builds/${SWIFT_NAME}-release/${PLATFORM}/${VERSION}/${TOOLCHAIN_TAR}
DIGITAL_SIGNATURE_NAME=${TOOLCHAIN_TAR}.sig
DIGITAL_SIGNATURE_URL=${TOOLCHAIN_URL}.sig

wget ${TOOLCHAIN_URL}

wget ${DIGITAL_SIGNATURE_URL}

echo "Step 2. Import the PGP keys into your keyring:." 1>&3
wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import -

echo "Step 3. Verify the PGP signature." 1>&3
gpg --keyserver hkp://pool.sks-keyservers.net --refresh-keys Swift
gpg --verify DIGITAL_SIGNATURE_NAME

echo "Step 4. Extract the archive to /opt/${SWIFT_NAME}." 1>&3
tar xzf ${TOOLCHAIN_TAR}
mv ${TOOLCHAIN_NAME} /opt/${SWIFT_NAME}

echo "Step 5. Add the Swift toolchain to your path" 1>&3
echo "export PATH=/opt/${SWIFT_NAME}/usr/bin:"\${PATH}"" 

echo "# Swift
export PATH=/opt/${SWIFT_NAME}/usr/bin:"\${PATH}"" >> ~/.bashrc

echo "run:
source ~/.bashrc
to activate the swift environment immediately."  1>&3

echo "Finished." 1>&3

echo "More details in ${LOG_FILE}." 1>&3
