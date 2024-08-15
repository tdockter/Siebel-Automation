#!/bin/bash
###########################################################################
# description: SiebelSRF application installation scripts
# use of tar.gz on a nexus repository for archive storage 
#ARTIFACT_VERSION=$2 #Ghost-780914-20180208-100
ARTIFACT_VERSION=$1
 
#automate Region variable to sync script
hostname=$(hostname)
if [ $hostname == 'da01' ] || [ $hostname == 'da02' ]
   then
                Region='Development'
elif [ $hostname == 'qia01' ] || [ $hostname == 'qia02' ]
   then
                Region='Integration'
elif [ $hostname == 'qua01' ] || [ $hostname == 'qua02' ]
   then
                Region='UAT'
elif [ $hostname == 'pa01' ] || [ $hostname == 'pa02' ] || [ $hostname == 'pmk01' ]
   then
                Region='Production'
fi
 
APPLICATION_NAME="SiebelSRF"
FILE_EXTN="tar.gz"
ARTIFACT_PATH="/siebel/${APPLICATION_NAME}"
INSTALLATION_PATH="/siebeladmin/sadmin/temp"
BINARY_PATH="/siebelapp/16.0.0.0.0/ses/siebsrvr/objects/enu
APP_PATH="/siebelapp/16.0.0.0.0/ses"
BINARY_NAME="siebel_sia.srf"
DATE_TIME="$(date +%Y%m%d_%H%M%S)"
LOG_PATH="/siebeladmin/sadmin/log"
INSTALLATION_LOG="${LOG_PATH}/${APPLICATION_NAME}_Installation_$DATE_TIME.log"
INSTALLATION_LOG1="${LOG_PATH}/${APPLICATION_NAME}_Installation1_$DATE_TIME.log"
INSTALLATION_TEMP="${LOG_PATH}/fileInstallation_TEMP.log"
NEXUS_URL="https://nexus.*****.com/nexus/repository/siebel-releases/${ARTIFACT_PATH}/${ARTIFACT_VERSION}/${APPLICATION_NAME}-${ARTIFACT_VERSION}.${FILE_EXTN}"
 
 
#install(){
# DUPLICATE VARIABLES ... Used to create 2 different log files and contents for company automated splunk process
arr1=(`echo $ARTIFACT_VERSION | tr '-' ' '`)
ReleaseArr=(`echo ${arr1[0]} | tr '_' ' '`)
arr=(`echo $ARTIFACT_VERSION | tr '-' ' '`)
 
 
 
d1="$(date +%Y%m%d_%H%M%S)"
echo "ApplicationName=\"Siebel\" Region=\"$Region\" LogLevel=\"Info\" Release=\"${ReleaseArr[0]}\" VersionNumber=\"${ReleaseArr[1]}\" CMR=\"${arr1[1]}\" Message=\"Deployment Started\" Date=\"$d1\"" >> $INSTALLATION_LOG1
echo  "`date` Starting $APPLICATION_NAME application installation process : $APPLICATION_NAME with artifact version: $ARTIFACT_VERSION " >> $INSTALLATION_TEMP
 
	pwd  >> $INSTALLATION_TEMP
	pushd . >> $INSTALLATION_TEMP

		#sends count of siebel processes to log file
		echo "Count Siebel before shutdown" >>$INSTALLATION_TEMP
		echo "ps -ef|grep siebel |wc -l">>$INSTALLATION_TEMP
		ps -ef|grep siebel|wc -l>>$INSTALLATION_TEMP

		#determine number of rpss items
		echo "ps -ef|grep regss |wc -l">>$INSTALLATION_LOG
		ps -ef|grep regss |wc -l>>$INSTALLATION_LOG

		#determine number of mwrpcss items
		echo "ps -ef|grep mwrpcss |wc -l">>$INSTALLATION_LOG
		ps -ef|grep mwrpcss|wc -l>>$INSTALLATION_LOG
 
	# STOP SIEBEL SERVER ONLY
	# ADDING && BELOW TO ENSURE THIS SERVER STOP IS COMPLETED PRIOR TO MOVING TO NEXT COMMAND AND COMMENTING OUT THE SLEEP COMMAND FOR TESTING
	echo "BEGIN STOP APPLICATION">>$INSTALLATION_TEMP
