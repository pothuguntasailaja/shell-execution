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
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATE $? "CREATE SYSTEM USER"
fi

mkdir -p /app  &>>$LOG_FILE
VALIDATE $? "CREATE APP DIR"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE
VALIDATE $? "DOWNLOAD THE CODE "

cd /app  &>>$LOG_FILE
VALIDATE $? "CHANGE APP DIR"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "remove old code"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "DOWNLOAD THE CODE IN TEMP DIR "

cd /app  &>>$LOG_FILE
VALIDATE $? "CHANGE APP DIR"

npm install  &>>$LOG_FILE
VALIDATE $? "INSTALL DEPENDENCIES"

cp $SCRIPT_DIR/catalogue.service  /etc/systemd/system/catalogue.service &>>$LOG_FILE
VALIDATE $? "copy the service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemmon reload"

systemctl enable catalogue  &>>$LOG_FILE
VALIDATE $? "enable catalogue"

systemctl start catalogue
VALIDATE $? "start catalogue"

cp $SCRIPT_DIR/mongo.repo  /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "COPYING THE MONGO SERVICES"

dnf install mongodb-mongosh -y  &>>$LOG_FILE
VALIDATE $? "INSTALL MONGODB"

mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "LOAD THE PRODUCTS" 