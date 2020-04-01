#!/usr/bin/env bash
cd ..
./scripts/create_keys_file.sh ${CLIENT_ID} ${CLIENT_PASSWORD}
echo Saved Keys.plist:
cat GiniVisionExample/GiniVisionExample/Keys.plist