/siebeladmin/sadmin/stopserveronly.sh >>$INSTALLATION_TEMP
	echo "STOP application completed">>$INSTALLATION_TEMP
	echo "Region: $Region" >> $INSTALLATION_TEMP
 
 
	# NAVIGATE TO "/siebel/temp" FOLDER
	cd $INSTALLATION_PATH >> $INSTALLATION_TEMP
	echo "`date` Changing directory to $INSTALLATION_PATH to start application $APPLICATION_NAME installation process..." >> $INSTALLATION_TEMP
 
	# GET NEXUS URL AND LOG ALL ERRORS IN INSTALLATION TEMP LOG FILE
	#wget $NEXUS_URL >> $INSTALLATION_TEMP 2>&1
	wget $NEXUS_URL --no-check-certificate
 
	if [ -f $APPLICATION_NAME-$ARTIFACT_VERSION.$FILE_EXTN ]; then

			echo "`date` Downloaded the installation file ${APPLICATION_NAME}-${ARTIFACT_VERSION}.${FILE_EXTN} successfully." >> $INSTALLATION_TEMP


			echo "`date` ${APPLICATION_NAME} application : ${APPLICATION_NAME}-${ARTIFACT_VERSION}.${FILE_EXTN} installed sucessfully."

	else
			echo "`date` File not found.FAILED to download the installation file ${APPLICATION_NAME}-${ARTIFACT_VERSION}.${FILE_EXTN}." >> $INSTALLATION_TEMP

								   
	#        return;
									exit 1
	fi
 
rm $BINARY_PATH/$BINARY_NAME >> $INSTALLATION_TEMP
 
#tar -xvf $APPLICATION_NAME-$ARTIFACT_VERSION.$FILE_EXTN >> $INSTALLATION_TEMP
tar -xvf $APPLICATION_NAME-$ARTIFACT_VERSION.$FILE_EXTN

pwd  >> $INSTALLATION_TEMP

cd input >> $INSTALLATION_TEMP
 
cp -r $BINARY_NAME $BINARY_PATH >> $INSTALLATION_TEMP
rm -rf $BINARY_NAME >> $INSTALLATION_TEMP
 
#sends count of siebel processes to log file                                                                                                                        
echo "Count Siebel before startup" >>$INSTALLATION_TEMP
echo "ps -ef|grep siebel |wc -l">>$INSTALLATION_TEMP
ps -ef|grep siebel|wc -l>>$INSTALLATION_TEMP
 
 
# START THE SEIBEL SERVER ONLY
echo "Start Application Process">>$INSTALLATION_TEMP
/siebeladmin/sadmin/startserveronly.sh >> $INSTALLATION_TEMP
echo "Start Application Process Completed">>$INSTALLATION_TEMP
 
# REMOVE "input" RECURSIVELY WITHOUT PROMPT

pwd  >> $INSTALLATION_TEMP
rm -rf srf*>> $INSTALLATION_TEMP
rm -rf $INSTALLATION_PATH/*>> $INSTALLATION_TEMP

 
# POP IS USED TO "POP" BACK A DIRECTORY
popd >> $INSTALLATION_TEMP
               
 
cp -r /siebelapp/16.0.0.0.0/ses/siebsrvr/objects/enu/siebel_sia.srf.* /siebelapp/16.0.0.0.0/ses/siebsrvr/objects/enu/backup/
rm -rf /siebelapp/16.0.0.0.0/ses/siebsrvr/objects/enu/siebel_sia.srf.*
echo  "`date` Deploy completed Region: $Region Release: ${arr[0]} CMR: ${arr[1]}" >> $INSTALLATION_TEMP
 
d2="$(date +%Y%m%d_%H%M%S)"
 
echo "ApplicationName=\"Siebel\" Region=\"$Region\" LogLevel=\"Info\" Release=\"${ReleaseArr[0]}\" VersionNumber=\"${ReleaseArr[1]}\" CMR=\"${arr1[1]}\" Message=\"Deployment Completed\" Date=\"$d2\"" >> $INSTALLATION_LOG1
cat $INSTALLATION_TEMP
cat $INSTALLATION_TEMP > $INSTALLATION_LOG
rm -rf $INSTALLATION_TEMP
 
#remove tar file
cd /siebeladmin/sadmin
rm -f *.tar.gz
echo "removed tar file" >> $INSTALLATION_TEMP
 
#sleep 60 secs and then report the number of siebel processes. If siebel is completely running somewhere 30+; If Siebel is not running <10
echo "60s pause" >>$INSTALLATION_LOG
sleep 60s
echo "Count Siebel end of script" >>$INSTALLATION_LOG
echo "ps -ef|grep siebel |wc -l">>$INSTALLATION_LOG
ps -ef|grep siebel|wc -l>>$INSTALLATION_LOG

#determine number of rpss items
echo "ps -ef|grep regss |wc -l">>$INSTALLATION_LOG
ps -ef|grep regss |wc -l>>$INSTALLATION_LOG

#determine number of mwrpcss items
echo "ps -ef|grep mwrpcss |wc -l">>$INSTALLATION_LOG
ps -ef|grep mwrpcss|wc -l>>$INSTALLATION_LOG
echo "If either of these last 2 numbers >2, cleanup is probably necessary">>$INSTALLATION_LOG

exit $?
