#version=RHEL8
lang en_US.UTF-8
keyboard --xlayouts='us'
timezone America/New_York
text
skipx
reboot

# Configure network to use DHCP and activate on boot
network --bootproto=dhcp --device=link --activate --onboot=on --hostname=microshift --noipv6

# Partition disk with a 1GB boot XFS partition and a 40GB LVM volume containing system root
# The remainder of the volume will be used by the CSI driver for storing data
zerombr
clearpart --all --initlabel
part /boot/efi --fstype=efi --size=200
part /boot --fstype=xfs --asprimary --size=800
part pv.01 --grow
volgroup rhel pv.01
logvol / --vgname=rhel --fstype=xfs --size=40960 --name=root

# Configure users
rootpw --lock
user --plaintext --name=microshift --password=microshift

selinux --enforcing
firewall --enabled --ssh

# Minimal package setup
cdrom
firstboot --disable
eula --agreed

%packages
@^minimal-environment
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

# Post install configuration
%post --log=/var/log/anaconda/post-install.log --erroronfail

# Allow the default user to run sudo commands with password
echo -e 'microshift\tALL=(ALL)\tPASSWD: ALL' > /etc/sudoers.d/microshift

# Import Red Hat public keys to allow RPM GPG check (not necessary if a system is registered)
if ! subscription-manager status >& /dev/null ; then
   rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-*
fi

# Configure systemd journal service to persist logs between boots and limit their size to 1G
sudo mkdir -p /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/microshift.conf <<EOF
[Journal]
Storage=persistent
SystemMaxUse=1G
RuntimeMaxUse=1G
EOF

%end