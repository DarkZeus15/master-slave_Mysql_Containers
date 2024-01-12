mkdir -p mysql-master-slave_1/master/conf/
mkdir -p mysql-master-slave_1/slave/conf/

echo "Creating File : mysql-master-slave_1/master/conf/mysql.conf.cnf"
echo '''[mysqld]
skip-name-resolve
default_authentication_plugin = mysql_native_password
server-id = 1
log_bin = 1
binlog_format = ROW
binlog_do_db = mydb''' > mysql-master-slave_1/master/conf/mysql.conf.cnf


echo "Creating file : mysql-master-slave_1/slave/conf/mysql.conf.cnf"
echo '''[mysqld]
skip-name-resolve
default_authentication_plugin = mysql_native_password
server-id = 2
log_bin = 1
binlog_do_db = mydb''' > mysql-master-slave_1/slave/conf/mysql.conf.cnf


echo "Creating File : mysql-master-slave_1/master/mysql_master.env"
echo '''MYSQL_ROOT_PASSWORD=111
MYSQL_PORT=3306
MYSQL_USER=mydb_user
MYSQL_PASSWORD=mydb_pwd
MYSQL_DATABASE=mydb
MYSQL_LOWER_CASE_TABLE_NAMES=0''' > mysql-master-slave_1/master/mysql_master.env


echo "Creating File : mysql-master-slave_1/slave/mysql_slave.env"
echo '''MYSQL_ROOT_PASSWORD=111
MYSQL_PORT=3306
MYSQL_USER=mydb_slave_user
MYSQL_PASSWORD=mydb_slave_pwd
MYSQL_DATABASE=mydb
MYSQL_LOWER_CASE_TABLE_NAMES=0''' > mysql-master-slave_1/slave/mysql_slave.env

cd mysql-master-slave_1