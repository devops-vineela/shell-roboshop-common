source ./common.sh
check_root
app_name=frontend

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "disabling nginx module"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "enabling nginx:1.24 module"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx &>>$LOG_FILE
VALIDATE $? "starting nginx"
rm -rf /usr/share/nginx/html/* 
VALIDATE $? "removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Unzipping frontend code"

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "removing nginx default configuration"

cp $script_dir/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying nginx configuration"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarting nginx"

print_time