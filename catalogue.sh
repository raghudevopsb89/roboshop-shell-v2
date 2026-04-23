source common.sh
component_name=catalogue
echo Log file Output : ${log_file}

echo -e "${hs} Install MySQL Client ${he}" | tee -a ${log_file}
dnf install mysql8.4 -y &>>${log_file}
status_check

echo -e "${hs} Load Schema, App User, & Master Data ${he}" | tee -a ${log_file}
mysql -h mysql-dev.rdevopsb89.online -u root -pRoboShop@1 < db/schema.sql &>>${log_file}
mysql -h mysql-dev.rdevopsb89.online -u root -pRoboShop@1 < db/app-user.sql &>>${log_file}
mysql -h mysql-dev.rdevopsb89.online -u root -pRoboShop@1 ${component_name} < db/master-data.sql &>>${log_file}
status_check

golang_app


