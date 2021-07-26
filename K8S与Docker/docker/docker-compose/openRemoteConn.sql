
alter  USER'root'@'%' IDENTIFIED WITH mysql_native_password BY ${MYSQL_ROOT_PASSWORD};
flush privileges;
