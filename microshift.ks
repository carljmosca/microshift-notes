#version=RHEL8
# Use graphical install
text


%packages
@^minimal-environment
@headless-management
kexec-tools
bash-completion
cockpit
conmon
conntrack-tools
containernetworking-plugins
containers-common
container-selinux
criu
git
jq
make
NetworkManager-ovs
python36
selinux-policy-devel

%end

# Keyboard layouts
keyboard --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network --bootproto=dhcp --device=ens18 --activate --onboot=on --hostname=server01.lab.moscaville.com --noipv6

# Run the Setup Agent on first boot
firstboot --enable

zerombr
clearpart --all --initlabel
part /boot/efi --fstype=efi --size=200
part /boot --fstype=xfs --asprimary --size=800
part pv.01 --grow
volgroup rhel pv.01
logvol / --vgname=rhel --fstype=xfs --size=40960 --name=root

# System timezone
timezone America/New_York --isUtc

#Root password
rootpw --lock
user --plaintext --name=microshift --password=microshift

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
