#!/bin/bash
# This
docker build -t ethlint dockerfiles/ethlint
docker build -t manticore dockerfiles/manticore
docker build -t mythril dockerfiles/mythril
docker build -t oyente dockerfiles/oyente
docker build -t slither dockerfiles/slither
docker build -t smartcheck dockerfiles/smartcheck
docker build -t profiler dockerfiles/sol-profiler
docker build -t solc dockerfiles/solc
docker build -t solhint dockerfiles/solhint
docker build -t verismart dockerfiles/veri-smart
git clone https://github.com/eth-sri/securify2.git dockerfiles/securify
docker build -t securify dockerfiles/securify
git clone https://github.com/crytic/echidna.git dockerfiles/echidna
docker build -t echidna dockerfiles/echidna
