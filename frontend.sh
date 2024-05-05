#!/bin/bash

source ./common.sh

check_root

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Install NGINX"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enable NGINX"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Start NGINX"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Remove default content from /usr/share/nginx/html/*"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Download Frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extract (unzip) frontend code in /usr/share/nginx/html"

cp /home/ec2-user/proj-auto/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Copying expense.conf to /etc/nginx/default.d/"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restart NGINX Service"