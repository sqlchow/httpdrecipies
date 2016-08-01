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
manageenginerequestid=     @input.get("MANAGE_ENGINE_REQUESTID")
manageenginesubject=	   @input.get("MANAGE_ENGINE_REQUESTSUB")
alerttype=		   @input.get("ALERTTYPE")

@log.info("restart_httpd was called for host "+ hostname +"Related incident Ticket Number : "+ manageenginerequestid )

   response=@call.connector("manageenginesdp")    
              .set("action","update-request")
              .set("request-id",manageenginerequestid.to_i)
              .set("requester","Flint Operator")
              .set("subject",manageenginesubject.to_s)
              .set("description", servicedesc)
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
    
#    result=response.get("result")
#    @log.info("#{result.to_s}")

if  alerttype == "HTTP"                                       #service goes ‘Down’
  response=@call.connector("ssh")                                   #calling ssh connector   
	.set("target",hostaddress)
	.set("type","exec")             
	.set("username","root")
	.set("password","Flint@01")
	.set("command","systemctl -q restart httpd.service && systemctl is-active httpd && logout")     #Starting web server apache2
	.set("timeout",60000)
	.sync

#  result=response.get("result")
#  @log.info("#{result.to_s}")



	  # closing request 
	response=@call.connector("manageenginesdp")    
              .set("action","close-request")
              .set("request-id",manageenginerequestid.to_i)
              .set("close-accepted","Accepted")
              .set("close-comment","Service restarted successfully")                               
              .async


#    result=response.get("result")
#    @log.info("#{resulti.to_s}")

end

if  alerttype == "DISK"                                       #service goes ‘Down’
  response=@call.connector("ssh")                                   #calling ssh connector   
	.set("target",hostaddress)
	.set("type","exec")             
	.set("username","root")
	.set("password","Flint@01")
	.set("command","lvextend -L+100M /dev/mapper/flintvg-flint_vol1 | echo $* > /dev/null  &&  resize2fs /dev/mapper/flintvg-flint_vol1 | echo $? > /dev/null ; if [[ $? = 0 ]]; then echo 0 ; else echo 1 ; exit 1 ;fi")     
	.set("timeout",60000)
	.sync

  #SSH Connector Response Parameter
# result=response.get("result")
#  @log.info("#{result.to_s}")



	  # closing request
	response=@call.connector("manageenginesdp")    
              .set("action","close-request")
              .set("request-id",manageenginerequestid.to_i)
              .set("close-accepted","Accepted")
              .set("close-comment","Volume Group expanded successfully")                               
              .async


#    result=response.get("result")
#    @log.info("#{result.to_s}")

end
