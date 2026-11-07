#!/bin/bash


USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


LOG_FOLDER="/var/log/shell-execution"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOG_FOLDER

if [ $USER_ID -ne 0 ]; then
   echo "please run this script as root privilege"
   exit 1
fi

VALIDATE(){
if [ $1 -ne 0 ]; then
   echo -e "$2 installation is $R FAILURE.... $N"
   exit 1
else
    echo -e "$2 installation is $G SUCCESS......$N"   
fi    
}


cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "COPYING MONGO REPOS"

dnf install mongodb-org -y  &>>$LOG_FILE
VALIDATE $? "INSTALL MONGODB"


systemctl enable mongod  &>>$LOG_FILE
VALIDATE $? "ENABLE MONGODB"

systemctl start mongod  &>>$LOG_FILE
VALIDATE $? "START MONGODB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? 'Allowing Remote Connections to Mongodb'

systemctl restart mongod
VALIDATE $? 'Restart Mongodb'
