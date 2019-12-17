#!/bin/bash


ip_list=`cat /etc/hosts|grep -vE "127|localhost"|cut -d " " -f 1`


for ip in $ip_list;do 
	firewall-cmd  --permanent --add-rich="rule family='ipv4' source address='$ip' accept"
done

firewall-cmd --reload


