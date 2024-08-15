
#!/bin/bash
######################################################################
# NAME: NewService.sh
# PURPOSE: TO SPEED AND SIMPLIFY THE SADMIN PASSWORD CHANGE PROCESS
######################################################################
 
# RUNTIME ENVIRONMENT VARIABLE DECLARATION
  . /home/sadmin/.bash_profile
  log=/siebeladmin/sadmin/Sadmin_Password/NewService.log
######################################################################
SiebsrvrName=da01
Enterprise=SBA_DEV
GatewayHostName=da01
 
echo
echo VARIABLE SUMMARY
echo Server: $SiebsrvrName
echo Enterprise: $Enterprise
echo Gateway: $GatewayHostName
 
#loop to allow password validation
correct="n"
until [ $correct == "y" ]
do
     echo "What is the new sadmin password"
     read NewPassword
 
     echo
     echo ""
     echo "Is this the correct password: (y/n)"
     read correct
done
# add the option to exit without continuation....
 
# STATIC VARIABLES
  GatewayPort=(your port number)
  SiebsrvrLoc='/siebelapp/16.0.0.0.0/ses/siebsrvr'
  DATE_TIME=$(date +%Y%m%d_%H%M%S)
######################################################################
#Rename old service
  cd /siebelapp/16.0.0.0.0/ses/siebsrvr/sys
  mv svc.siebsrvr.$Enterprise:$SiebsrvrName "$DATE_TIMEsvc".siebsrvr.$Enterprise:$SiebsrvrName
  rm osdf*
  cd ..
  . ./siebenv.sh
  cd bin
 
# Create New Service with updated password
siebctl -r $SiebsrvrLoc -S siebsrvr -i $Enterprise:$SiebsrvrName -a -g "-g $GatewayHostName:$GatewayPort -e $Enterprise -s $SiebsrvrName -u sadmin" -e $NewPassword -L ENU
 
exit $?
