#!/bin/bash
# author: ishx
# ref url: https://openvpn.net/download-open-vpn/
# sudo sh i*.sh

# install openvpn service
apt update && apt -y install ca-certificates wget net-tools gnupg
wget -qO - https://as-repository.openvpn.net/as-repo-public.gpg | apt-key add -
echo "deb http://as-repository.openvpn.net/as/debian focal main">/etc/apt/sources.list.d/openvpn-as-repo.list
apt update && apt -y install openvpn-as
cp /usr/local/openvpn_as/init.log openvpn_init.log

# install openvpn client
# ref url: https://community.openvpn.net/openvpn/wiki/OpenVPN3Linux?_ga=2.22393339.1192676484.1647053767-2030199088.1637140059
apt install apt-transport-https
curl -fsSL https://swupdate.openvpn.net/repos/openvpn-repo-pkg-key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/openvpn-repo-pkg-keyring.gpg
curl -fsSL https://swupdate.openvpn.net/community/openvpn3/repos/openvpn3-$DISTRO.list >/etc/apt/sources.list.d/openvpn3.list
apt install openvpn3
