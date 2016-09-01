#Log all input at call 
@log.info("input is:"+ @input.to_s)

# Initialization 

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

# Initialization  ends here

#We call Manage Engine Updating the ticket with intent to auto resolve
@log.info("restart_httpd was called for host "+ hostname +"Related incident Ticket Number : "+ manageenginerequestid )

  response10=@call.connector("manageenginesdp")   
             .set("action","add-note")
             .set("request-id",manageenginerequestid.to_i)
             .set("ispublic","false")
             .set("notestext","Flint will attempt auto resolution")                              
             .sync
  

  result10=response10.get("operation").get("result")   

  response0=@call.connector("manageenginesdp")    
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
            .sync
    
# result0=response0.get("result")
#
  result0=response0.get("operation").get("result")
  @log.info("#{result0.to_s}")

# Manage Engine  Call ends here 

#Auto resolve on basis of alertype  Code starts here 

#Call to auto resolve based on alrt type HTTP 

  if  alerttype == "HTTP"                                       #service goes ‘Down’
	response1=@call.connector("ssh")                                   #calling ssh connector   
		  .set("target",hostaddress)
		  .set("type","exec")             
		  .set("username","root")
		  .set("password","Flint@01")
		  .set("command","systemctl -q restart httpd.service && systemctl is-active httpd && logout")     #Starting web server apache2
		  .set("timeout",60000)
		  .sync

        result1=response1.get("result")
        @log.info("#{result1.to_s}")

      if result1.include? "active"
	response10=@call.connector("manageenginesdp")   
                   .set("action","add-note")
                   .set("request-id",manageenginerequestid.to_i)
                   .set("ispublic","false")
                   .set("notestext","Flint succeeded in auto resolution")                              
                   .sync

        resut10=response10.get("result")
        @log.info("#{result10.to_s}")

	# closing request 
	response2=@call.connector("manageenginesdp")    
                  .set("action","close-request")
                  .set("request-id",manageenginerequestid.to_i)
                  .set("close-accepted","Accepted")
                  .set("close-comment","Service restarted successfully")                               
                  .async

        result2=response2.get("operation").get("result")
        @log.info("#{result2.to_s}")

      else
	response11=@call.connector("manageenginesdp")   
                   .set("action","add-note")
                   .set("request-id",manageenginerequestid.to_i)
                   .set("ispublic","false")
                   .set("notestext","Flint was unsuccessful in auto resolution")                              
                   .sync

        result11=response11.get("operation").get("result")
        @log.info("#{result11.to_s}")

      end

  end

#Call to auto resolve for alert type  HTTP ends here 

#Call to auto resolve based on alert type DISK 

  if  alerttype == "DISK" 
	response12=@call.connector("manageenginesdp")   
                   .set("action","add-note")
                   .set("request-id",manageenginerequestid.to_i)
                   .set("ispublic","false")
                   .set("notestext","Flint will attempt auto resolution")                              
                   .sync

	result12=response12.get("operation").get("result")
        @log.info("#{result12.to_s}")


	response3=@call.connector("ssh")                                   #calling ssh connector   
		  .set("target",hostaddress)
		  .set("type","exec")             
		  .set("username","root")
		  .set("password","Flint@01")
		  .set("command","lvextend -L+1000M /dev/mapper/flintvg-flint_vol1 &&  resize2fs /dev/mapper/flintvg-flint_vol1 ")     
		  .set("timeout",60000)
		  .sync

        result3=response3.get("result")
        @log.info("#{result3.to_s}")



	if result3.include? "Insufficient"
	@log.info("SSH command to resize/extend VG/FS failed") 

	response4=@call.connector("manageenginesdp")
                  .set("action","add-request")
                  .set("requester","Flint Operator")
                  .set("subject", "Attention Storage Admins : DISK/ LUNS request.Auto resolution failed for " + manageenginerequestid + " " + manageenginesubject )
                  .set("description", "Requesting LUNS from Storage Admins :Not enough LUNS to grow VG ,Auto Resolution fails Refer to acted alert "+ manageenginerequestid)
                  .set("requesttemplate", "Unable to browse")
                  .set("requestType","Incident")
                  .set("priority", "High")
                  .set("site", "-")
                  .set("group","Network")
                  .set("technician", "John")
                  .set("level", "Tier 1")
                  .set("status", "Open")
                  .set("service", "Hardware")
                  .timeout(10000)
                  .sync

	result4=response4.get("operation").get("result")
	@log.info("#{result4.to_s}")
	
        else   
	
	  response5=@call.connector("manageenginesdp")    
                    .set("action","close-request")
                    .set("request-id",manageenginerequestid.to_i)
                    .set("close-accepted","Accepted")
                    .set("close-comment","Volume Group expanded successfully")                               
                    .sync

          result5=response5.get("operation").get("result")
	  @log.info("#{result5.to_s}")

        end


  end
