#!/bin/bash
# author: Xiao Shang
# note: Install Swift on Ubuntu 20.04
# ref url: https://swift.org/download/#using-downloads
# sudo chmod +x ./swift.sh
# ./iswift.sh
# sudo sh swift.sh
# run as root

LOG_FILE=swift_install_log.txt

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

check_root() {
  if [ "$(id -u)" != 0 ]; then
    exiterr "Script must be run as root. Try 'sudo sh $0'"
  fi
}

check_os() {
  os_type=centos
  rh_file="/etc/redhat-release"
  if grep -qs "Red Hat" "$rh_file"; then
    os_type=rhel
  fi
  if grep -qs "release 7" "$rh_file"; then
    os_ver=7
  elif grep -qs "release 8" "$rh_file"; then
    os_ver=8
    grep -qi stream "$rh_file" && os_ver=8s
    grep -qi rocky "$rh_file" && os_type=rocky
    grep -qi alma "$rh_file" && os_type=alma
  elif grep -qs "Amazon Linux release 2" /etc/system-release; then
    os_type=amzn
    os_ver=2
  else
    os_type=$(lsb_release -si 2>/dev/null)
    [ -z "$os_type" ] && [ -f /etc/os-release ] && os_type=$(. /etc/os-release && printf '%s' "$ID")
    case $os_type in
      [Uu]buntu)
        os_type=ubuntu
        ;;
      [Dd]ebian)
        os_type=debian
        ;;
      [Rr]aspbian)
        os_type=raspbian
        ;;
      [Aa]lpine)
        os_type=alpine
        ;;
      *)
cat 1>&2 <<'EOF'
Error: This script only supports one of the following OS:
       Ubuntu, Debian, CentOS/RHEL 7/8, Rocky Linux, AlmaLinux,
       Amazon Linux 2 or Alpine Linux
EOF
        exit 1
        ;;
    esac
    if [ "$os_type" = "alpine" ]; then
      os_ver=$(. /etc/os-release && printf '%s' "$VERSION_ID" | cut -d '.' -f 1,2)
      if [ "$os_ver" != "3.14" ]; then
        exiterr "This script only supports Alpine Linux 3.14."
      fi
    else
      os_ver=$(sed 's/\..*//' /etc/debian_version | tr -dc 'A-Za-z0-9')
      if [ "$os_ver" = "8" ] || [ "$os_ver" = "jessiesid" ]; then
        exiterr "Debian 8 or Ubuntu < 16.04 is not supported."
      fi
    fi
  fi
}


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

wget ${TOOLCHAIN_URL}

wget ${DIGITAL_SIGNATURE_URL}

echo "Step 2. Import the PGP keys into your keyring." 1>&3
wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import -

echo "Step 3. Verify the PGP signature." 1>&3
gpg --keyserver hkp://pool.sks-keyservers.net --refresh-keys Swift
gpg --verify ${DIGITAL_SIGNATURE_NAME}

echo "Step 4. Extract the archive to /opt/${SWIFT_NAME}." 1>&3
tar xzf ${TOOLCHAIN_TAR}
mv ${TOOLCHAIN_NAME} /opt/${SWIFT_NAME}

echo "Step 5. Add the Swift toolchain to your path." 1>&3
echo "export PATH=\"/opt/${SWIFT_NAME}/usr/bin:\${PATH}\"" 

echo "# Swift
export PATH=\"/opt/${SWIFT_NAME}/usr/bin:\${PATH}\"" >> ~/.bashrc

source ~/.bashrc

# enable current swift environment
export PATH="/opt/${SWIFT_NAME}/usr/bin"

Swift --version 1>&3

echo "Finished." 1>&3

echo "More details in ${LOG_FILE}." 1>&3