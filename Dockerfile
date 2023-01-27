FROM ubuntu:latest

LABEL maintainer="Ravindra Singh"
LABEL desc="ubuntu image is latest"

ENV UBUNTU_HOME=/var/www/html/
ENV DEBIAN_FRONTEND noninteractive	

# Updating system
RUN apt-get update -y \
  &&  apt-get -y install tzdata \
  && apt-get install apache2 -y
  
WORKDIR UBUNTU_HOME

COPY script/ ${UBUNTU_HOME}

EXPOSE 80

CMD ["apachectl" , "-D","FOREGROUND"]
