#!/bin/bash

USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


LOG_FOLDER="/var/log/shell-execution"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_NAME=$PWD
MONGODB_HOST=mongodb.daws86s.de


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



dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "DISABLE NODEJS"


dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "ENABLE NODEJS"


dnf install nodejs -y
VALIDATE $? "INSTALL NODEJS"

id roboshop
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "CREATE SYSTEM USER"
fi

mkdir -p /app 
VALIDATE $? "CREATING APP DIRECTORY"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "DOWNLOAD THE CODE"

cd /app 
VALIDATE $? "CHANGE APP DIRECTORY"

rm -rf /app/*
VALIDATE $? "remove old code"

unzip /tmp/catalogue.zip
VALIDATE $? "UNZIP THE CODE"

cd /app 
VALIDATE $? "CHANGE APP DIRECTORY"

npm install 
VALIDATE $? "INSTALL DEPENDENCIES"

cp $SCRIPT_NAME/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "COPYING CATALOGUE SERVICE"

systemctl daemon-reload
VALIDATE $? "DAEMON RELOAD"

systemctl enable catalogue
VALIDATE $? "ENABLE CATALOGUE"

systemctl start catalogue
VALIDATE $? "START CATALOGUE"

cp $SCRIPT_NAME/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "COPYING MONGODB SERVICES"

dnf install mongodb-mongosh -y
VALIDATE $? "INSTALL MONGODB"

mongosh --host MONGODB-SERVER-IPADDRESS </app/db/master-data.js
VALIDATE $? "LOADING THE PRODUCTS"