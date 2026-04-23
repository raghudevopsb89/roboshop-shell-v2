log_file=/tmp/roboshop.log
hs="\e[33m >>>>>>>>>>>>>"
he="<<<<<<<<<<<<<<< \e[0m"

app_pre_reqs() {
  echo -e "${hs} Create Application User ${he}" | tee -a ${log_file}
  useradd -r -s /bin/false appuser &>>${log_file}
  echo $?

  echo -e "${hs} Copy SystemD Service file ${he}" | tee -a ${log_file}
  cp ${component_name}.service /etc/systemd/system/${component_name}.service &>>${log_file}
  echo $?

  echo -e "${hs} Download Application Content ${he}" | tee -a ${log_file}
  curl -L -o /tmp/${component_name}.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/${component_name}.zip &>>${log_file}
  echo $?

  echo -e "${hs} Create folder for application ${he}" | tee -a ${log_file}
  rm -rf /app &>>${log_file}
  mkdir -p /app &>>${log_file}
  echo $?

  cd /app

  echo -e "${hs} Extract application content ${he}" | tee -a ${log_file}
  unzip /tmp/${component_name}.zip &>>${log_file}
  echo $?
}

systemd_service() {
  echo -e "${hs} Apply permission for application folder  ${he}" | tee -a ${log_file}
  chown -R appuser:appuser /app &>>${log_file}
  chmod o-rwx /app -R &>>${log_file}
  echo $?

  echo -e "${hs} Start Service ${he}" | tee -a ${log_file}
  systemctl daemon-reload &>>${log_file}
  systemctl enable ${component_name} &>>${log_file}
  systemctl restart ${component_name} &>>${log_file}
  echo $?
}

nodejs_app() {
  app_pre_reqs

  echo -e "${hs} Install NodeJS ${he}" | tee -a ${log_file}
  curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - &>>${log_file}
  dnf install -y nodejs &>>${log_file}
  echo $?

  echo -e "${hs} Download App Dependencies ${he}" | tee -a ${log_file}
  npm install --production &>>${log_file}
  echo $?

  systemd_service
}

golang_app() {
  app_pre_reqs

  echo -e "${hs} Install GoLang & MySQL Client ${he}" | tee -a ${log_file}
  dnf install -y golang git &>>${log_file}
  echo $?

  echo -e "${hs} Compile Application Code ${he}" | tee -a ${log_file}
  go mod tidy &>>${log_file}
  CGO_ENABLED=0 go build -o /app/${component_name} . &>>${log_file}
  echo $?

  systemd_service
}

status_check() {
  if [ $? -eq 0 ]; then
    echo -e "\e[32m SUCCESS \e[0m"
  else
    echo -e "\e[31m FAILURE \e[0m"
  fi
}

