#!/bin/bash 

## Set variables 
AppName=mongo
TodayDate=`date +"%d/%b/%g %r"`
DateStamp=`date +%Y%m%d%H%M`
CurrentTime=`date +"%r"`
AppBinPath="/usr/bin"
ReplicaSet=`echo 'rs.status()' | $AppBinPath/mongo | egrep "set" | awk -F \" '{print $4}'` 
MongoHost=`hostname` 
LocalBackupPath="/var/backups/mongodb/dump"
LogFile="/tmp/$AppName-backup-$DateStamp_$CurrentTime.log"
IsOK=0
CmdStatus=""
BackupPath="/var/backups"
BackupFileName="`hostname`.$AppName.$DateStamp.tar"

## Check whether host is slave and in good state for backup 
for i in `echo "rs.status()" | $AppBinPath/mongo | egrep "name" | awk -F \" '{print $4}'| cut -f 1 -d :`;
  do IsMaster=`echo "db.isMaster()"| $AppBinPath/mongo --host $i | grep ismaster|awk -F ":" '{print $2}' | cut -f 1 -d ,`;
   TheState=`echo "rs.status()"| $AppBinPath/mongo --host $i | grep -i mystate | awk -F ":" '{print $2}' | cut -f 1 -d ,`;
  if [ $IsMaster == "false" -a $TheState -eq 2 ];
    then MongoHost=$i IsOK=1 echo "$CurrentTime: $MongoHost is slave and looks OK."
    break
  fi
done


## Exit if not good 
#if [ $IsOK -eq 0 ];
#  then echo "$CurrentTime: Error: Either $MongoHost is not slave or not in good state. Aborting Backup, Please check!" 
#  exit 1;
#fi

## Remove earlier backup 
sudo rm -rf $LocalBackupPath/*

## Start backup process 
echo "$CurrentTime: Starting Dump, executing $AppBinPath/mongodump --out $LocalBackupPath --host $MongoHost..." 
$AppBinPath/mongodump --out $LocalBackupPath --host $MongoHost
if [ $? -ne 0 ];
  then exit
fi


## tar it up
## Push to s3
sudo tar -czvf ${BackupPath}/${BackupFileName} ${LocalBackupPath}


s3cmd put ${BackupPath}/${BackupFileName} s3://backups.kwarter.com/`hostname |cut -d"." -f2`/${AppName}/

sudo rm -rf ${BackupPath}/${BackupFileName}
