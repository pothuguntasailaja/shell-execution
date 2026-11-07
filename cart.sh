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

dnf module disable nodejs -y  &>>$LOG_FILE
VALIDATE $? "DISABLE NODEJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "ENABLE NODEJS"

dnf install nodejs -y  &>>$LOG_FILE
VALIDATE $? "INSTALL NODEJS"

id roboshop
if [$? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOG_FILE
VALIDATE $? "CREATE USER"
fi

mkdir -p /app  &>>$LOG_FILE
VALIDATE $? "CREATE APP DIR"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip  &>>$LOG_FILE
VALIDATE $? "DOWNLOAD THE CODE"

cd /app  
VALIDATE $? "CHANGE APP DIR"

rm -rf /app/*
VALIDATE $? "REMOVE THE OLD CODE"

unzip /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "UNZIP THE CODE"

cd /app 
VALIDATE $? "CHANGE THE APP DIRECTORY"

npm install  &>>$LOG_FILE
VALIDATE $? "INSTALL DEPENDENCIES"


cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "COPY THE SERVICES"

systemctl daemon-reload
VALIDATE $? "DAEMON RELOAD"

systemctl enable cart 
VALIDATE $? "ENABLE CART"

systemctl start cart
VALIDATE $? "START CART"