source ./common.sh
echo "please enter mysql root password:"
read -s MYSQL_ROOT_PASSWORD
check_root
app_name=shipping
app_setup
maven_setup
systemd_setup

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing mysql client"

mysql -h mysql.daws-84s.bond -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql
mysql -h mysql.daws-84s.bond -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql 
mysql -h mysql.daws-84s.bond -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql
VALIDATE $? "Loading shipping schema and data in mysql"

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restarting shipping service"

print_time


