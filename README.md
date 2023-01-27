# docker-cncf-meetup
Repoitory contains the code of demo reference

# Commands to build the docker iamge
Pipeline to create DB and USERS in Atlas Mongo

- Commands to run build the code and run in the local machine
``` sh
docker build -t web:latest .
docker run -itd -p 80:80 web:latest
curl localhost
```
