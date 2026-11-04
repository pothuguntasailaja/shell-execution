#!/bin/bash


USER_ID=$(id -u) # edhi root privilege ayithe ne

if [ $USER_ID -ne 0 ]; then
   echo "please run this script as root privilege"
   exit 1
fi


VALIDATE(){
if [ $? -ne 0 ]; then
    echo "$2 installation is FAILURE...."
    exit 1
    else
    echo "$2 installation is SUCCESS...."
fi
}

dnf install mysql -y 
VALIDATE $? "MYSQL"


dnf install nginx -y
VALIDATE $? "NGINX"
