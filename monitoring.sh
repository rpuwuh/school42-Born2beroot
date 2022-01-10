#!/bin/bash
(printf "\t"\#Architecture:\ ;
    echo | uname -a

printf "\t"\#CPU\ physical\ :\ ;
    grep processor /proc/cpuinfo -c

printf "\t"\#vCPU\ :\ ;
    grep processor /proc/cpuinfo -c

printf "\t"\#Memory\ Usage:\ ;
    A=`free -m | grep Mem:  | grep -oE '\b[0-9]+\b'  | sed -n 2p`
    B=`free -m | grep Mem:  | grep -oE '\b[0-9]+\b'  | sed -n 1p`
    C=`echo "scale = 2; (100 * $A) / $B" | bc -l`
    echo "$A/$B$()MB ($C%)"

printf "\t"\#Disk\ Usage:\ ;
    A=`df -T -h / /home -BK | grep ext4 | grep -oE '[+-]?([0-9]+([,][0-9]*)?|[,][0-9]+)' | sed -n 2p`
    B=`df -T -h / /home -BK | grep ext4 | grep -oE '[+-]?([0-9]+([,][0-9]*)?|[,][0-9]+)' | sed -n 7p`
    C=`echo "scale = 6; $A + $B" | bc -l`
    A=`df -T -h / /home -BK | grep ext4 | grep -oE '[+-]?([0-9]+([,][0-9]*)?|[,][0-9]+)' | sed -n 3p`
    B=`df -T -h / /home -BK | grep ext4 | grep -oE '[+-]?([0-9]+([,][0-9]*)?|[,][0-9]+)' | sed -n 8p`
    printf "`echo "scale = 1; ($A + $B) / 1000000"| bc -l`"
    printf "/`echo "scale = 1; $C / 1000000"| bc -l`"
    C=`echo "scale = 0; (49 + 10000 * ($A + $B)/$C) / 100" | bc -l`
    echo "Gb ($C%)"


printf "\t"\#CPU\ load:\ ;
    A=`top -bn1 -p 0 | grep Cpu | grep -oE '[+-]?([0-9]+([,][0-9]*)?)' | sed -n 4p`
    #printf ${A//[,]/.}\
    B=`echo "scale=1; 100 - ${A//[,]/.}"| bc -l`
    echo "$B%"

printf "\t"\#Last\ boot:\ ;
    printf "`who -b | grep -oE '[0-9].*'`"
    echo;

printf "\t"\#LVM\ use:\ ;
    if lsblk | grep -q lvm; then
        printf "yes"
    else
        printf "no"
    fi
    echo;

printf "\t"\#Connexions\ TCP\ :\ ;
    echo "`netstat -an | grep tcp | grep ESTABLISHED -c` ESTABLISHED"

printf "\t"\#User\ log:
    echo " `who | grep -E '.*' -c`"

printf "\t"\#Network:\ IP\
    printf "`hostname -I`"
    echo "(`ip a | grep -E ether | tr " " "\n" | grep -E '[0-9].*' | grep :`)"

printf "\t"\#Sudo\ :\
    A=`grep TSID /var/log/sudo/sudo.log | tail -1 | tr ";" "\n" | grep TSID | tail -1 | tr "=" "\n" | tail -1`
    B=$((36#$A))
    printf "$B cmd"
) | wall
