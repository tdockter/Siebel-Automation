#!/bin/bash
###########################################################################
#
# Validates Siebel is not/running
# Starts application if not running.
# 
###########################################################################
# Runtime environment variables
###########################################################################
. /home/sadmin/.bash_profile
log=/siebeladmin/sadmin/log/startserver.log
status=0
 
###########################################################################
# Pre Processing
###########################################################################
echo "`hostname ` Siebel startup started: `date `" >>$log
 
###########################################################################
# Validate OSDF does not exist before attempting startup for DR purposes
###########################################################################
cd /siebelapp/16.0.0.0.0/ses/siebsrvr/sys >>$log
 
# IF osdf* FILE DOESN'T EXIST...
if [ -b osdf* ]
 
# THEN MAKE CORE FOLDER WITHIN
then                         
    echo " osdf file does not exist, no removal needed. " >>$log
 
# OTHERWISE REMOVE osdf* FILE
else
    rm osdf* >>$log
    echo " osdf file removed. " >>$log
fi
  
###########################################################################
# Main Processing
###########################################################################
cd /siebelapp/16.0.0.0.0/ses/siebsrvr >>$log
echo "set directory for environment variables">>$log
echo "set environment variables">>$log
. ./siebenv.sh >>$log
 
#additional logging
#echo "count sieble PID before starting">>$log
#echo "ps -ef|grep siebel |wc -l">>$log
SBLcount=`ps -ef|grep sadmin|wc -l`
echo "SBLcount=$SBLcount" >>$log
 
if [ $SBLcount -gt 20 ]
then
   status=1
   echo "Siebel is already running SBLcount">>$log
else
   start_server all >>$log
   if test $? -ne 0 ; then
      status=1
      echo "`hostname ` start_server all failed: `date `" >>$log
      echo " start failed" >>$log
   fi
fi

###########################################################################
# Post Processing
###########################################################################
if test $status -ne 0 ; then
   echo "error in startup" >>$log
   exit 1
else
   echo "`hostname ` Siebel startup finished: `date `" >>$log
   echo " " >>$log
   exit 0
fi
 
###########################################################################
 
