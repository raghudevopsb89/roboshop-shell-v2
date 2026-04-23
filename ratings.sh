source common.sh
component_name=ratings
echo Log file Output : ${log_file}
schema_load=true
schema_type=mysql
schema_files="schema.sql app-user.sql"
extra_pip_packages=cryptography

python_app
