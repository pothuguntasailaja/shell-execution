#!/bin/bash


USER_ID=$(id -u) # edhi root privilege ayithe ne
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell-execution"
SCRIPT_NAME=$0
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"


if [ $USER_ID -ne 0 ]; then
   echo "please run this script as root privilege"
   exit 1
fi


VALIDATE(){
if [ $? -ne 0 ]; then
    echo -e  "$2 installation is  $R FAILURE.... $N"
    exit 1
    else
    echo -e "$2 installation is $G SUCCESS.... $N"
fi
}

dnf install mysql -y  &>>$LOG_FILE
VALIDATE $? "MYSQL"


dnf install nginx -y  &>>$LOG_FILE
VALIDATE $? "NGINX"
