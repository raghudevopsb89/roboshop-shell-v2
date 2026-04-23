source common.sh

echo -e "${hs} Copy RabbitMQ repo file ${he}" | tee -a ${log_file}
cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>${log_file}
status_check

echo -e "${hs} Install Erlang & RabbitMQ ${he}" | tee -a ${log_file}
dnf install -y rabbitmq-server erlang &>>${log_file}
status_check

echo -e "${hs} Start RabbitMQ service ${he}" | tee -a ${log_file}
systemctl enable rabbitmq-server &>>${log_file}
systemctl start rabbitmq-server &>>${log_file}
status_check

echo -e "${hs} Enable Management Plugin ${he}" | tee -a ${log_file}
rabbitmq-plugins enable rabbitmq_management &>>${log_file}
systemctl restart rabbitmq-server &>>${log_file}
status_check

echo -e "${hs} Create Application User ${he}" | tee -a ${log_file}
rabbitmqctl add_user roboshop RoboShop@1 &>>${log_file}
rabbitmqctl set_user_tags roboshop administrator &>>${log_file}
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${log_file}
status_check
