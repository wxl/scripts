#!/bin/bash

# getoff - g̲et o̲fficial.f̲m f̲iles

# official.fm downloader— rescue your lost mp3s!
# all you need to provide is the url of the page that contains the player
# try to make sure if it's a multipage source like a blog, you use only one post
# if the page has multiple players, it will only grab the first instance

# author: walter lapchynski/wxl
# license: public domain
# contact: carsrcoffins23@yahoo.com
# date born: 24 sep 2012

echo "what is the URL that contains the official.fm player for the track you want?"
read orig_url

echo -e "\nwhat would you like the call the resulting file? you want something like [/path/to/]<filename>.mp3 where you provide the part before the .mp3 and the path is optional (otherwse it goes in ${PWD})… and don't use spaces, silly!"
read filename
filename="${filename}.mp3"

# figure out the track id
track_id="$(w3m -dump ${orig_url} | grep -m 1 -i xspf | sed 's|.*%2F\([0-9]\{6\}\).*|\1|')"
# take the first three characters of the track id for our folder
track_id_folder=${track_id:0:3}
# build url
final_url="http://cdn.official.fm/mp3s/${track_id_folder}/${track_id}.mp3"

### FIXME: check for url errors

# get the file
wget $final_url -O $filename
