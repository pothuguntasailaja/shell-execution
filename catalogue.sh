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
MONGODB_HOST=mongodb.daws86s.de
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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "DISABLE NODEJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "ENABLE NODEJS"

dnf install nodejs -y &>>$LOG_FILE
 VALIDATE $? "INSTALL NODEJS"

 id roboshop
 if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
fi

mkdir -p /app 
VALIDATE $? "CREATE APP DIRECTORY"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE
VALIDATE $? "DOWNLOAD CODE"

cd /app 
VALIDATE $? "CHANGE APP DIRECTORY"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "UNZIP CODE"

cd /app
VALIDATE $? "CHANGE APP DIRECTORY" 

npm install  &>>$LOG_FILE
VALIDATE $? "INSTALL DEPENDENCIES"

cp $SCRIPT_NAME/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "COPYING THE SERVICE"

systemctl daemon-reload
VALIDATE $? "RELOAD"

systemctl enable catalogue 
VALIDATE $? "DISABLE CATALOGUE"

systemctl start catalogue
VALIDATE $? "START CATALOGUE"

cp /$SCRIPT_NAME/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "COPYING MONGODB SERVICE"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "INSTALL MONGODB"

mongosh --host  $MONGODB_HOST </app/db/master-data.js
VALIDATE $? "LOADING" 
