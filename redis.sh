source ./common.sh
check_root
app_name=redis
dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "disabling redis module"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "enabling redis:7 module"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "allowing remote access to redis"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "enabling redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "starting redis"

print_time