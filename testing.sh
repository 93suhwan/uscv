#!/bin/bash

help() {
  echo "testing.sh [OPTIONS]"
  echo "           -t <string>  Used to specify a tool name."
  echo "                        echidna | ethlint | manticore | mythril | oyente | securify"
  echo "                        slither | smartcheck | solhint | sol-profiler | verismart"
  echo "                        Security | Testing | All"
  echo "           -f <strihg>  Used to specify a source file to be tested."
  echo "           -l <int>     Used to specify timeout value(1, 30, 60, 3600, ...)."
  echo "           -o \"string\"  Used to specify the options that the tool uniquely supports."
  exit 0
}

options="empty"

while getopts "f:o:s:t:l:h" opt
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

filename=${file##*/}

if [[ $tool = "mythril" ]]; then
  if [[ $options = "empty" ]]; then
    timelimit -s 9 -t $timeout docker run -it --rm -v $(pwd)/$file:/root/$filename $tool analyze $filename --solv $solc 
  else
    docker run -it --rm -v $(pwd)/$file:/root/$filename $tool analyze $filename --solv $solc $options
  fi
elif [[ $tool = "oyente" ]]; then
  if [[ $options = "empty" ]]; then
    timelimit -s 9 -t $timeout docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool -s $filename
  else
    docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool -s $filename $options
  fi
elif [[ $tool = "manticore" ]]; then
  if [[ $options = "empty" ]]; then
    timelimit -s 9 -t $timeout docker run -it --rm -v $(pwd)/manticore:/root -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool $filename
  else
    docker run -it --rm -v $(pwd)/manticore:/root -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool $filename
  fi
elif [ $tool = "slither" -o $tool = "sol-profiler" -o $tool = "solhint" ]; then
  if [[ $options = "empty" ]]; then
    timelimit -s 9 -t $timeout docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool $filename
  else
    docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool $filename $options
  fi
elif [[ $tool = "securify" ]]; then
  if [[ $options = "empty" ]]; then
    timelimit -s 9 -t $timeout docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/sec/$filename $tool $filename
  else
    docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/sec/$filename $tool $filename $options
  fi
elif [[ $tool = "ethlint" ]]; then
  if [[ $options = "empty" ]]; then
    timelimit -s 9 -t $timeout docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool -f $filename
  else
    docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool -f $filename $options
  fi
elif [[ $tool = "smartcheck" ]]; then
  if [[ $options = "empty" ]]; then
    timelimit -s 9 -t $timeout docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool -p $filename
  else
    docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool -p $filename $options
  fi
elif [[ $tool = "verismart" ]]; then
  time1=$(bc <<< "$timeout / 10 * 9")
  time2=$(bc <<< "$timeout / 10")
  if [[ $options = "empty" ]]; then
    docker run -it --rm  -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/VeriSmart-public/$filename $tool -input $filename -verify_timeout $time1 -z3timeout $time2
  else
    docker run -it --rm -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/VeriSmart-public/$filename $tool -input $filename
  fi
elif [[ $tool = "echidna" ]]; then
  if [[ $options = "empty" ]]; then
    timelimit -s 9 -t $timeout docker run -it --rm -e PATH="$PATH:/root/.local/bin" -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool echidna-test $filename
  else
    docker run -it --rm -e PATH="$PATH:/root/.solc:/root/.local/bin" -v $(pwd)/.solc/solc:/usr/bin/solc -v $(pwd)/$file:/root/$filename $tool echidna-test $filename $options
  fi
else
  echo "You typed $tool. Please type right tool name"
  help
fi
end=`date +%s.%N`
runtime=$( echo "$end - $start" | bc -l )
echo "It took $runtime times."
sh -c 'docker rm -f $(docker ps -aq)' > /dev/null 2>&1
