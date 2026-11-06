


#!/bin/bash

USER_ID=$(id -u) # get the user id of the current user
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
MONGODB_HOST=mongodb.daws86s.de
SCRIPT_DIR=$PWD


mkdir -p $LOGS_FOLDER
echo "Logs will be stored in $LOG_FILE" | tee -a $LOG_FILE
echo "Script started execution at $(date)" | tee -a $LOG_FILE

if [ $USER_ID -ne 0 ]; then 
    echo "please run this script as root privilege"
    exit 1 # failure exit status
fi


VALIDATE(){
    if [ $1 -ne 0 ]; then  # check the exit status of the last command
        echo -e "$2 installation is $R FAILURE.... $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 installation is $G SUCCESS.... $N" | tee -a $LOG_FILE
    fi
}


dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing Nodejs"


id roboshop
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Creating System User"
else
    echo -e "roboshop user already exists.... $Y SKIPPING $N"
fi


mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating Application Directory"


curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>$LOG_FILE
VALIDATE $? "Downloading Catalogue Artifact"

cd /app  &>>$LOG_FILE
VALIDATE $? "Changing Directory to /app"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "Removing Old Application Content"

unzip /tmp/catalogue.zip &>>$LOG_FILE 
VALIDATE $? "Extracting Catalogue Artifact"


cd /app  &>>$LOG_FILE
VALIDATE $? "Changing Directory to /app"

npm install &>>$LOG_FILE
VALIDATE $? "Installing Nodejs Dependencies"


cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
VALIDATE $? "Copying Catalogue Service File"


systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reloading Systemd Daemon"


systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "Enabling Catalogue Service"

systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "Starting Catalogue Service"

cp $SCRIPT_DIR/mongo.repo  /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "Copying MongoDB Repo File"


dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB Shell"


# "MongoDB Server and MongoDB Shell are different. MongoDB Server stores all the catalogue product information.
# MongoDB Shell is a command-line tool used to connect to the MongoDB Server and execute commands.
# We use mongosh to execute the master-data.js file and load product data into MongoDB."

INDEX=$(mongosh mongodb.daws86s.de --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -lt 0 ]; then
     mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
     VALIDATE $? "Loading Catalogue Products"
else
    echo -e "Catalogue Products already Loaded.... $Y SKIPPING $N"
fi

systemctl restart catalogue &>>$LOG_FILE
VALIDATE $? "Restarting Catalogue Service"



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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "DISABLE NODEJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "ENABLE NODEJS"

dnf install nodejs -y &>>$LOG_FILE
 VALIDATE $? "INSTALL NODEJS"

 id roboshop
 if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
fi

mkdir -p /app 
VALIDATE $? "CREATE APP DIRECTORY"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE
VALIDATE $? "DOWNLOAD CODE"

cd /app 
VALIDATE $? "CHANGE APP DIRECTORY"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "UNZIP CODE"

cd /app
VALIDATE $? "CHANGE APP DIRECTORY" 

npm install  &>>$LOG_FILE
VALIDATE $? "INSTALL DEPENDENCIES"

cp $SCRIPT_NAME/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "COPYING THE SERVICE"

systemctl daemon-reload
VALIDATE $? "RELOAD"

systemctl enable catalogue 
VALIDATE $? "DISABLE CATALOGUE"

systemctl start catalogue
VALIDATE $? "START CATALOGUE"

cp /$SCRIPT_NAME/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "COPYING MONGODB SERVICE"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "INSTALL MONGODB"

mongosh --host  $MONGODB_HOST </app/db/master-data.js
VALIDATE $? "LOADING" 