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
MYSQL_HOST=mysql.daws86s.de

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

dnf install maven -y &>$LOG_FILE
VALIDATE $? "INSTALL MAVEN"

id roboshop
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>$LOG_FILE
VALIDATE $? "CREATE SYSTEM USER"
fi

mkdir -p /app  &>$LOG_FILE
VALIDATE $? "CREATE APP DIR"


curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>$LOG_FILE
VALIDATE $? "DOWNLOAD THE CODE"

cd /app 
VALIDATE $? "CHANGE APP DIR"

rm -rf /app/*
VALIDATE $? "REMOVE THE OLD CODE"

unzip /tmp/shipping.zip &>$LOG_FILE
VALIDATE $? "UNZIP THE CODE"

cd /app 
VALIDATE $? "CHANGE APP DIR"

mvn clean package  &>$LOG_FILE
VALIDATE $? "BUILDING SHIIPING APP"

mv target/shipping-1.0.jar shipping.jar  &>$LOG_FILE
VALIDATE $? "COPYING THE FILE"

 cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
 VALIDATE $? "Copying the service"

systemctl daemon-reload
VALIDATE $? "daemon reload"

systemctl enable shipping 
VALIDATE $? "enable shipping"

systemctl start shipping
VALIDATE $? "start shipping"


dnf install mysql -y  &>$LOG_FILE
VALIDATE $? "install mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql  &>$LOG_FILE
VALIDATE $? "load the mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql  &>$LOG_FILE
VALIDATE $? "load the mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>$LOG_FILE
VALIDATE $? "load the mysql"

systemctl restart shipping
VALIDATE $? "RESTART THE SHIPPING"