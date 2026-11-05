#!/bin/bash


USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


LOG_FOLDER="/var/log/shell-execution"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"


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

dnf list installed mysql  &>>$LOG_FILE
if [ $? -ne 0 ]; then
   dnf install mysql -y &>>$LOG_FILE
   VALIDATE $? "MYSQL"
else
    echo -e "MYSQL is already installed so, $Y SKIPPING..... $N"  
fi

dnf list installed nginx &>>$LOG_FILE
if [ $? -ne 0 ]; then
  dnf install nginx -y &>>$LOG_FILE
  VALIDATE $? "NGINX"
else
   echo -e "Nginx is already INSTALLED so, $Y SKIPPING...... $N"  
fi   