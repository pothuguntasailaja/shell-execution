#!/bin/bash


USER_ID=$(id -u)

if [ $USER_ID -ne 0 ]; then
   echo "please run this script as root privilege"
   exit 1
fi

VALIDATE(){
if [ $? -ne 0 ]; then
   echo "MYSQL installation is FAILURE...."
   exit 1
else
    echo "MYSQL installation is SUCCESS......"   
fi    
}


dnf install mysql -y
VALIDATE $? "MYSQLLL"

dnf install nginx -y
VALIDATE $? "NGINX"