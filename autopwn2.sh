#!/bin/bash

if ! ping -q -c1 google.com &>/dev/null
then
    printf "[!] No network! Aborting..." && exit
fi

interface="wlan0"
network_ssid=$(iwgetid -r)
gateway=$(ip route | grep -v 'default' | awk {'print $1'})

printf "########## Network AutoPWN v1 ##########\n[i] Found network SSID: $network_ssid\n[i] Found network gateway: $gateway\n[*] Mapping network...\n\n"

ips=($(nmap -sn  $gateway | awk '/is up/ {print up}; {gsub (/\(|\)/,""); up = $NF}' | sort
))

#echo "${ips[@]}"

ipArray=${ips[@]}
ipArraLenght=${#ips[@]}

if [ ${#ips[@]} -eq "0" ]
then 
    printf "\n[!] No IPs found!"
    exit
fi

printf "[i] Found \e[92m${#ips[@]}\e[0m IPs!\n"

#nmap -sn $gateway -e $interface | awk '/Nmap scan report for/{printf $5;}/MAC Address:/{print " => "substr($0, index($0,$3)) }' | sort

for i in ${ips[@]}
do
    printf "\n$i\n"
done

#printf "%s\n ${ips[*]}"

i=0


while [ $i -lt ${#ips[@]} ]
do

sshPort=$(nmap -p 22 ${ips[$i]} | grep 22/ | awk '{print $2}')

httpPort=$(nmap -p 80 ${ips[$i]} | grep 80/ | awk '{print $2}')

httpsPort=$(nmap -p 443 ${ips[$i]} | grep 443/ | awk '{print $2}')

ftpPort=$(nmap -p 21 ${ips[$i]} | grep 21/ | awk '{print $2}')

telnetPort=$(nmap -p 23 ${ips[$i]} | grep 23/ | awk '{print $2}')


    printf "\n[*] Scanning ip ($((i+1))/${#ips[@]}) - ${ips[$i]}\n"

    #nmap -vv ${ips[$i]} | awk -F'[ /]' '/Discovered open port/{print $NF":"$4}'
    
    
    #nmap -n -Pn ${ips[$i]} -p80,8080,443,22 -oG - | grep '/open/' | awk '/Host:/{print $2}'
    
    if [[ $sshPort == "open" ]] 
    then
        printf "SSH: \e[92m$sshPort\e[0m\n"
        sshCrack=1
    elif [[ $sshPort == "filtered" ]]
    then
        printf "SSH: \e[93m$sshPort\e[0m\n"
        sshCrack=1
    else
        printf "SSH: \e[91m$sshPort\e[0m\n"
        sshCrack=0
    fi
    
    
    if [[ $httpPort == "open" ]] 
    then
        printf "HTTP: \e[92m$httpPort\e[0m\n"
        httpCrack=1
    elif [[ $httpPort == "filtered" ]]
    then
        printf "HTTP: \e[93m$httpPort\e[0m\n"
        httpCrack=1
    else
        printf "HTTP: \e[91m$httpPort\e[0m\n"
        httpCrack=0
    fi
    
    
    if [[ $httpsPort == "open" ]] 
    then
        printf "HTTPS: \e[92m$httpsPort\e[0m\n"
        httpsCrack=1
    elif [[ $httpsPort == "filtered" ]]
    then
        printf "HTTPS: \e[93m$httpsPort\e[0m\n"
        httpsCrack=1
    else
        printf "HTTPS: \e[91m$httpsPort\e[0m\n"
        httpsCrack=0
    fi

    if [[ $ftpPort == "open" ]] 
    then
        printf "FTP: \e[92m$ftpPort\e[0m\n"
        ftpCrack=1
    elif [[ $ftpPort == "filtered" ]]
    then
        printf "FTP: \e[93m$ftpPort\e[0m\n"
        ftpCrack=1
    else
        printf "FTP: \e[91m$ftpPort\e[0m\n"
        ftpCrack=0
    fi

    if [[ $telnetPort == "open" ]] 
    then
        printf "TELNET: \e[92m$telnetPort\e[0m\n"
        telnetCrack=1
    elif [[ $telnetPort == "filtered" ]]
    then
        printf "TELNET: \e[93m$telnetPort\e[0m\n"
        telnetCrack=1
    else
        printf "TELNET: \e[91m$telnetPort\e[0m\n"
        telnetCrack=0
    fi

    sleep 0.5
    
    i=$((i+1))
done


printf "\n[*] Attempting to crack services...\n"

#nmap -sn $gateway | awk '/is up/ {print up}; {gsub (/\(|\)/,""); up = $NF}' | sort



#while [ $i -lt ${#ips[@]} ]
#do
   # printf "\n[*] Scanning ${#ips[$i]}\n"
    #nmap ${#ips[$i]}
  #  i=$((i+1))
#done 

#for i in "$ipsArray"
#do
   # :
   # printf "Scanning ${ips[$i]}"
 #   
#done




