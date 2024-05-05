#!/bin/bash

source ./common.sh

check_root

echo "Please enter the root password for DB: "
read -s mysql_root_password

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "MySQL Server Installation"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling mysqld service"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting mysqld service"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting up root password"

mysql -h db.surya-devops.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "MySQL Root password is setup"
else
    echo -e "MySQL root password is already setup... $Y SKIPPING $N"
fi