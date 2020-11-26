FROM ubuntu:18.04

ENV OPAM_SWITCH_PREFIX /root/.opam/4.10.0

ENV MANPATH /root/.opam/4.10.0/man

ENV PATH $PATH:/root/.opam/4.10.0/bin

RUN apt-get update
RUN apt-get install -y wget git make m4 patch unzip bubblewrap python3 python3-distutils g++ build-essential
RUN wget https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh
RUN echo "\n" | sh install.sh

RUN opam init --reinit -ni --disable-sandboxing --compiler=4.10.0
#RUN opam switch create 4.10.0
RUN opam install -y conf-m4.1 ocamlfind ocamlbuild num yojson batteries ocamlgraph

RUN wget https://github.com/Z3Prover/z3/releases/download/z3-4.7.1/z3-4.7.1.tar.gz
RUN tar -xvzf z3-4.7.1.tar.gz
WORKDIR /z3rel
RUN python3 scripts/mk_make.py --ml
WORKDIR /z3rel/build
RUN make -j 4
RUN make install

WORKDIR /root
RUN git clone https://github.com/kupl/VeriSmart-public.git
WORKDIR /root/VeriSmart-public
RUN chmod +x ./build
RUN ./build

WORKDIR /root/VeriSmart-public

ENTRYPOINT ["./main.native"]
