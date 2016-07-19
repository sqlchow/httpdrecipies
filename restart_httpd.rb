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
manageenginerequestid=      @input.get("MANAGE_ENGINE_REQUESTID")

@log.info("restart_httpd was called for host "+ hostname +"Related incident Ticket Number : "+ manageenginerequestid )

   response=@call.connector("manageenginesdp")    
              .set("action","update-request")
              .set("request-id",manageenginerequestid.to_i)
              .set("requester","Flint Operator")
              .set("subject","Flint attempted Restarting the Service")
              .set("description","Flint will attempt to ssh to "+ hostaddress +" and restart "+ servicedesc)
              .set("requesttemplate","Unable to browse")
              .set("priority","Low")
              .set("site","-")
              .set("group","Network")
              .set("technician","Flint Operator")
              .set("level","Tier 3")
              .set("status","Close")
              .set("service",@service)
              .timeout(10000)                                                 
              .async
    
    result=response.get("result")
    @log.info("#{result.to_s}")

@log.info("Call to Manage Engine Completed ") 
@log.info("Call to SSH Connector Started ") 



if servicestate == "CRITICAL"                                       #service goes ‘Down’
  response=@call.connector("ssh")                                   #calling ssh connector   
	.set("target",hostaddress)
	.set("type","exec")             
	.set("username","root")
	.set("password","Flint@01")
	.set("command","systemctl -q restart httpd.service && systemctl is-active httpd ")     #Starting web server apache2
	.set("timeout",60000)
	.async

  #SSH Connector Response Parameter
  resultfromaction=response.get("result")
  @log.info("#{resultfromaction.to_s}")

@log.info("Call to SSH Connector completed") 
@log.info("Call to Manage Engine to close ticket ") 


  response2=@call.connector("manageenginesdp")    
               .set("action","close-request")
               .set("request-id",manageenginerequestid.to_i)
               .set("close-accepted","Accepted")
               .set("close-comment","Service restarted successfully")                               
               .async

@log.info("Call to Manage Engine close-request Completed ") 

  resulti=response2.get("result")
  @log.info("#{resulti.to_s}")

end
