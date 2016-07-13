#!/bin/bash -x


# Setting event Handler arguements to appropriate variables names as declared in NagiosXi Command
#
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

#Flint Variables
FLINT_WORKERNODE_URL="192.168.1.200:3500"
FLINT_USERNAME="admin"
FLINT_PASSWORD="admin123"


create_payload_json()
{

  PAYLOAD_JSON="{\"servicename\":\""$SERVICEDISPLAYNAME"\",\"servicestate\":\""$SERVICESTATE"\",\"hostname\":\""$HOSTNAME"\",\"hoststatetype\":\""$HOSTSTATETYPE"\",\"hostattempt\":\""$HOSTATTEMPT"\",\"servicedesc\":\""$SERVICEDESC"\",\"servicestateid\":\""$SERVICESTATEID"\",\"serviceeventid\":\""$SERVICEEVENTID"\",\"serviceproblemid\":\""$SERVICEPROBLEMID"\",\"servicelatency\":\""$SERVICELATENCY"\",\"serviceexecutiontime\":\""$SERVICEEXECUTIONTIME"\",\"serviceduration\":\""$SERVICEDURATION"\",\"hostaddress\":\""$HOSTADDRESS"\"}"

}

create_payload_xml()
{
  PAYLOAD_XML=

}

DATA="{\"servicename\":\""$SERVICEDISPLAYNAME"\",\"servicestate\":\""$SERVICESTATE"\",\"hostname\":\""$HOSTNAME"\",\"hoststatetype\":\""$HOSTSTATETYPE"\",\"hostattempt\":\""$HOSTATTEMPT"\",\"servicedesc\":\""$SERVICEDESC"\",\"servicestateid\":\""$SERVICESTATEID"\",\"serviceeventid\":\""$SERVICEEVENTID"\",\"serviceproblemid\":\""$SERVICEPROBLEMID"\",\"servicelatency\":\""$SERVICELATENCY"\",\"serviceexecutiontime\":\""$SERVICEEXECUTIONTIME"\",\"serviceduration\":\""$SERVICEDURATION"\",\"hostaddress\":\""$HOSTADDRESS"\"}"



/usr/bin/curl -X POST \
-H "Content-Type: application/json" \
-H "x-flint-username: admin" \
-H "x-flint-password: admin123" \
-d "$DATA" 'http://192.168.1.200:3501/v1/bit/run/httpdrecipies:restart_httpd.rb'  -o  /var/log/nagios_notify_flint.log
#-d "'"{"servicename":"$SERVICEDISPLAYNAME","servicestate": "$SERVICESTATE", "hostname":"$HOSTNAME","hoststatetype":"$HOSTSTATETYPE","hostattempt":"$HOSTATTEMPT", "servicedesc": "$SERVICEDESC", "servicestateid":"$SERVICESTATEID","serviceeventid":"$SERVICEEVENTID","serviceproblemid":"$SERVICEPROBLEMID","servicelatency":"$SERVICELATENCY","serviceexecutiontime":"$SERVICEEXECUTIONTIME","serviceduration":"$SERVICEDURATION","hostaddress":"$HOSTADDRESS"}"'" 'http://192.168.1.200:3501/v1/bit/run/httpdrecipies:restart_httpd.rb'  -o  /var/log/nagios_notify_flint.log

echo "Call Ended " >> /var/log/nagios_notify_flint.log
