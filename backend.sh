#!/bin/bash

source ./common.sh

check_root

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs version 20"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense
    VALIDATE $? "Adding expense user"
else
    echo -e "Expense user already added... $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Created /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading Backend code"

cd /app 
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracted (Unzipped) Backend Code in /app directory"

npm install &>>$LOGFILE
VALIDATE $? "Installing nodejs dependencies"

cp /home/ec2-user/proj-auto/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Creating backend.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloading daemon"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Start backend service"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enable backend service"


dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Install MySQL Client"

mysql -h db.surya-devops.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Loading Schema for MySQL Client"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting backend service"