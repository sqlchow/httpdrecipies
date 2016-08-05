#!/bin/bash 
#
ARGS="$*"
HOSTATTEMPT=$(echo $ARGS | awk -F '-EOA-' '{printf $1}')
SERVICESTATEID=$(echo $ARGS | awk -F '-EOA-' '{printf $2}') 
SERVICEPROBLEMID=$(echo $ARGS | awk -F '-EOA-' '{printf $3}') 
SERVICEDURATION=$(echo $ARGS | awk -F '-EOA-' '{printf $4 }') 
SERVICEDESC=$(echo $ARGS | awk -F '-EOA-' '{printf $5}' | tr ' ' '_') 
SERVICEEXECUTIONTIME=$(echo $ARGS | awk -F '-EOA-' '{printf $6}')
HOSTNAME=$(echo $ARGS | awk -F '-EOA-' '{printf $7}')
HOSTADDRESS=$(echo $ARGS | awk -F '-EOA-' '{printf $8}')
SERVICESTATE=$(echo $ARGS | awk -F '-EOA-' '{printf $9}') 
SERVICELATENCY=$(echo $ARGS | awk -F '-EOA-' '{printf $10}')
SERVICEDISPLAYNAME=$(echo $ARGS | awk -F '-EOA-' '{printf $11}' |  tr ' ' '_')
SERVICEEVENTID=$(echo $ARGS | awk -F '-EOA-' '{printf $12}')
HOSTSTATETYPE=$(echo $ARGS | awk -F '-EOA-' '{printf $13}')
PROCESS_ID="$$"

ISALERTTYPE_DISK=$(echo $ARGS | awk -F '-EOA-' '{printf $11}' | grep -q -i Disk ; echo $?)
if [[ $ISALERTTYPE_DISK -eq 0 ]];
   then ALERT_TYPE="DISK"
else 
   ALERT_TYPE="HTTP"
fi

TECHNICIAN_KEY="950BF8C4-4BB0-41D0-A893-E3D69BEEE7AE"


#create xml for Manage Engine Service Desk 
# Note remove all whitespace in payload . to Retain white space use %20
MESDP_SUBJECT="Issues detected with $HOSTADDRESS :  $SERVICEDISPLAYNAME reported $SERVICESTATE"

MESDP_PAYLOAD="<Operation>\
<Details>\
<requester>Nagios%20Event%20Notifier</requester>\
<subject>Issues%20detected%20with%20$HOSTADDRESS%20:%20%20$SERVICEDISPLAYNAME%20reported%20$SERVICESTATE</subject>\
<description>Nagios%20detected%20$HOSTADDRESS:$SERVICEDISPLAYNAME%20in%20critical%20state</description>\
<callbackURL>http://192.168.1.63</callbackURL>\
<requesttemplate>FILESYSTEMISSUE</requesttemplate>\
<priority>High</priority>\
<site></site>\
<group>Network</group>\
<technician>Nagios%20Operator</technician>\
<level>Tier%203</level>\
<status>open</status>\
<service>Email</service>\
</Details>\
</Operation>"


call_managesdp(){
#call Manage Engine Retrieve workoerder id for flint
/usr/bin/curl --connect-timeout 60 -X POST \
  -H "Content-Type:x-www-form-urlencoded"\
  'http://192.168.1.253:8484/sdpapi/request/?OPERATION_NAME=ADD_REQUEST&'"TECHNICIAN_KEY=$TECHNICIAN_KEY&INPUT_DATA=$MESDP_PAYLOAD"'' -o /tmp/workorder$$.log

if [[ $? -eq 0 ]];
   then echo "$(date "+%d-%m-%y %T") INFO Call to Manage Engine Service Desk Succeeded "  >> /var/log/nagios/eventnotifier.log
   MANAGE_ENGINE_REQUESTID=`xml_grep workorderid --text_only /tmp/workorder$$.log`
   echo "$(date "+%d-%m-%y %T") INFO PID $PROCESS_ID Request id $MANAGE_ENGINE_REQUESTID created for the alert "  >> /var/log/nagios/eventnotifier.log
else 
   echo "$(date "+%d-%m-%y %T") INFO PID $PROCESS_ID Call to  Manage Engine Service Desk Failed , exiting" >> /var/log/nagios/eventnotifier.log
   return 1
fi

}




