#!/bin/bash

docker-compose down -v      # Stops and removes containers, networks, and volumes defined in the docker-compose.yml file.
rm -rf ./master/data/*      # Removes files and directories recursively and forcefully.
rm -rf ./slave/data/*       # Removes files and directories recursively and forcefully.
docker-compose build        # Builds or rebuilds Docker images defined in the docker-compose.yml file
docker-compose up -d        # Starts the Docker containers defined in the docker-compose.yml file.


until docker exec mysql_master sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql_master database connection..."
    sleep 4
done
# connect to mysql_master and run an empty command (-e ";"), sending password '111' to mysql to check connectivity status. Once successfull , it gets out of untill loop.

priv_stmt='CREATE USER "mydb_slave_user"@"%" IDENTIFIED BY "mydb_slave_pwd"; GRANT REPLICATION SLAVE ON *.* TO "mydb_slave_user"@"%"; FLUSH PRIVILEGES;'
docker exec mysql_master sh -c "export MYSQL_PWD=111; mysql -u root -e '$priv_stmt'"
# Create user 'mydb_slave_user' & allow the user to connect from any host ie. '%', Set Password : 'mydb_slave_pwd'.
# GRANT : replication slave privilege from any host to 'mydb_slave_user' user
# To apply replication previlages from grant table., 'FLUSH PRIVILEGES' command is used. Its like refresh

until docker-compose exec mysql_slave sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql_slave database connection..."
    sleep 4
done
# Same as master, we need to check connection to the slave by sending in password to inner mysql process of the slave container untill it connects.


MS_STATUS=`docker exec mysql_master sh -c 'export MYSQL_PWD=111; mysql -u root -e "SHOW MASTER STATUS"'`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`
# CURRENT_LOG : Specifies the binary log file on the master from which the replication should start.
# CURRENT_POS : Specifies the position within the binary log file from which replication should start.


start_slave_stmt="CHANGE MASTER TO MASTER_HOST='mysql_master',MASTER_USER='mydb_slave_user',MASTER_PASSWORD='mydb_slave_pwd',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd='export MYSQL_PWD=111; mysql -u root -e "'
start_slave_cmd+="$start_slave_stmt"
start_slave_cmd+='"'
docker exec mysql_slave sh -c "$start_slave_cmd"
# MASTER TO MASTER_HOST : Specifies the hostname or IP address of the MySQL master server.
# MASTER_USER : Specifies the username of the MySQL user on the master for replication.
# START SLAVE : This SQL statement starts the slave thread, initiating the replication process


docker exec mysql_master sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW MASTER STATUS \G'"
docker exec mysql_slave sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW SLAVE STATUS \G'"
