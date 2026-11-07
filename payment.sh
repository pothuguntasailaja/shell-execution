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

dnf install python3 gcc python3-devel -y &>$LOG_FILE
VALIDATE $? "INSTALL PYTHON3"

id roboshop
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>$LOG_FILE
VALIDATE $? "INSTALL PYTHON3"
fi

mkdir /app  &>$LOG_FILE
VALIDATE $? "create app dir"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip   &>$LOG_FILE
VALIDATE $? "UNZIP THE CODE"

cd /app   &>$LOG_FILE
VALIDATE $? "CHANGE APP DIR"

rm -rf /app/*
VALIDATE $? "REMOVE OLD CODE"

unzip /tmp/payment.zip &>$LOG_FILE
VALIDATE $? "DOWNLOAD THE CODE"

cd /app 
VALIDATE $? "CHANGE APP DIR"

pip3 install -r requirements.txt &>$LOG_FILE
VALIDATE $? "INSTALL PIP3"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "COPYING THE SERVICE"

systemctl daemon-reload
VALIDATE $? "DAEMON RELOAD"

systemctl enable payment
VALIDATE $? "ENABLE PAYMENT"

systemctl start payment
VALIDATE $? "START PAYMENT" 