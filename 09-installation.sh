#!/bin/bash


USER_ID=$(id -u) # edhi root privilege ayithe ne
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-execution"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER

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
