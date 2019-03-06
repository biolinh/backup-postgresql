## backup_mysql_databases
This project build a image helping to run a script to backup Mysql database.


## How to use this image
### Start a mysql client instance
`$ docker run --name some-mysql -e MY_PASS=mypassword -d biolinh/biolinh/backup_mysql_databases:tag`

### ... via docker stack deploy or docker-compose
Example docker-compose.yml for mysql:
```
version: '3'
services:
  backup_mysql:
    image: biolinh/backup_mysql_databases:1.0
    container_name: backup_mysql
    environment:
    - MY_USER=myuser
    - MY_PASS=myhost
    - MY_HOST=ip-of-server
    - MY_BACKUP_DIRECTORY=backup_mysql
    - MY_BACKUP_DB=mydata
    - MY_STORED_DAY=1
    volumes:
    - ./backup_mysql:/backup_mysql
```
run `docker-compose up ` to backup database.

## Environment Variables
 
#### **MY_USER**
The variable specifies the user to connect the Mysql server. The đefault value is root

#### **MY_PASS**
The variable is mandatory and specifies user's password connecting to Mysql server.

#### **MY_HOST**
The variable specifies the host of Mysql server. The default value is localhost.
Noted: if the host isn't localhost value, it's Mysql user must be allowed connect from outside. myuser@% will allow access from anywhere.

#### **MY_BACKUP_DIRECTORY**
The variable is optional and specifies the location to store the backup files. The default value is /backup.

#### **MY_BACKUP_DB**
The variable is mandatory and specifies which database will be backuped.

#### **MY_STORED_DAY**
The variable is optional and specifies the day of back up file which will be kept before removed. This feature doesn't be available in version 1.0
The default value is 7 days.
