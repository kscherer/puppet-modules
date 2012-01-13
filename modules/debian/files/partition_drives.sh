#!/bin/bash

set -x

for drive in {b..f}; do
  device=/dev/sd$drive

  #use gpt for large drives
  parted -s $device mklabel gpt

  #Use alignment of 1MB to properly align for raid stripe size of 64K or 128K
  parted -s $device mkpart vm ext2 1M 100%
done
