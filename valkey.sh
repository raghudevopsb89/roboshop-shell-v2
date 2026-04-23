source common.sh

echo -e "${hs} Install Valkey ${he}" | tee -a ${log_file}
dnf install -y valkey &>>${log_file}
status_check

echo -e "${hs} Update Valkey config ${he}" | tee -a ${log_file}
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/valkey/valkey.conf &>>${log_file}
sed -i 's/protected-mode yes/protected-mode no/' /etc/valkey/valkey.conf &>>${log_file}
status_check

echo -e "${hs} Start Valkey service ${he}" | tee -a ${log_file}
systemctl enable valkey &>>${log_file}
systemctl restart valkey &>>${log_file}
status_check
