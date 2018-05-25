#!/bin/bash

DEVICE=/dev/$(lsblk -n | grep -v 'xvda' | awk '$NF != "/" {print $1}')
FS_TYPE=$(file -s $DEVICE | awk '{print $2}')
MOUNT_POINT=/data

# If no FS, then this output contains "data"
if [ "$FS_TYPE" = "data" ]
then
    echo "Creating file system on $DEVICE"
    mkfs -t ext4 $DEVICE
fi

mkdir $MOUNT_POINT
mount $DEVICE $MOUNT_POINT

echo '/dev/xvdh /data ext4 defaults,nofail 0 2' >> /etc/fstab

touch /var/lib/cloud/instance/locale-check.skip
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install python-minimal

echo 'Finished cloud-init using custom user data'
