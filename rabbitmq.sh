source ./common.sh
check_root
app_name=rabbitmq
echo "Please eneter rabbitmq user pwd: "
read -s RABBITMQ_PWD
cp $script_dir/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo | tee -a $LOG_FILE
VALIDATE $? "Copying rabbitmq.repo file"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing RabbitMQ Server"

systemctl enable rabbitmq-server &>>$LOG_FILE
systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Starting RabbitMQ Server"

rabbitmqctl add_user roboshop $RABBITMQ_PWD &>>$LOG_FILE
VALIDATE $? "Adding RabbitMQ User"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "Setting permissions to RabbitMQ User"

print_time