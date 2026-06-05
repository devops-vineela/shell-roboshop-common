source ./common.sh
check_root
app_name=catalogue
app_setup
nodejs_setup
systemd_setup

cp $script_dir/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying MongoDB repository file"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB shell"

status=$(mongosh --host mongodb.daws-84s.bond  --eval 'db.getMongo().getDBNames(). indexOf("catalogue")') &>>$LOG_FILE
if [ $status -lt 0 ]
then
  mongosh --host mongodb.daws-84s.bond </app/db/master-data.js &>>$LOG_FILE
  VALIDATE $? "Loading data to MongoDB"
else
  echo -e "Data is already loaded... $Y SKIPPING $N"
fi

print_time


