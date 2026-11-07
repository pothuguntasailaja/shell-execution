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


dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "DISABLE NGINX" 

dnf module enable nginx:1.24 -y  &>>$LOG_FILE
VALIDATE $? "ENABLE NGINX" 

dnf install nginx -y  &>>$LOG_FILE
VALIDATE $? "INSTALL NGINX" 

systemctl enable nginx 
VALIDATE $? "ENABLE NGINX" 

systemctl start nginx 
VALIDATE $? "START NGINX" 

rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
VALIDATE $? "REMOVE THE OLD CODE" 

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "DOWNLOAD THE CODE" 

cd /usr/share/nginx/html  &>>$LOG_FILE
VALIDATE $? "CHANGE THE DIRECTORY" 

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "UNZIP THE CODE" 

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "copying NGINX" 

systemctl restart nginx 
VALIDATE $? "restart nginx 