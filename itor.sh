#!/bin/bash
# author: Xiao Shang
# note: install tor
# sudo chmod +x ./i*.sh
# sudo sh i*.sh

LOG_FILE=tor_install_log.txt
exec 3>&1 1>>${LOG_FILE} 2>&1 # Writing outputs to log file(log.txt)

TOR_HOME=${HOME}/tor
TOR_FILE=tor-0.4.6.10
TOR_VERSION=0.4.6.10

BRIDGE_FILE=bridge_lines.txt

echo "Get bridge lines (${BRIDGE_FILE}) from url:
https://bridges.torproject.org/
Add \"Bridge\" in front of every lines, eg.:
Bridge obfs4 ...
"

wget https://dist.torproject.org/${TOR_FILE}.tar.gz
mkdir ${TOR_HOME}
tar -zxvf tor-0.4.6.10.tar.gz -C ${TOR_HOME}

# install some required packages
sudo apt-get install build-essential libssl-dev zlib1g zlib1g-dev obfs4proxy

cd ${TOR_HOME}/${TOR_FILE}
./configure
make
cd -

echo "#! /bin/bash

TOR_HOME=${TOR_HOME}
TOR_FILE=${TOR_FILE}

TOR_APP=\${TOR_HOME}/\${TOR_FILE}/src/app/tor


\${TOR_APP} -f \${TOR_HOME}/torrc
" > ${TOR_HOME}/tor
sudo chmod +x tor

echo "DataDirectory ${TOR_HOME}/.tor                                                                                                                                                                                  
                                                                                                                                                                                                                
                                                                                                                                                                                                                
HiddenServiceDir ${TOR_HOME}/.tor/hidden_service/                                                                                                                                                               
HiddenServicePort 22 0.0.0.0:22                                                                                                                                                                                 
                                                                                                                                                                                                                
GeoIPFile ${TOR_HOME}/${TOR_FILE}/src/config/geoip                                                                                                                                                           
GeoIPv6File ${TOR_HOME}/${TOR_FILE}/src/config/geoip6                                                                                                                                                        
                                                                                                                                                                                                                
UseBridges 1                                                                                                                                                                                                    
ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy

" > ${TOR_HOME}/torrc

#cat ${BRIDGE_FILE} >> ${TOR_HOME}/torrc
cat ${BRIDGE_FILE} | while read line
do
    echo "Bridge ${line}" >> ${TOR_HOME}/torrc
done

echo "Connect Tor network (type ${TOR_HOME}/tor)"

${TOR_HOME}/tor

echo "Tor hostname (${TOR_HOME}/.tor/hidden_service/hostname):"

cat ${TOR_HOME}/.tor/hidden_service/hostname

echo "Tor network connection test"

echo "Check current IP address:"

wget -qO - https://api.ipify.org; echo

echo "Run with torsocks, i.e. tor network:"

torsocks wget -qO - https://api.ipify.org; echo

echo "Finished." 1>&3

echo "More details in ${LOG_FILE}." 1>&3
