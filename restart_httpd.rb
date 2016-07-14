@log.info("input is:"+ @input.to_s)
servicename=               @input.get("servicename")   #getting the values from JSON
hostname=                  @input.get("hostname")
servicestate=              @input.get("servicestate")
hoststatetype=             @input.get("hoststatetype")
hostattempt=               @input.get("hostattempt")
servicedesc=               @input.get("servicedesc")
hoststateid=               @input.get("servicestateid")
serviceeventid=            @input.get("serviceeventid")
serviceproblemid=          @input.get("serviceproblemid")
servicelatency=            @input.get("servicelatency")
serviceexecutiontime=      @input.get("serviceexecutiontime")
serviceduration=           @input.get("serviceduration")
hostaddress=               @input.get("hostaddress")
manageenginerequestid=      @input.get(MANAGE_ENGINE_REQUESTID)

@log.info("restart_httpd was called host "+ hostname +"Related incident Ticket Number : "+ manageenginerequestid )

if servicestate == "CRITICAL"                                       #service goes ‘Down’
  response=@call.connector("ssh")                                   #calling ssh connector   
	.set("target",hostaddress)
	.set("type","exec")             
	.set("username","root")
	.set("password","Flint@01")
	.set("command","touch /tmp/something && systemctl restart httpd.service && systemctl status httpd")     #Starting web server apache2
	.set("timeout",60000)
	.sync

  #SSH Connector Response Parameter
  result=response.get("result")
  @log.info("#{result.to_s}")
end

#if response.exitcode == 0	# if the previous call succeeds then Update Manage Engine
   response=@call.connector("manageenginesdp")    
              .set("action","update-request")
              .set("request-id",manageenginerequestid)
              .set("requester","administrator")
              .set("subject","Testing update service request")
              .set("description","Specific descriptio")
              .set("requesttemplate","Unable to browse")
              .set("priority","Low")
              .set("site","-")
              .set("group","Network")
              .set("technician","Flint Operator")
              .set("level","Tier 3")
              .set("status","Close")
              .set("service",@service)
              .timeout(10000)                                                 
              .sync
    
    result=response.get("result")
    @log.info("#{result.to_s}")

	if response.exitcode == 0               # 0 is success.
	  puts "success"
	  # take action in case of success
	else                                    # non zero means fail
	  puts "fail"
	  puts "Reason:" + response.message     # get the reason of failure
	  ## Take action in case of failure
	end
#end 

