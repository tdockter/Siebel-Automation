. /home/sadmin/.bash_profile
log=/siebeladmin/sadmin/log/startserver.log
status=0
 
###########################################################################
# Pre Processing
###########################################################################
echo "`hostname ` Siebel startup started: `date `" >$log
 
###########################################################################
# Main Processing
###########################################################################
cd /siebelapp/16.0.0.0.0/ses/gtwysrvr >>$log
. ./siebenv.sh >>$log
 
#Implement Siebel Gateway Logging
SIEBEL_LOG_EVENTS=3
#SIEBEL_LOG_EVENTS= Level of 1 to 5
 
#Is Gateway Running?...
gatecount=$(ps -ef|grep gtwyns|wc -l)
   echo "Is Gateway running"
   echo "Is Gateway running" >>$log
   echo "Gateway count=" $gatecount
   echo "Gateway count=" $gatecount >>$log
 
# If Gateway is running coun
if [ $gatecount -eq 2 ]
then
   status=1
   echo "Gateway is running ...abort"
else
   echo "Gateway is not running ... continue"
   echo "Gateway is not running ... continue" >>$log
 
   start_ns >>$log
   if test $? -ne 0 ; then
      status=1
      echo "`hostname ` start_ns failed: `date `" >>$log
      echo " " >>$log
 
   else
      echo "start_ns success" >>$log
   fi
   echo "status = $status"  >>$log
fi
exit $status