call_flint(){
#call Flint 

DATA="{\"servicename\":\""$SERVICEDISPLAYNAME"\",\"servicestate\":\""$SERVICESTATE"\",\"hostname\":\""$HOSTNAME"\",\"hoststatetype\":\""$HOSTSTATETYPE"\",\"hostattempt\":\""$HOSTATTEMPT"\",\"servicedesc\":\""$SERVICEDESC"\",\"servicestateid\":\""$SERVICESTATEID"\",\"serviceeventid\":\""$SERVICEEVENTID"\",\"serviceproblemid\":\""$SERVICEPROBLEMID"\",\"servicelatency\":\""$SERVICELATENCY"\",\"serviceexecutiontime\":\""$SERVICEEXECUTIONTIME"\",\"serviceduration\":\""$SERVICEDURATION"\",\"MANAGE_ENGINE_REQUESTID\":\""$MANAGE_ENGINE_REQUESTID"\",\"MANAGE_ENGINE_REQUESTSUB\":\""$MESDP_SUBJECT"\",\"ALERTTYPE\":\""$ALERT_TYPE"\",\"hostaddress\":\""$HOSTADDRESS"\"}"

echo "$(date "+%d-%m-%y %T") INFO PID $PROCESS_ID DATA = $DATA "  >> /var/log/nagios/eventnotifier.log

/usr/bin/curl --connect-timeout 60 -X POST \
-H "Content-Type: application/json" \
-H "x-flint-username: admin" \
-H "x-flint-password: admin123" \
-d "$DATA" 'http://192.168.1.200:3501/v1/bit/run/httpdrecipies:restart_httpd.rb'  -o  /var/log/nagios_notify_flint.log

if [[ $? -eq 0 ]];
   then echo "$(date "+%d-%m-%y %T") INFO PID $PROCESS_ID Call to Flint Box  Succeeded "  >> /var/log/nagios/eventnotifier.log
else
   echo "$(date "+%d-%m-%y %T") ERROR PID $PROCESS_ID Call to Flint box  Failed , exiting" >> /var/log/nagios/eventnotifier.log
   return 1
fi

}


main(){

echo "$(date "+%d-%m-%y %T") INFO PID $PROCESS_ID Call Started "   >> /var/log/nagios/eventnotifier.log
echo "$(date "+%d-%m-%y %T") INFO PID $PROCESS_ID Script arguement are $* " >>   /var/log/nagios/eventnotifier.log
echo "$(date "+%d-%m-%y %T") INFO PID $PROCESS_ID json created as follows:\n$DATA " >> /var/log/nagios/eventnotifier.log


  if [[ "$SERVICESTATE" = "CRITICAL" ]];
	then echo "$(date "+%d-%m-%y %T") INFO PID $PROCESS_ID event notifier invoked from Monitoring for $HOSTADDRESS  Alert Type : $SERVICESTATE " >> /var/log/nagios/eventnotifier.log
	call_managesdp 
        if [[ $? -eq 0 ]];
           then sleep 10 && call_flint
        else
 	   echo " Call to call_managesdp failed " >> /var/log/nagios/eventnotifier.log 
	fi
  else
	echo "$(date "+%d-%m-%y %T") INFO PID $PROCESS_ID event notifier invoked from Monitoring for $HOSTADDRESS  Alert Type : $SERVICESTATE , no action required" >> /var/log/nagios/eventnotifier.log
   	echo "Nothing to do "
  fi
   echo "$(date "+%d-%m-%y %T") INFO PID $PROCESS_ID Call Ended "   >> /var/log/nagios/eventnotifier.log

}
main $*
