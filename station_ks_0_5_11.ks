# station kickstart
# 0.5
# added tsauser
#
# 0.5.2
# clearpart now removes partitions on all hard drives attached
#
# 0.5.3
# corrected tar line for vmware tools
#
# 0.5.4
# disabled GSSAPIAuthentication so ssh will login faster
#
# 0.5.5
# set tsauser password, previously it was setting an incorrect user
#
# 0.5.6
# removed nx from the rpm list
# nxclient
# nxnode
# nxserver
#
# 0.5.7
# changed vmware tools http name to VMwareTools.tar.gz
# removed plus repo
#
# 0.5.8
# added --initlabel to clearpart command
# clearpart --linux --initlabel
#
# 0.5.9
# Starting with RHEL 6.2, authorized_keys has a different selinux context that prevents pki login
# added restorecon -R /root/.ssh
# and while we are at it, chmod 600 /root/.ssh
#
# 0.5.10
# Added /etc/kickstart-release so it is easier to identify the installed version
# added the kickstart-release contents to /etc/issue so it displays on the console
# remarked out the line because it should no longer be an issue: echo "UseDNS no" >>/etc/ssh/sshd_config
#
# 0.5.11
# station kickstart is now embedded in the server kickstart to make use of variables

############################################################
# Installing the station
############################################################
# The server provides dhcp on the private network and
# pxe/tftp to install the stations.
#
# Power on the workstation, and it will boot from network,
# obtain a dhcp address, pull the kernel from tftp,
# then will pull the kickstart and remaining files
# from server1 automatically.

#version=DEVEL
# 0.5.11
# export repo_file
# export distro_name
# export short_name
install
# 0.5.11
url --url=http://server1/pub/$short_name/
lang en_US.UTF-8
keyboard us
network --onboot yes --device eth0 --bootproto dhcp --noipv6
# password flag
rootpw password
firewall --service=ssh
authconfig --enableshadow --passalgo=sha512
selinux --enforcing
timezone --utc America/Chicago
bootloader --location=mbr --driveorder=sda --append="crashkernel=auto rhgb quiet"
# The following is the partition information you requested
# Note that any partitions you deleted are not expressed
# here so unless you clear all partitions first, this is
# not guaranteed to work
#clearpart --linux --drives=sda
clearpart --linux --initlabel

part /boot --fstype=ext4 --size=500
part pv.008002 --grow --size=1

volgroup VolGroup --pesize=4096 pv.008002
logvol / --fstype=ext4 --name=lv_root --vgname=VolGroup --grow --size=1024 --maxsize=51200
logvol swap --name=lv_swap --vgname=VolGroup --grow --size=1008 --maxsize=2016
# 0.5.11
repo --name="$distro_name"  --baseurl=http://server1/pub/$short_name/ --cost=100
#repo --name="Plus"  --baseurl=http://server1/pub/plusrepo/ --cost=100

%packages
@base
@client-mgmt-tools
@core
@debugging
@basic-desktop
@desktop-debugging
@desktop-platform
@directory-client
@fonts
@general-desktop
@graphical-admin-tools
@input-methods
@internet-browser
@java-platform
@legacy-x
@network-file-system-client
@perl-runtime
@print-client
@remote-desktop-clients
@server-platform
@server-policy
@x11
mtools
pax
python-dmidecode
oddjob
sgpio
genisoimage
wodim
abrt-gui
certmonger
pam_krb5
krb5-workstation
libXmu
perl-DBD-SQLite
%end

%post
(
if dmidecode|grep -q "Product Name: VMware Virtual Platform"
then
	cd /tmp
	wget http://server1/pub/materials/VMwareTools.tar.gz
	tar xzvf VMwareTools.tar.gz
	cd vmware-tools-distrib
	./vmware-install.pl default
fi

############################################################
# /etc/kickstart-release
############################################################
echo "$distro_name Lab in a Box - server1 kickstart 0.5.11" >/etc/kickstart-release
cat /etc/kickstart-release >>/etc/issue

chkconfig NetworkManager off
chkconfig firstboot off

mkdir -m 700 -p /root/.ssh
wget -q -O - http://server1/pub/materials/id_rsa.pub >>/root/.ssh/authorized_keys
# 0.5.9
restorecon -R /root/.ssh
chmod 600 /root/.ssh/authorized_keys
wget -q -O /etc/yum.repos.d/server1.repo http://server1/pub/materials/server1.repo

#echo "UseDNS no" >>/etc/ssh/sshd_config

echo "default web url" > /root/default.html
echo "welcome to vhost" > /root/vhost.html
sed -i -e s/id:.:initdefault:/id:3:initdefault:/ /etc/inittab
sed -e 's/#GSSAPIAuthentication no/GSSAPIAuthentication no/' -e 's/GSSAPIAuthentication yes/#GSSAPIAuthentication yes/' -i /etc/ssh/sshd_config

# password flag
useradd -g users -g 100 tsauser
echo "password" | passwd --stdin tsauser
wget -q -O /etc/openldap/cacerts/cacert.pem http://server1/pub/materials/cacert.pem
ln -s /etc/openldap/cacerts/cacert.pem /etc/openldap/cacerts/`openssl x509 -hash -noout -in /etc/openldap/cacerts/cacert.pem`.0
) 2>&1 | tee /root/install.log | tee /dev/console

