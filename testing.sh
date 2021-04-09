#!/bin/bash

help() {
  echo "testing.sh [OPTIONS]"
  echo "           -t <string>  Used to specify the countermeasure's name."
  echo "                        echidna | ethlint | manticore | mythril | oyente | securify"
  echo "                        slither | smartcheck | solhint | sol-profiler | verismart"
  echo "                        Vul | Aux | All | Name of being added countermeasure."
  echo "           -f <strihg>  Used to specify the target code to be tested."
  echo "           -l <int>     Used to specify timeout value (1, 30, 60, 3600, ...)."
  echo "           -o \"string\"  Used to specify the options that each countermeasure uniquely supports."
  exit 0
}

while getopts "f:s:t:o:l:h" opt
do
  case $opt in
    f) file=$OPTARG;;
    o) options=$OPTARG;;
    s) solc=$OPTARG;;
    t) tool=$OPTARG;;
    l) timeout=$OPTARG;;
    h) help ;;
    ?) help ;;
  esac
done

if [[ ${solc:4:1} == "^" ]]; then
  if [[ ${solc:2:1} == "4" ]]; then
    solc="${solc:0:4}26"
  elif [[ ${solc:2:1} == "5" ]]; then
    solc="${solc:0:4}17"
  elif [[ ${solc:2:1} == "6" ]]; then
    solc="${solc:0:4}12"
  elif [[ ${solc:2:1} == "7" ]]; then
    solc="${solc:0:4}4"
  fi
elif [[ ${solc:2:1} -eq 4 ]]; then
  if [[ ${solc:4} -lt 11 ]]; then
    solc="0.4.11"
  fi
elif [[ $solc = "" ]]; then
  solc="0.4.26"
fi

docker run -it --rm -v $(pwd)/.solc:/root/.solc solc cp /root/.solcx/solc-v$solc /root/.solc/solc

start=`date +%s.%N`

timeout1=$(bc <<< "$timeout / 10 * 9")
timeout2=$(bc <<< "$timeout / 10")

filename=${file##*/}

if [[ $options = "empty" ]]; then
options=""
fi

if [[ $tool = "??" ]]; then
  help
# This
elif [[ $tool = "mythril" ]]; then
  timelimit -s 9 -t $timeout docker run -it --rm -v $(pwd)/$file:/root/$filename $tool analyze $filename --solv $solc $options
elif [[ $tool = "oyente" ]]; then
  timelimit -s 9 -t $timeout docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool -s $filename $options
elif [[ $tool = "manticore" ]]; then
  timelimit -s 9 -t $timeout docker run -it --rm -v $(pwd)/result/${file%.sol}:/root -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool $filename --core.time $timeout1 --smt.timeout $timeout2 $options
  sudo chmod 755 result/${file%.sol}/mcore*
elif [ $tool = "slither" -o $tool = "sol-profiler" -o $tool = "solhint" ]; then
  timelimit -s 9 -t $timeout docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool $filename $options
elif [[ $tool = "securify" ]]; then
  timelimit -s 9 -t $timeout docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/sec/$filename $tool $filename $options
elif [[ $tool = "ethlint" ]]; then
  timelimit -s 9 -t $timeout docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool -f $filename $options
elif [[ $tool = "smartcheck" ]]; then
  timelimit -s 9 -t $timeout docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool -p $filename $options
elif [[ $tool = "verismart" ]]; then
  timelimit -s 9 -t $timeout docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/VeriSmart-public/$filename $tool -input $filename -verify_timeout $timeout1 -z3timeout $timeout2 $options
elif [[ $tool = "echidna" ]]; then
  timelimit -s 9 -t $timeout docker run -it --rm -e PATH="$PATH:/root/.local/bin" -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool echidna-test $filename $options
else
  echo "You typed $tool. Please type right tool name"
  help
fi

end=`date +%s.%N`

runtime=$( echo "$end - $start" | bc -l )
echo "It took $runtime times."

sh -c 'docker rm -f $(docker ps -aq)' > /dev/null 2>&1

if [[ $tool = "oyente" ]]; then
  sed -i '/.*Attack Vulnerability:.*$/N;s/\n//' ./result/${file%.sol}/oyente.txt
fi
