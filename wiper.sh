#!/usr/bin/env bash
#	Keeping it portable.
#	see:	https://www.cyberciti.biz/tips/finding-bash-perl-python-portably-using-env.html


###	FAIR WARNING!
##	THIS SCRIPT IS LIVE AND ARMED!
#	IT WILL DELETE DATA!

#	This script is a version of another server wiping script, but with all the security checks removed.
#	see:	https://github.com/kkarhan/misc-scripts/blob/master/server_wipe.sh


echo	"Detecting Blockdevices..."

lsblk -e7 -d -io NAME -n
#	lists devices, excluding loopback devices partitions and header line.
#	see:	https://unix.stackexchange.com/questions/414305/lsblk-capture-only-the-disks
#	output should only yield /dev/ devicenames like sda & nvme0n1


echo	"Starting wipe..."

mapfile -t my_array < <(lsblk -e7 -d -io NAME -n)

for i in "${my_array[@]}"
do
    shred -f -n 1 -v -z /dev/$i
    echo    "/dev/$i nuked!"
    echo    " "
done
#   wipe each detected disk [physical block device] twice with shred & output progress

echo    " "
echo    "finished!"

exit 
#	Quit Script