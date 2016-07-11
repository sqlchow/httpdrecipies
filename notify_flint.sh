#!/bin/bash -x



HOSTATTEMPT=$1
SERVICESTATEID=$2 
SERVICEPROBLEMID=$3 
SERVICEDURATION="$4 $5 $6 $7" 
SERVICEDESC=$8 
SERVICEEXECUTIONTIME=$9 
HOSTNAME=${10} 
HOSTADDRESS=${11} 
SERVICESTATE=${12} 
SERVICELATENCY=${13}
SERVICEDISPLAYNAME=${14}
SERVICEEVENTID=${15}
HOSTSTATETYPE=${16}





echo "Call Started " >> /var/log/nagios_notify_flint.log
echo "Printing all arguement $* " >> /var/log/nagios_notify_flint.log
echo "                          " >> /var/log/nagios_notify_flint.log
echo "                          " >> /var/log/nagios_notify_flint.log
echo "                          " >> /var/log/nagios_notify_flint.log
echo "Printing all Variables" >> /var/log/nagios_notify_flint.log
echo $SERVICEDISPLAYNAME >> /var/log/nagios_notify_flint.log
echo $SERVICESTATE >> /var/log/nagios_notify_flint.log
echo $HOSTNAME >> /var/log/nagios_notify_flint.log
echo $HOSTSTATETYPE >> /var/log/nagios_notify_flint.log
echo $HOSTATTEMPT >> /var/log/nagios_notify_flint.log
echo $SERVICEDESC >> /var/log/nagios_notify_flint.log
echo $SERVICESTATEID >> /var/log/nagios_notify_flint.log
echo $SERVICEEVENTID >> /var/log/nagios_notify_flint.log
echo $SERVICEPROBLEMID >> /var/log/nagios_notify_flint.log
echo $SERVICELATENCY >> /var/log/nagios_notify_flint.log
echo $SERVICEEXECUTIONTIME >> /var/log/nagios_notify_flint.log
echo $SERVICEDURATION >> /var/log/nagios_notify_flint.log
echo $HOSTADDRESS >> /var/log/nagios_notify_flint.log



DATA="{\"servicename\":\""$SERVICEDISPLAYNAME"\",\"servicestate\":\""$SERVICESTATE"\",\"hostname\":\""$HOSTNAME"\",\"hoststatetype\":\""$HOSTSTATETYPE"\",\"hostattempt\":\""$HOSTATTEMPT"\",\"servicedesc\":\""$SERVICEDESC"\",\"servicestateid\":\""$SERVICESTATEID"\",\"serviceeventid\":\""$SERVICEEVENTID"\",\"serviceproblemid\":\""$SERVICEPROBLEMID"\",\"servicelatency\":\""$SERVICELATENCY"\",\"serviceexecutiontime\":\""$SERVICEEXECUTIONTIME"\",\"serviceduration\":\""$SERVICEDURATION"\",\"hostaddress\":\""$HOSTADDRESS"\"}"


echo "Printing all arguement $* " >> /var/log/nagios_notify_flint.log
echo "                          " >> /var/log/nagios_notify_flint.log
echo "                          " >> /var/log/nagios_notify_flint.log
echo "$DATA"	>> /var/log/nagios_notify_flint.log

sleep 10

/usr/bin/curl -X POST \
-H "Content-Type: application/json" \
-H "x-flint-username: admin" \
-H "x-flint-password: admin123" \
-d "$DATA" 'http://192.168.1.200:3501/v1/bit/run/httpdrecipies:restart_httpd.rb'  -o  /var/log/nagios_notify_flint.log
#-d "'"{"servicename":"$SERVICEDISPLAYNAME","servicestate": "$SERVICESTATE", "hostname":"$HOSTNAME","hoststatetype":"$HOSTSTATETYPE","hostattempt":"$HOSTATTEMPT", "servicedesc": "$SERVICEDESC", "servicestateid":"$SERVICESTATEID","serviceeventid":"$SERVICEEVENTID","serviceproblemid":"$SERVICEPROBLEMID","servicelatency":"$SERVICELATENCY","serviceexecutiontime":"$SERVICEEXECUTIONTIME","serviceduration":"$SERVICEDURATION","hostaddress":"$HOSTADDRESS"}"'" 'http://192.168.1.200:3501/v1/bit/run/httpdrecipies:restart_httpd.rb'  -o  /var/log/nagios_notify_flint.log

echo "Call Ended " >> /var/log/nagios_notify_flint.log

