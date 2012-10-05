#!/bin/bash
#This script was used on newer R720 to partition
#and create 8 TB data partition with lvm so that
#e2croncheck can be used.
parted -s /dev/sdb mklabel gpt
parted -s /dev/sdb mkpart data ext2 1M 100%
parted -s /dev/sdb toggle 1 lvm

#make lvm drive on 1M alignment
pvcreate --dataalignment=1024K -M2 /dev/sdb1
vgcreate vg /dev/sdb1

#8TB leaves enough for a snapshot
lvcreate -L 8T -n data vg

#4k block on 64K RAID = 16 stride
#RAID 5 on 6 disks = width of 5 disks of 16 block = 80
mkfs.ext4 -m 0 -E stride=16,stripe_width=80 /dev/mapper/vg-data
tune2fs -i 0 /dev/mapper/vg-data
