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

TECHNICIAN_KEY="950BF8C4-4BB0-41D0-A893-E3D69BEEE7AE"

#Create json for Flint
#DATA="{\"servicename\":\""$SERVICEDISPLAYNAME"\",\"servicestate\":\""$SERVICESTATE"\",\"hostname\":\""$HOSTNAME"\",\"hoststatetype\":\""$HOSTSTATETYPE"\",\"hostattempt\":\""$HOSTATTEMPT"\",\"servicedesc\":\""$SERVICEDESC"\",\"servicestateid\":\""$SERVICESTATEID"\",\"serviceeventid\":\""$SERVICEEVENTID"\",\"serviceproblemid\":\""$SERVICEPROBLEMID"\",\"servicelatency\":\""$SERVICELATENCY"\",\"serviceexecutiontime\":\""$SERVICEEXECUTIONTIME"\",\"serviceduration\":\""$SERVICEDURATION"\",\"hostaddress\":\""$HOSTADDRESS"\"}"

#create xml for Manage Engine Service Desk 
# Note remove all whitespace in payload . to Retain white space use %20
MESDP_PAYLOAD="<Operation>\
<Details>\
<requester>Nagios%20Event%20Notifier</requester>\
<subject>Host%20$HOSTADDRESS%20issues%20%20$SERVICEDISPLAYNAME%20reported%20$SERVICESTATE</subject>\
<description>Nagios%20detected%20$HOSTADDRESS:$SERVICEDISPLAYNAME%20in%20critical%20state</description>\
<callbackURL>http://192.168.1.63</callbackURL>\
<requesttemplate>$SERVICEDISPLAYNAME%20in%20$SERVICESTATE%20</requesttemplate>\
<priority>High</priority>\
<site></site>\
<group>Network</group>\
<technician>Nagios%20Operator</technician>\
<level>Tier%203</level>\
<status>open</status>\
<service>Email</service>\
</Details>\
</Operation>"


#call Manage Engine Retrieve workoerder id for flint
/usr/bin/curl -X POST \
  -H "Content-Type:x-www-form-urlencoded"\
  'http://192.168.1.253:8484/sdpapi/request/?OPERATION_NAME=ADD_REQUEST&'"TECHNICIAN_KEY=$TECHNICIAN_KEY&INPUT_DATA=$MESDP_PAYLOAD"'' -o /tmp/wrokoder$$.log

#set Request ID
MANAGE_ENGINE_REQUESTID=`xml_grep workorderid --text_only /tmp/wrokoder$$.log`

#Create json for Flint
DATA="{\"servicename\":\""$SERVICEDISPLAYNAME"\",\"servicestate\":\""$SERVICESTATE"\",\"hostname\":\""$HOSTNAME"\",\"hoststatetype\":\""$HOSTSTATETYPE"\",\"hostattempt\":\""$HOSTATTEMPT"\",\"servicedesc\":\""$SERVICEDESC"\",\"servicestateid\":\""$SERVICESTATEID"\",\"serviceeventid\":\""$SERVICEEVENTID"\",\"serviceproblemid\":\""$SERVICEPROBLEMID"\",\"servicelatency\":\""$SERVICELATENCY"\",\"serviceexecutiontime\":\""$SERVICEEXECUTIONTIME"\",\"serviceduration\":\""$SERVICEDURATION"\",\"MANAGE_ENGINE_REQUESTID\":\""$MANAGE_ENGINE_REQUESTID"\",\"hostaddress\":\""$HOSTADDRESS"\"}"

echo $DATA


sleep 10
#call Flint 
/usr/bin/curl -X POST \
-H "Content-Type: application/json" \
-H "x-flint-username: admin" \
-H "x-flint-password: admin123" \
-d "$DATA" 'http://192.168.1.200:3501/v1/bit/run/httpdrecipies:restart_httpd.rb'  -o  /var/log/nagios_notify_flint.log
#-d "'"{"servicename":"$SERVICEDISPLAYNAME","servicestate": "$SERVICESTATE", "hostname":"$HOSTNAME","hoststatetype":"$HOSTSTATETYPE","hostattempt":"$HOSTATTEMPT", "servicedesc": "$SERVICEDESC", "servicestateid":"$SERVICESTATEID","serviceeventid":"$SERVICEEVENTID","serviceproblemid":"$SERVICEPROBLEMID","servicelatency":"$SERVICELATENCY","serviceexecutiontime":"$SERVICEEXECUTIONTIME","serviceduration":"$SERVICEDURATION","hostaddress":"$HOSTADDRESS"}"'" 'http://192.168.1.200:3501/v1/bit/run/httpdrecipies:restart_httpd.rb'  -o  /var/log/nagios_notify_flint.log

echo "Call Ended " >> /var/log/nagios_notify_flint.log

