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

if servicestate == "CRITICAL"                                       #service goes ‘Down’
  response=@call.connector("ssh")                                   #calling ssh connector   
                  .set("target",hostaddress)
              .set("type","exec")              
                  .set("command","systemctl restart httpd.service && systemctl status httpd")     #Starting web server apache2
                  .set("timeout",60000)
                  .sync

  #SSH Connector Response Parameter
  result=response.get("result")
  @log.info("#{result.to_s}")
end
