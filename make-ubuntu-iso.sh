#!/bin/bash

# make-ubuntu-iso v1.1
# author: walter lapchynski/wxl
# contact: carsrcoffins23@yahoo.com
# license: public domain
# born: 21 sept 2012

# what it does: burns a verified *buntu cd

# WARNING:
# please note this assumes you have one cd drive
# if you have more than one, replace /dev/cdrom with the right device
# also can change to e.g /dev/cdrom for usb
# consult the df command for more info

syntax_error () {
	echo -e "Usage: $0 [DERIVATIVE] [ARCHITECTURE] [desktop|alternate] [VERSION]\n\
		Example: $0 lubuntu powerpc desktop quantal\n\n\
		or for listing of possible options: $0 [-l|--long]\n\n\
		note not all combinations of the options are possible"
	exit
}

### FIXME: add other options-- see comments
# make sure we have 1st argument (derivative)
case $1 in
#edubuntu|kubuntu|mythbuntu|ubuntu|core|server|ec2|studio|xubuntu)
lubuntu)
	derivative="$1"
	;;
--long|-l)
	echo "DERIVATIVES:"
	echo -e "lubuntu" # \n edubuntu\n kubuntu\n mythbuntu\n ubuntu\n core\n server\n ec2\n studio\n xubuntu"
	echo "ARCHITECTURES:"
	echo -e "powerpc" # \n i386\n amd64\n amd64mac\n armhf\n armhfomap\n armhfomap4"
	echo "more to come"
	exit
	;;
*)
	syntax_error
	;;
esac

### FIXME: add other options-- see comments
# make sure we have 2nd argument (architecture)
case $2 in
#i386|amd64|amd64mac|armhf|armhfomap|armhfomap4)
powerpc)
	architecture="$2"
	;;
*)
	syntax_error
	;;
esac

# make sure we have 3rd argument (desktop/alternate)
case $3 in
desktop)
	iso_type="$3"
	daily_type="daily-live"
	;;
alternate)
	iso_type="$3"
	daily_type="daily"
	;;
*)
	syntax_error
	;;
esac

if [ -z "$4" ];
then
	syntax_error
else
	version="$4"
fi

# make urls
iso_filename="${version}-${iso_type}-${architecture}.iso"
base_url="http://cdimage.ubuntu.com/${derivative}/${daily_type}/current/"
md5sums_url="${base_url}MD5SUMS"
zsync_url="${base_url}${iso_filename}.zsync"

### FIXME
# check for url errors

# grab the iso and get the md5sum
zsync "$zsync_url"
iso_md5sum="$(md5sum $iso_filename | awk '{print $1}')"

# get the MD5SUMS, extract appropriate md5sum and compare with iso md5sum
wget "$md5sums_url" -O MD5SUMS
published_md5sum="$(grep ${architecture} MD5SUMS | awk '{print $1}')"
if [ "$iso_md5sum" == "$published_md5sum" ];
then
	echo "iso passes"
else
	echo "iso fails"
	exit
fi 

# copy the iso to the cd and get its md5sum
sudo dd if="$iso_filename" of=/dev/cdrom
iso_size="$(ls -l | grep -m 1 ${iso_filename} | awk '{print $5}')"
dd_count="$((iso_size / 2048))"
dd_cd="$(sudo dd if=/dev/cdrom bs=2048 count="${dd_count}" | md5sum | awk '{print $1}')"

# compare iso md5sum and cd md5sum
if [ "$iso_md5sum"  == "$dd_cd"	];
then
	echo "disc passes"
else
	echo "disc fails"
	exit
fi
