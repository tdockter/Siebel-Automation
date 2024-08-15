#!/bin/bash
###########################################################################
# Changes: Updated for IP16
# Added Additional Logging
# Test backup creation
# Remove Anonymous User Profile
# Changes: Added link to RegSS_WatchDog_Mwrpcss.sh
# This will check for latent items and shutdown if still live
 
###########################################################################
# Runtime environment variables
###########################################################################
 
echo
. /home/sadmin/.bash_profile
srfbackup=siebel_sia.srf.$(date +%Y)$(date +%m)$(date +%d)$(date +%H)$(date +%M)
log=/siebeladmin/sadmin/log/stopserver.log
status=0
 
###########################################################################
# Pre Processing
###########################################################################
echo "`hostname ` Siebel shutdown started: `date `" >$log
 
###########################################################################
# Main Processing
###########################################################################
cd /siebelapp/16.0.0.0.0/ses/siebsrvr >>$log
echo "change directory to /siebelapp/16.0.0.0.0/ses/siebsrvr">>$log
echo "set environment variables">>$log
. ./siebenv.sh >>$log
 
	echo "ps -ef|grep siebel |wc -l">>$log
    ps -ef|grep siebel|wc -l>>$log
 
echo "begin stop server">>$log
stop_server all >>$log
if test $? -ne 0 ; then
   status=1
   echo "`hostname ` stop_server all failed: `date `" >>$log
   echo " " >>$log
else
 
	#check for number of siebel processes
	echo "ps -ef|grep siebel |wc -l">>$log
	ps -ef|grep siebel|wc -l>>$log
 
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
 
	#Backup of SRF
	srfLocation=/siebelapp/16.0.0.0.0/ses/siebsrvr/objects/enu/
	cd /siebelapp/16.0.0.0.0/ses/siebsrvr/objects/enu >>$log
	 
	cp siebel_sia.srf $srfbackup >>$log
	echo $srfbackup >>$log
	 
	cd /siebelapp/16.0.0.0.0/ses/siebsrvr >>$log
	 
	#Stop MiddleWare Pieces
	 
	echo "stop watchdog mwadm">>$log
	mwadm stop >>$log
	if test $? -ne 0 ; then
	   status=1
	   echo "`hostname ` mwadm stop failed: `date `" >>$log
	   echo " " >>$log
	fi
	#remove Anonymous Users from User SPF location
	cd /siebeluserspf/ip16
	if  test -e ADSBL*;then
		ls -lrt ADSBL*>>$log
		rm -f ADSBL*.spf
    fi
 
	#verify ADSBL has been removed
    if ! test -e ADSBL*
    then
                echo "ADSBL does not exist">>$log
    fi
    #Test Sadmin
    if test -e SADMIN*Sales*;then
		ls -lrt SADMIN*Sales*>>$log
		rm -f SADMIN*Sales*
    fi
    #verify SADMIN has been removed
    if ! test -e SADMIN*Sales*
    then
		echo "Sadmin Sales does not exist">>$log
    fi
 
	#Remove latent Watchdog, Regss, mwrpcss
	sleep 10
	cd /siebeladmin/sadmin
	./RegSS_WatchDog_Mwrpcss.sh
fi
 
###########################################################################
# Post Processing
###########################################################################
# Test if graceful shutdown failed ... then force shutdown
# Validate all components down
##########################
 
ps -ef|grep sadmin >>$log
 
if test $status -ne 0 ; then
   echo " ">>$log
   echo "SHUTDOWN failure">>$log
   echo " ">>$log
 
   cd /siebelapp/16.0.0.0.0/ses/siebsrvr >>$log
   echo "change directory to /siebelapp/16.0.0.0.0/ses/siebsrvr">>$log
   echo "set environment variables">>$log
   . ./siebenv.sh >>$log
   stop_server all >>$log
 
   siebmtshmw=$(pidof siebmtshmw)
   echo  "kill siebmtshmw process $siebmtshmw " >>$log
   kill -9 $siebmtshmw
 
   siebproc=$(pidof siebproc)
   echo "kill siebproc $siebproc " >>$log
   kill -9 $siebproc
 
   siebprocmw=$(pidof siebprocmw)
   echo "kill siebprocmw $siebprocmw " >>$log
   kill -9 $siebprocmw
 
   siebsvc=$(pidof siebsvc)
   echo "kill siebsvc $siebsvc " >>$log
   kill -9 $siebsvc
 
   siebsess=$(pidof siebsess)
   echo "kill siebsess process $siebsess " >>$log
   kill -9 $siebsess
 
   siebmtsh=$(pidof siebmtsh)
   echo "kill siebmtsh process $siebmtsh " >>$log
   kill -9 $siebmtsh
 
   sleep 10
   cd /siebeladmin/sadmin
   ./RegSS_WatchDog_Mwrpcss.sh
  
   echo " ">>$log
   sleep 40
   siebmtshmw=$(pidof siebmtshmw)
   siebproc=$(pidof siebproc)
   siebprocmw=$(pidof siebprocmw)
   siebsvc=$(pidof siebsvc)
   siebsess=$(pidof siebsess)
   siebmtsh=$(pidof siebmtsh)
 
   ps -ef|grep sadmin >>$log
 
##########################
# Test all above items (6) are NULL... no processes should be running.
##########################
   echo " ">>$log
                echo  "log file should have 6 Null statements or the 2nd attempt to shutdown failed" >>$log
   echo " ">>$log
 
	t=0
	if  [[ -z $siebmtshmw ]]; then
	   echo "NULL siebmtshmw">>$log
	   (( t=$t + 1 ))
	fi
	if [[ -z $siebproc ]]; then
	   echo "NULL siebproc">>$log
	   (( t=$t + 1 ))
	fi
	if [[ -z $siebprocmw ]]; then
	   echo "NULL siebprocmw">>$log
	   (( t=$t + 1 ))
	fi
	if [[ -z $siebsvc ]]; then
	   echo "NULL siebsvc">>$log
	   (( t=$t + 1 ))
	fi
	if [[ -z $siebsess ]]; then
	   echo "NULL siebsess">>$log
	   (( t=$t + 1 ))
	fi
	if [[ -z $siebmtsh ]]; then
	   echo "NULL siebmtsh">>$log
	   (( t=$t + 1 ))
	fi

	# Failed First Status Exits Here
	# after attempt to kill all Siebel related Process

	if [[ $t -lt 6 ]]; then
	   status=1
	else
	   status=0
	fi
	echo "status=$status" >>$log
	exit $status
 
else
   echo "`hostname ` Siebel shutdown finished: `date `" >>$log
   echo " " >>$log
   exit 0
fi
###########################################################################
# END OF PROGRAM
###########################################################################
 
