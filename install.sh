#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "[i] Run this script as root!!! Aborting...\sn" 
   exit 1
fi

printf "[i] Checking network connection...\n"

if ! ping -q -c1 google.com &>/dev/null
then
    printf "[!] No network! Aborting...\n" && exit
fi

clear
printf '   _  __    __  ___   ____
  / |/ /__ / /_/ _ | /  _/
 /    / -_) __/ __ |_/ /  
/_/|_/\__/\__/_/ |_/___/  
----------------------------------
Network Exploitation AI installer
----------------------------------
'

info='\n[i]]INSTALLING TOOL...\n'

printf "\n[i] Checking and installing tools! Please wait...\n"

command -v hydra >/dev/null 2>&1 || { printf >&2 "%s$info"; apt-get install thc-hydra -y; }
command -v python3 >/dev/null 2>&1 || { printf >&2 "%s$info"; apt-get install python3 -y; }
# command -v python3 >/dev/null 2>&1 || { printf >&2 "%s$info"; apt-get install wireless-tools -y; }


if [ ! -d "$(pwd)/Mikrotik-WinBox-Exploit" ]
then
   git clone https://github.com/dharmitviradia/Mikrotik-WinBox-Exploit
   chmod +x Mikrotik-WinBox-Exploit/*
fi

chmod +x autopwn-test.sh

printf "\n[i] Installation done!\n"
