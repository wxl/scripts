#!/bin/bash

# uploadit v1.0
# author: walter lapchynski/wxl
# contact: carsrcoffins23@yahoo.com
# license: public domain
# born: 9 feb 2013

# what it does: uploads Community Audio to Internet Archive
# make sure you have cURL!

# first let's get our cookie
curl --location --dump-header cookies http://archive.org/account/login.php

# let's get out login info
read -e -p "username: " username
read -es -p "password: " password

# now let's get logged in, making sure to get a new cookie
curl --location --dump-header cookies2 --cookie cookies --data-urlencode "username=${username}" --data-urlencode "password=${password}" --data-urlencode "remember=CHECKED" --data-urlencode "action=login" --data-urlencode "submit=Log in" http://archive.org/account/login.php

# we need an identifier
### TOFIX: make sure to check if it's valid
read -e -p "identifier: " identifier

# then let's get our identifier
curl --location --cookie cookies2 --data "ftp=1&identifier=${identifier}&submit=Create%20item%21" http://archive.org/create.php

# we need a filename
### TOFIX: do more than one with a loop, possible curl ftp
read -e -p "filename: " filename

# upload
ftp -in <<EOF
open items-uploads.archive.org
user ${username} ${password}
cd ${identifier}
bin
put ${filename}
close
bye
EOF

# check-in the identifier
curl --location --cookie cookies2 "http://archive.org/checkin/${identifier}"

# navigate to the identifier and set the mediatype
curl --location --cookie cookies2 "http://archive.org/editxml.php?field_default_mediatype=audio&field_default_collection=opensource_audio&edit_item=${identifier}&type=audio&submit=Submit%20audio"

### TOFIX: should be redirected to metadata page

# clean up our mess
rm cookies cookies2
