#!/bin/bash

# uploadit v1.2
# author: walter lapchynski/wxl
# contact: carsrcoffins23@yahoo.com
# license: public domain
# born: 9 feb 2013

# what it does: uploads Community Audio to Internet Archive
# make sure you have cURL!

# first let's get our cookie
curl --location --dump-header cookies http://archive.org/account/login.php >/dev/null 2>&1

# let's get our login info
read -e -p "username: " username
read -es -p "password: " password

# add a newline because read -s doesn't end in one
echo -e "\n"

# now let's get logged in, making sure to get a new cookie
curl --location --dump-header cookies2 --cookie cookies --data-urlencode "username=${username}" --data-urlencode "password=${password}" --data-urlencode "remember=CHECKED" --data-urlencode "action=login" --data-urlencode "submit=Log in" http://archive.org/account/login.php >/dev/null 2>&1

# we need an identifier
read -e -p "identifier: " identifier

# validate identifier: 5-50 characters, alphanumeric 1st, rest alphanumeric plus period or underscore
until [[ $identifier =~ ^[A-Za-z0-9][A-Za-z0-9\._]{4,49}$ ]]
	do
		echo "invalid identifier. must be 5-50 alphanumeric characters, with . or _ allowed after the first character"
		read -e -p "enter new identifier: " identifier
	done

# then let's get our identifier
curl --location --cookie cookies2 --data "ftp=1&identifier=${identifier}&submit=Create%20item%21" http://archive.org/create.php >/dev/null 2>&1

# we need a filenames and will use loops and arrays to get multiples, if necessary
# get first member of the array
read -e -p "enter filename or ENTER when done: " filename[0]

# loop while checking last element of array for null
until [ -z ${filename[`expr ${#filename[@]} - 1`]} ]
	do
		# get a new last element
		read -e -p "enter filename or ENTER when done: " filename[${#filename[@]}]
	done

# upload making sure not to upload our last element of the array-- the null
ftp -in >/dev/null 2>&1 <<EOF
open items-uploads.archive.org
user ${username} ${password}
cd ${identifier}
bin
mput ${filename[@]:0:$(expr ${#filename[@]} - 1)}
close
bye
EOF

# check-in the identifier
curl --location --cookie cookies2 "http://archive.org/checkin/${identifier}" >/dev/null 2>&1

# navigate to the identifier and set the mediatype
curl --location --cookie cookies2 "http://archive.org/editxml.php?field_default_mediatype=audio&field_default_collection=opensource_audio&edit_item=${identifier}&type=audio&submit=Submit%20audio" >/dev/null 2>&1

### TOFIX: should be redirected to metadata page

# clean up our mess
rm cookies cookies2
