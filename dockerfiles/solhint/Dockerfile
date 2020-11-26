FROM ubuntu:18.04

WORKDIR /root

RUN apt-get update 

RUN apt-get install -y npm

RUN npm install solhint -g

SHELL ["/bin/bash", "-c"]

RUN echo $'{\n\  
"extends": "solhint:recommended"\n\
}\n\
' > /root/.solhint.json

ENTRYPOINT ["solhint"]
