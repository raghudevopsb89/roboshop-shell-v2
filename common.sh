log_file=/tmp/roboshop.log
hs="\e[33m >>>>>>>>>>>>>"
he="<<<<<<<<<<<<<<< \e[0m"

app_pre_reqs() {
  echo -e "${hs} Create Application User ${he}" | tee -a ${log_file}
  id appuser &>>${log_file}
  if [ $? -eq 1 ]; then
    useradd -r -s /bin/false appuser &>>${log_file}
  fi
  status_check

  echo -e "${hs} Copy SystemD Service file ${he}" | tee -a ${log_file}
  cp ${component_name}.service /etc/systemd/system/${component_name}.service &>>${log_file}
  status_check

  echo -e "${hs} Download Application Content ${he}" | tee -a ${log_file}
  curl -L -o /tmp/${component_name}.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/${component_name}.zip &>>${log_file}
  status_check

  echo -e "${hs} Create folder for application ${he}" | tee -a ${log_file}
  rm -rf /app &>>${log_file}
  mkdir -p /app &>>${log_file}
  status_check

  cd /app

  echo -e "${hs} Extract application content ${he}" | tee -a ${log_file}
  unzip /tmp/${component_name}.zip &>>${log_file}
  status_check
}

systemd_service() {
  schema_load

  echo -e "${hs} Apply permission for application folder  ${he}" | tee -a ${log_file}
  chown -R appuser:appuser /app &>>${log_file}
  chmod o-rwx /app -R &>>${log_file}
  status_check

  echo -e "${hs} Start Service ${he}" | tee -a ${log_file}
  systemctl daemon-reload &>>${log_file}
  systemctl enable ${component_name} &>>${log_file}
  systemctl restart ${component_name} &>>${log_file}
  status_check
}

nodejs_app() {
  app_pre_reqs

  echo -e "${hs} Install NodeJS ${he}" | tee -a ${log_file}
  curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - &>>${log_file}
  dnf install -y nodejs &>>${log_file}
  status_check

  echo -e "${hs} Download App Dependencies ${he}" | tee -a ${log_file}
  npm install --production &>>${log_file}
  status_check

  systemd_service
}

golang_app() {
  app_pre_reqs

  echo -e "${hs} Install GoLang & MySQL Client ${he}" | tee -a ${log_file}
  dnf install -y golang git &>>${log_file}
  status_check

  echo -e "${hs} Compile Application Code ${he}" | tee -a ${log_file}
  go mod tidy &>>${log_file}
  CGO_ENABLED=0 go build -o /app/${component_name} . &>>${log_file}
  status_check

  systemd_service
}

java_app() {
  app_pre_reqs

  echo -e "${hs} Install Java & Maven ${he}" | tee -a ${log_file}
  dnf install -y java-21-openjdk java-21-openjdk-devel maven &>>${log_file}
  status_check

  echo -e "${hs} Build Application Code ${he}" | tee -a ${log_file}
  mvn clean package -DskipTests &>>${log_file}
  cp target/${component_name}.jar /app/${component_name}.jar &>>${log_file}
  status_check

  systemd_service
}

python_app() {
  app_pre_reqs

  echo -e "${hs} Install Python & Pip ${he}" | tee -a ${log_file}
  dnf install -y python3 python3-pip &>>${log_file}
  status_check

  echo -e "${hs} Install App Dependencies ${he}" | tee -a ${log_file}
  pip3 install -r requirements.txt ${extra_pip_packages} &>>${log_file}
  status_check

  systemd_service
}

status_check() {
  if [ $? -eq 0 ]; then
    echo -e "\e[32m SUCCESS \e[0m"
  else
    echo -e "\e[31m FAILURE \e[0m"
  fi
}

schema_load() {
  if [ "$schema_load" = "true" ]; then
    if [ "$schema_type" = "mysql" ]; then
      echo -e "${hs} Install MySQL Client ${he}" | tee -a ${log_file}
      dnf install mysql8.4 -y &>>${log_file}
      status_check

      echo -e "${hs} Load Schema, App User, & Master Data ${he}" | tee -a ${log_file}
      for file in $schema_files; do
        mysql -h mysql-dev.rdevopsb89.online -u root -pRoboShop@1 < db/$file &>>${log_file}
      done
      status_check
    fi
  fi
}

