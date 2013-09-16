#!/bin/bash
sudo mkdir -p /mnt/floppy
sudo mount -o loop ~charles/Dropbox/Lab_in_a_Box/linux_lab_floppy.img /mnt/floppy && sleep 1 && (

# The most recently modified kickstart for server1 and station
export serverks="`ls -1t ~charles/Dropbox/Lab_in_a_Box/Linux_Lab_in_a_Box_kickstart*.cfg|head -n1`"
export stationks="`ls -1t ~charles/Dropbox/Lab_in_a_Box/station_ks*.ks|head -n1`"
echo "Latest server1 kickstart: $serverks"
echo "Latest station kickstart: $stationks"

# clean floppy
echo "Cleaning cfg and ks files from the floppy image."
sudo rm -f /mnt/floppy/*.cfg /mnt/floppy/*.ks

sudo cp "$stationks" /mnt/floppy/
sudo cp "$stationks" /mnt/floppy/station_ks.cfg

sudo cp "$serverks" /mnt/floppy/
sudo cp "$serverks" /mnt/floppy/ks.cfg

echo "Floppy image contents:"
ls -l /mnt/floppy
)
sleep 1
sudo umount /mnt/floppy 

