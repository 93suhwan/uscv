FROM ubuntu:18.04

WORKDIR /root

RUN apt-get update 

RUN apt-get install -y python3-pip

RUN pip3 install slither-analyzer

ENTRYPOINT ["slither"]
