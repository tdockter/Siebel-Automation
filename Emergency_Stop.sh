#!/bin/bash
log=/siebeladmin/sadmin/log/emergencystop.log
 
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
