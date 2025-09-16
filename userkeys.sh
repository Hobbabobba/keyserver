#!/bin/bash
curl -sf https://raw.githubusercontent.com/Hobbabobba/keyserver/refs/heads/main/$1/keys
if [ $? == 0 ]; then
  exit 0
else 
  curl -sf https://git.nauheimtech.de/StefanMewes/keyserver/raw/branch/main/$1/keys
fi
