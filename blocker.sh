#!/bin/bash

# Block IPs with more than n request per minute by iptables
# Using Nginx Log file as input
nginx_logs_sample=$1

if [[ -n $1 ]]
then
    echo "!!!!Input recieved!!!!"
fi

if [[ -n $1 && -f $nginx_logs_sample ]]
then
	
	#Get input form User
	read -p "Enter the limitation of tries in one minute:" limit

	#Parsing Log file and sort & uniq ips by hour and minute
	awk -F' |:' '{print $1" "$5":"$6}' $nginx_logs_sample | sort | uniq -c | sort -rn | awk '{ if ( $1 > '$limit' ) { print $2; } }' | sort | uniq > blocked_ips

	#While loop gets the
	while read ip; do
		echo "$ip"" BLOCKED"
		iptables -I INPUT -s $ip -j DROP 	#Block target IP Address
#		iptables -D INPUT -s $ip -j DROP	#Uncomment to remove the IP from Blacklist
	done < blocked_ips
	#End of While loop
else
	echo "You must provide an nginx log file to block suspecious IPs"
fi

#Uncomment to remove temporary file created by bash script
#rm -f blocked_ips

