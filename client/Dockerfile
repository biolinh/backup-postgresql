FROM debian:8-slim
MAINTAINER linh.bio@gmail.com
RUN echo "deb http://ftp.de.debian.org/debian sid main " | tee /etc/apt/sources.list.d/postgresql-client.list
RUN apt-get  update && apt-get install -y postgresql-client 
