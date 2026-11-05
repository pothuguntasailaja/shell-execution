#!/bin/bash


USER_ID=$(id -u)

if [ $USER_ID -ne 0 ]; then
   echo "please run this script as root privilege"
   exit 1
fi

VALIDATE(){
if [ $1 -ne 0 ]; then
   echo "$2 installation is FAILURE...."
   exit 1
else
    echo "$2 installation is SUCCESS......"   
fi    
}


dnf install mysqlll -y
VALIDATE $? "MYSQL"

dnf install nginx -y
VALIDATE $? "NGINX"