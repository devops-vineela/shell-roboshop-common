#!/bin/bash
START_TIME=$(date +%s)
userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 |cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
mkdir -p $LOGS_FOLDER
script_dir=$PWD

# checks the user has root priviliges or not
check_root(){
if [ $userid -ne 0 ]
then 
  echo -e "$R Error:: you should run this script with root access $N" | tee -a $LOG_FILE
  exit 1
else
  echo -e "$G you are running with root access $N" | tee -a $LOG_FILE
fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
      echo  -e "$2 is  $R FAILURE $N" | tee -a $LOG_FILE
      exit 1
    else
      echo -e "$2 is $G SUCCESS $N" |tee -a $LOG_FILE
    fi
}

print_time(){
  END_TIME=$(date +%s)
  EXECUTION_TIME=$(($END_TIME - $START_TIME))
  echo -e "Total execution time: $EXECUTION_TIME seconds" | tee -a $LOG_FILE
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling nodejs module"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling nodejs 20 module"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? " Installing nodejs"

    npm install &>>$LOG_FILE
    VALIDATE $? "Installing Dependencies"
}

app_setup(){
 id roboshop
    if [ $? -ne 0 ]
    then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "creating system roboshop user"
    else
    echo -e "roboshop User already created....$Y SKIPPING $N" | tee -a $LOG_FILE
    fi

    mkdir -p /app 
    VALIDATE $? "creating app directory"


    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "downloading $app_name code"

    cd /app
    rm -rf /app/*
    unzip /tmp/$app_name.zip
    VALIDATE $? "Unzipping $app_name code"
}

systemd_setup(){
    cp $script_dir/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "copying $app_name systemd service file"

    systemctl daemon-reload &>>$LOG_FILE
    VALIDATE $? "reloading systemd daemon"

    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "enabling $app_name service"

    systemctl start $app_name &>>$LOG_FILE
    VALIDATE $? "starting $app_name service"
}

maven_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing maven"

    mvn clean package &>>$LOG_FILE
    VALIDATE $? "building shipping code"

    mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    VALIDATE $? "Renaming shipping jar file"
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Installing Python3 and dependencies"

    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing payment dependencies"
}
