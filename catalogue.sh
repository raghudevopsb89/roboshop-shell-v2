source common.sh
component_name=catalogue
echo Log file Output : ${log_file}

echo -e "${hs} Install GoLang & MySQL Client ${he}" | tee -a ${log_file}
dnf install -y golang git mysql8.4 &>>${log_file}
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

echo -e "${hs} Load Schema, App User, & Master Data ${he}" | tee -a ${log_file}
mysql -h mysql-dev.rdevopsb89.online -u root -pRoboShop@1 < db/schema.sql &>>${log_file}
mysql -h mysql-dev.rdevopsb89.online -u root -pRoboShop@1 < db/app-user.sql &>>${log_file}
mysql -h mysql-dev.rdevopsb89.online -u root -pRoboShop@1 ${component_name} < db/master-data.sql &>>${log_file}
echo $?

echo -e "${hs} Create Application User ${he}" | tee -a ${log_file}
useradd -r -s /bin/false appuser &>>${log_file}
echo $?


echo -e "${hs} Compile Application Code ${he}" | tee -a ${log_file}
go mod tidy &>>${log_file}
CGO_ENABLED=0 go build -o /app/${component_name} . &>>${log_file}
echo $?

echo -e "${hs} Apply permission for application folder  ${he}" | tee -a ${log_file}
chown -R appuser:appuser /app &>>${log_file}
chmod o-rwx /app -R &>>${log_file}
echo $?

echo -e "${hs} Start Service ${he}" | tee -a ${log_file}
systemctl daemon-reload &>>${log_file}
systemctl enable ${component_name} &>>${log_file}
systemctl restart ${component_name} &>>${log_file}
echo $?
