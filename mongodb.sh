source common.sh

echo -e "${hs} Copy MongoDB service file ${he}" | tee -a ${log_file}
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
echo $?

echo -e "${hs} Install MongoDB ${he}" | tee -a ${log_file}
dnf install -y mongodb-org &>>${log_file}
echo $?


echo -e "${hs} Update MongoDB config ${he}" | tee -a ${log_file}
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf &>>${log_file}
echo $?

echo -e "${hs} Start MongoDB service ${he}" | tee -a ${log_file}
systemctl enable mongod
systemctl restart mongod &>>${log_file}
echo $?
