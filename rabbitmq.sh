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

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "COPYING RABBITMQ REPO"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "INSTALL RABBITMQ"

systemctl enable rabbitmq-server
VALIDATE $? "ENABLE RABBITMQ"

systemctl start rabbitmq-server
VALIDATE $? "START RABBITMQ"

rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "CREATE USER AND SETTING PERMISIONS"