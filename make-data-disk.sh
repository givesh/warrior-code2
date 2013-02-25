#!/bin/bash
# This script looks for an unmounted disk where
# it can create a partition. It formats the partition
# and mounts it on /data.
#
# This is faster than rm -rf /data/ and allows the user
# to connect a new, unformatted disk to the warrior VM.

# unmount the partition
if mountpoint -q /data
then
  umount /data
fi

# find an unmounted disk
for device in `blkid -o device`
do
  if ! grep -qs "$device" /proc/mounts /proc/swaps
  then
    data_disk="$device"
    break
  fi
done

# reset partition table
echo "Creating a data partition on ${data_disk}..."
( echo d ; echo d ; echo d ; echo d ; echo d ; echo n ; echo p ; echo 1 ; echo ; echo ; echo w ) | fdisk $data_disk &> /dev/null

# format drive, mount and prepare folders
echo "Preparing the data partition..."
mke2fs -t ext4 -O ^has_journal -E lazy_itable_init=1 ${data_disk}1 &> /dev/null
mount -t ext4 -o noatime,nodiratime,data=writeback,barrier=0,nobh ${data_disk}1 /data
mkdir /data/data
chmod 777 /data /data/data

