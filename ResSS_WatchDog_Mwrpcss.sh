#!/bin/bash
############################################
#             Detect orphan PID from shutdown
#             mwrpcss, watchdog, regss
#             Kill the above PID if necessary
#             This is part of Tidal Siebel MW Stop Job Group
############################################
. /home/sadmin/.bash_profile
log=/siebeladmin/sadmin/log/orphantest.log
status=0
############################################
DATE_TIME="$(date +%Y%m%d_%H%M%S)"
 
echo "Date Stamp $DATE_TIME" >$log
t=0
 
#Grab PID value of the 3 processes ... if running
m=$(pidof mwrpcss)
w=$(pidof watchdog)
r=$(pidof regss)
m=$((m+0))
w=$((w+0))
r=$((r+0))
if [ $m -eq 0 ]; then
    m=""
    t=$((t+1))
fi
if [ $w -eq 0 ]; then
    w=""
    t=$((t+1))
fi
if [ $r -eq 0 ]; then
    r=""
    t=$((t+1))
fi
echo
echo
echo
echo ${hostname}  >>$log
if [ $t -lt 3 ];then
    echo "run the following command" >>$log
    orphan="kill -9 $m $w $r"
    echo $orphan >>$log
    export orphan
    ${orphan}
else
    echo "no orphan processes" >>$log
fi
echo
echo
echo
 
exit $?
