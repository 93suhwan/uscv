FROM ubuntu:18.04

WORKDIR /root

RUN apt-get update 

RUN apt-get install -y python3-pip

RUN pip3 install py-solc-x

COPY solc.sh .

RUN chmod +x solc.sh

RUN ./solc.sh 2> /dev/null
