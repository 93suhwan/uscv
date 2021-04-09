#!/bin/bash
security_tools=( "manticore" "mythril" "oyente" "securify" "slither" "smartcheck" "solhint" "verismart" )
testing_tools=( "echidna" "ethlint" "sol-profiler" )

ac=( "manticore" "mythril" "oyente" "securify" "slither" "smartcheck" )
dos=( "mythril" "smartcheck" )
fr=( "manticore" "oyente" "Securify" )
io=( "manticore" "mythril" "oyente" "smartcheck" "verismart" )
re=( "manticore" "mythril" "oyente" "securify" "slither" "solhint" )
td=( "manticore" "mythril" "oyente" "securify" "slither" "smartcheck" "solhint" )
uc=( "manticore" "mythril" "securify" "slither" "smartcheck" )

solc="0"
options="empty"
timeout="60"

help() {
  echo "execution.sh [OPTIONS]"
  echo "             -f <string>  Used to specify the name of a target code."
  echo "             -d <string>  Used to specify the name of a directory (recursively)."
  echo "             -t <string>  Used to specify a countermeasure."
  echo "                          echidna | ethlint | manticore | mythril | oyente | securify"
  echo "                          slither | smartcheck | solhint | sol-profiler | verismart"
  echo "                          Aux | Vul | All | Name of being added countermeasure."
  echo "             -v <string>  Used to specify a type of vulnerability."
  echo "                          AC | DoS | FR | IO | RE | TD | UC"
  echo "             -l <int>     Used to specify a timeout value."
  echo "             -o \"string\"  Used to specify the options that each countermeasure uniquely supports."
  exit 0
}

while getopts "d:f:o:s:t:v:l:h" opt
do
  case $opt in
    d) input=$OPTARG;;
    f) input=$OPTARG;;
    o) options=$OPTARG;;
    s) solc=$OPTARG;;
    t) tool=$OPTARG;;
    v) vul=$OPTARG;;
    l) timeout=$OPTARG;;
    h) help ;;
    ?) help ;;
  esac
done

checkSolc() {
  sol=$1
  if [[ $sol = "0" ]]; then
	  temp=0
    str=$(cat $2 | grep "pragma" | grep [0\*])
	  if [[ "$str" =~ "^" || "$str" =~ ">" ]]; then
  	  temp=1
  	fi
    str=${str#*pragma*0.}
    str=${str%%[; ]*}
	  if [[ $temp == 1 ]]; then
      str="${str:0:2}^"
	  fi
    if [[ $str == "" ]]; then
      str=5.17
    fi
    sol=0.$str
  fi
  solc=$sol
}

if ( [ ! $tool ] && [ ! $vul ] ) || ( [ ! $input ] ) ; then
  help
fi

if [ -d "$input" ] || [ -f $input ]; then
  for f in $(find $input -name "*.sol")
  do
    checkSolc $solc $f
    dirname=${f%/*}
    file=${f##*/}
    file=${file%.sol}
    mkdir -p ./result/$dirname/$file
    cp $f ./result/$dirname/$file
    if [[ $tool = "Vul" ]]; then
      tool=("${security_tools[@]}")
    elif [[ $tool = "Aux" ]]; then
      tool=("$testing_tools{[@]}")
    elif [[ $tool = "All" ]]; then
      tool=("${security_tools[@]}")
      tool+=("${testing_tools[@]}")
    elif [[ $vul = "AC" ]]; then
      tool=("${ac[@]}")
    elif [[ $vul = "DoS" ]]; then
      tool=("${dos[@]}")
    elif [[ $vul = "FR" ]]; then
      tool=("${fr[@]}")
    elif [[ $vul = "IO" ]]; then
      tool=("${io[@]}")
    elif [[ $vul = "RE" ]]; then
      tool=("${re[@]}")
    elif [[ $vul = "TD" ]]; then
      tool=("${td[@]}")
    elif [[ $vul = "UC" ]]; then
      tool=("${uc[@]}")
    fi
      for t in ${tool[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -l $timeout -o "$options" > ./result/$dirname/$file/$t.txt
      done
  done
  sudo ./result.sh -d result/data
  sudo python3 plot.py
else
  help
fi
