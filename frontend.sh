source common.sh
component_name=frontend

echo Log file Output : ${log_file}
echo -e "${hs} Install Nginx ${he}" | tee -a ${log_file}
dnf install -y nginx &>>${log_file}
echo $?

echo -e "${hs} Copy Nginx Config ${he}" | tee -a ${log_file}
cp nginx.conf /etc/nginx/nginx.conf &>>${log_file}
echo $?

echo -e "${hs} Install NodeJS ${he}" | tee -a ${log_file}
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - &>>${log_file}
dnf install -y nodejs &>>${log_file}
echo $?

echo -e "${hs} Download ${component_name} Code ${he}" | tee -a ${log_file}
curl -L -o /tmp/${component_name}.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/${component_name}.zip &>>${log_file}
echo $?

echo -e "${hs} Create App Directory ${he}" | tee -a ${log_file}
rm -rf /tmp/${component_name} &>>${log_file}
mkdir -p /tmp/${component_name} &>>${log_file}
echo $?
cd /tmp/${component_name} &>>${log_file}

echo -e "${hs} Extract App Code ${he}" | tee -a ${log_file}
unzip /tmp/${component_name}.zip &>>${log_file}
echo $?

echo -e "${hs} Install App Dependencies & Build Html Code ${he}" | tee -a ${log_file}
npm cache clean --force &>>${log_file}
npm install &>>${log_file}
npm run build &>>${log_file}
echo $?

echo -e "${hs} Copy Built Code to Nginx ${he}" | tee -a ${log_file}
rm -rf /usr/share/nginx/html/* &>>${log_file}
cp -r out/* /usr/share/nginx/html/ &>>${log_file}
echo $?

echo -e "${hs} Start Nginx Service ${he}" | tee -a ${log_file}
systemctl enable nginx &>>${log_file}
systemctl restart nginx &>>${log_file}
echo $?

