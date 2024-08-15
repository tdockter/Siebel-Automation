#!/bin/bash
############################################
#
# Program: RemoveOldInstallationLogs
# Removes Installation Log files Older than 30 days
# and Records the names of the removed files in a separate log file
# Part of a Tidal Job which will be run monthly
# This script will exist on each Linux Siebel machine in the /siebeladmin/sadmin directory
# and operate only on the log files that are within the subdirectories ID'd
#
#####################################################

 
##### VARIABLE DEFINITIONS #####
 
# LOG FILE LOCATIONS
  LOG_PATH="/siebeladmin/sadmin/log/"
  LOG_PATH2="/siebelapp/16.0.0.0.0/ses/siebsrvr/log/"
#remove callstack, core, and fdr files 30 days and older
  LOG_PATH3="/siebelapp/16.0.0.0.0/ses/siebsrvr/bin"
 
# DATE DECLARATION
  d1="$(date +%Y%m%d_%H%M)"
 
# LOG OF LOGS REMOVED
  FileName="${LOG_PATH}Remove_Old_Logs${d1}.log"
 
# Identify and Delete FILES of Logs/Crashes OLDER THAN 30 DAYS
#SRF and Admin Related Log Files
  echo LOG_PATH="/siebeladmin/sadmin/log/">>$FileName
  ls -1 $LOG_PATH |wc -l >>$FileName
  find $LOG_PATH -mtime +30 -print >>$FileName
  find $LOG_PATH -mtime +30 -delete >>$FileName
  ls -1 $LOG_PATH |wc -l >>$FileName
 
#Application Related Log Files
  echo  LOG_PATH2="/siebelapp/16.0.0.0.0/ses/siebsrvr/log/">>$FileName
  ls -1 $LOG_PATH2 |wc -l >>$FileName
  find $LOG_PATH2 -mtime +30 -print >>$FileName
  find $LOG_PATH2 -mtime +30 -delete >>$FileName
  ls -1 $LOG_PATH2 |wc -l >>$FileName
 
#Crash Related: Core, Call Stack, *.fdr older than 30 days
  echo LOG_PATH3="/siebelapp/16.0.0.0.0/ses/siebsrvr/bin">>$FileName
  ls -1 $LOG_PATH3 |wc -l >>$FileName
  find $LOG_PATH3 -name *.fdr -mtime +30 -print >>$FileName
  find $LOG_PATH3 -name callstack* -mtime +30  -print >>$FileName
  find $LOG_PATH3 -name core.* -mtime +30  -print >>$FileName
  find $LOG_PATH3 -name *.fdr -mtime +30 -delete >>$FileName
  find $LOG_PATH3 -name callstack* -mtime +30  -delete >>$FileName
  find $LOG_PATH3 -name core.* -mtime +30  -delete >>$FileName
  ls -1 $LOG_PATH3 |wc -l >>$FileName
 
exit $?
 
