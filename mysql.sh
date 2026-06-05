source ./common.sh
app_name=mysql
echo "enter MySQL root password: "

read -s MYSQL_ROOT_PASSWORD

check_root

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting MySQL Server"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD
VALIDATE $? "Setting MySQL root password"

print_time
