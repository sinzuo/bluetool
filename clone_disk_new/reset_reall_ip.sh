#!/bin/bash




function modify_network_scripts()
{
    WORK_DIR=$(pwd)
    cd /etc/sysconfig/network-scripts
	
    MGT1=`ip add|grep BROADCAST|sort|awk -F " " '{print $2}'| sed 's/://g'| awk 'NR==1{print}'`
	
    ETH_SCRIPTS1=`ls | grep ifcfg | grep -v lo | awk 'NR==1{print}'`

    if [ -z "$ETH_SCRIPTS1" ]; then
        echo "Error: configuration management was not found at the mouth of the script" | tee -a $OPERATION_LOG
        cd $WORK_DIR
        return 1
    fi  

    # Rename MGT1 if needed
    if [ "$ETH_SCRIPTS1" != "ifcfg-$MGT1" ]; then
        mv -f $ETH_SCRIPTS1 ifcfg-$MGT1
    fi

	# Modify management port(s) ifcfg script(s)
	if [ -n "$MGT1" ]; then
		eval sed -i 's/^NAME.*$/NAME=$MGT1/g' ifcfg-$MGT1
		sed -i 's/^IPADDR.*$/IPADDR=172.16.110.62/g' ifcfg-$MGT1
	fi
	
	cd $WORK_DIR

    #restart network
    service network restart
	
    return 0
}

modify_network_scripts
