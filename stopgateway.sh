#!/bin/bash
###########################################################################
# Runtime environment variables
###########################################################################
. /home/sadmin/.bash_profile
log=/siebeladmin/sadmin/log/stopgateway.log
status=0
 
###########################################################################
# Pre Processing
###########################################################################
echo "`hostname ` Siebel Gateway started: `date `" >>$log
 
cd /siebelapp/16.0.0.0.0/ses/gtwysrvr >>$log
. ./siebenv.sh >>$log
 
stop_ns >>$log
if test $? -ne 0 ; then
   status=1
   echo "`hostname ` stop_ns failed: `date `" >>$log
   echo " " >>$log
else
   status=0
   echo "`hostname ` stop_ns succeeded: `date `" >>$log
   echo " " >>$log
fi
 
sleep 20
ps -ef|grep sadmin >>$log
exit $status
