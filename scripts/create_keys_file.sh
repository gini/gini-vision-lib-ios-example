#!/bin/bash

echo Removing Keys.plist...
rm GiniVisionExample/GiniVisionExample/Keys.plist

echo Reading...
client_id=$1
client_password=$2

echo clientId:
echo $client_id
echo password:
echo $client_password

echo Saving...

printf '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>client_domain</key>
	<string>gini.net</string>
	<key>client_password</key>
	<string>'$client_password'</string>
	<key>'client_id'</key>
	<string>'$client_id'</string>
</dict>
</plist>' > GiniVisionExample/GiniVisionExample/Keys.plist
