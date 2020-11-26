FROM ubuntu:18.04

WORKDIR /root

RUN apt-get update 

RUN apt-get install -y npm 

RUN npm install -g ethlint 

RUN solium --init

ENTRYPOINT ["solium"]
