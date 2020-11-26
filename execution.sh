#!/bin/bash
security_tools=("manticore" "mythril" "oyente" "securify" "slither" "smartcheck" "solhint" "verismart")
testing_tools=("echidna" "ethlint" "sol-profiler")
ac=("manticore" "mythril" "oyente" "securify" "slither" "smartcheck")
ac_opt=("smartcheck")
dos=("mythril" "smartcheck")
dos_opt=("mythril")
fr=("manticore" "oyente" "Securify")
fr_opt=("oyente")
io=("manticore" "mythril" "oyente" "smartcheck" "verismart")
io_opt=("verismart")
re=("manticore" "mythril" "oyente" "securify" "slither" "solhint")
re_opt=("oyente""solhint")
td=("manticore" "mythril" "oyente" "securify" "slither" "smartcheck" "solhint")
td_opt=("mythril" "slither" "solhint")
uc=("manticore" "mythril" "securify" "slither" "smartcheck")
uc_opt=("slither")

dir="None"
file="None"
solc="0"
tool="None"
vul="None"
options="empty"
timeout="30"
optimal=0

help() {
  echo "execution.sh [OPTIONS]"
  echo "             -f <string>  Used to specify the name of a source file."
  echo "             -d <string>  Used to specify the name of a directory(recursively)."
  echo "             -t <string>  Used to specify the tool."
  echo "                          echidna | ethlint | manticore | mythril | oyente | securify"
  echo "                          slither | smartcheck | solhint | sol-profiler | verismart"
  echo "                          Security | Testing | All"
  echo "             -v <string>  Used to specify a type of vulnerability."
  echo "                          AC | DOS | FR | IO | RE | TD | UC"
  echo "             -r           Used to apply only the effective tool set(proposed)"
  echo "             -l <int>     Used to specify timeout value."
  echo "             -o \"string\"  Used to specify the options that the tool uniquely supports."
  exit 0
}

while getopts "d:f:o:s:t:v:l:ha" opt
do
  case $opt in
    d) dir=$OPTARG;;
    f) file=$OPTARG;;
    o) options=$OPTARG;;
    s) solc=$OPTARG;;
    t) tool=$OPTARG;;
    v) vul=$OPTARG;;
    l) timeout=$OPTARG;;
    a) optimal=1;;
    h) help ;;
    ?) help ;;
  esac
done

if [[ $tool = "None" ]]; then
  if [[ $vul = "None" ]]; then
    help;
  fi
fi
if [[ $dir = "None" ]]; then
  if [[ $file = "None" ]]; then
    help;
  fi
fi

if [[ $dir = "None" ]]; then
  if [[ $solc = "0" ]]; then
	  temp=0
    str=$(cat $file | grep "pragma" | grep [0\*]) #.[4-6])
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
    solc=0.$str
  fi
  f=$file
  file=${file%.sol}
  mkdir -p ./result/$file
  cp $f ./result/$file
  if [[ $tool = "Security" ]]; then
    for t in ${security_tools[@]}
    do
      echo "Analyzing $f using ${t^}."
      ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
    done
  elif [[ $tool = "Testing" ]]; then
    for t in ${testing_tools[@]}
    do
      echo "Analyzing $f using ${t^}."
      ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
    done
  elif [[ $tool = "All" ]]; then
    for t in ${security_tools[@]}
    do
      echo "Analyzing $f using ${t^}."
      ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
    done
    for t in ${testing_tools[@]}
    do
      echo "Analyzing $f using ${t^}."
      ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
    done
  elif [[ $vul = "AC" ]]; then
    if [[ $optimal == 0 ]]; then
      for t in ${ac[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
      done
    else
      for t in ${ac_opt[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
      done
    fi
  elif [[ $vul = "DOS" ]]; then
    if [[ $optimal == 0 ]]; then
      for t in ${dos[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
      done
    else
      for t in ${dos_opt[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
      done
    fi
  elif [[ $vul = "FR" ]]; then
    if [[ $optimal == 0 ]]; then
      for t in ${fr[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
      done
    else
      for t in ${fr_opt[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
      done
    fi
  elif [[ $vul = "IO" ]]; then
    if [[ $optimal == 0 ]]; then
      for t in ${io[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
      done
    else
      for t in ${io_opt[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
      done
    fi
  elif [[ $vul = "RE" ]]; then
    if [[ $optimal == 0 ]]; then
      for t in ${re[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
      done
    else
      for t in ${re_opt[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
      done
    fi
  elif [[ $vul = "TD" ]]; then
    if [[ $optimal == 0 ]]; then
      for t in ${td[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
      done
    else
      for t in ${td_opt[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
      done
    fi 
  elif [[ $vul = "UC" ]]; then
    if [[ $optimal == 0 ]]; then
      for t in ${uc[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
      done
    else
      for t in ${uc_opt[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$file/$t.txt
      done
    fi
  else
    echo "Analyzing $f using ${tool^}."
    ./testing.sh -t $tool -f $f -s $solc -o $options -l $timeout > ./result/$file/$tool.txt
  fi
  if [ -f ./result/$file/manticore.txt ]; then
    str=$(cat ./result/$file/manticore.txt | grep "Results in")
    str=${str#2020*Results in /root}
    str=${str%?}
    if [[ $str != "" ]]; then
      cp -r ./manticore$str ./result/$file/manticore
    fi  
  fi
  if [ -f ./result/$file/oyente.txt ]; then
    sed -i '/.*Attack Vulnerability:.*$/N;s/\n//' ./result/$file/oyente.txt
  fi
  ./comparison.sh -d ./result/$file
else
  for f in $(find $dir -name "*.sol")
  do
    temp=0
    str=$(cat $f | grep "pragma" | grep [0\*]) #.[4-6])
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
    solc=0.$str
    dirname=${f%/*}
    file=${f##*/}
    file=${file%.sol}
    exit 0
    mkdir -p ./result/$dirname/$file
    cp $f ./result/$dirname/$file
    if [[ $tool = "Security" ]]; then
      for t in ${security_tools[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
      done
    elif [[ $tool = "Testing" ]]; then
      for t in ${testing_tools[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
      done
    elif [[ $tool = "All" ]]; then
      for t in ${security_tools[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
      done
      for t in ${testing_tools[@]}
      do
        echo "Analyzing $f using ${t^}."
        ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
      done
    elif [[ $vul = "AC" ]]; then
      if [[ $optimal == 0 ]]; then
        for t in ${ac[@]}
        do
          echo "Analyzing $f using ${t^}."
          ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
        done
      else
        for t in ${ac_opt[@]}
        do
          echo "Analyzing $f using ${t^}."
          ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
        done
      fi
    elif [[ $vul = "DOS" ]]; then
      if [[ $optimal == 0 ]]; then
        for t in ${dos[@]}
        do
          echo "Analyzing $f using ${t^}."
          ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
        done
      else
        for t in ${dos_opt[@]}
        do
          echo "Analyzing $f using ${t^}."
          ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
        done
      fi
    elif [[ $vul = "FR" ]]; then
      if [[ $optimal == 0 ]]; then
        for t in ${fr[@]}
        do
          echo "Analyzing $f using ${t^}."
          ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
        done
      else
        for t in ${fr_opt[@]}
        do
          echo "Analyzing $f using ${t^}."
          ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
        done
      fi
    elif [[ $vul = "IO" ]]; then
      if [[ $optimal == 0 ]]; then
        for t in ${io[@]}
        do
          echo "Analyzing $f using ${t^}."
          ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
        done
      else
        for t in ${io_opt[@]}
        do
          echo "Analyzing $f using ${t^}."
          ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
        done
      fi
    elif [[ $vul = "RE" ]]; then
      if [[ $optimal == 0 ]]; then
        for t in ${re[@]}
        do
          echo "Analyzing $f using ${t^}."
          ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
        done
      else
        for t in ${re_opt[@]}
        do
          echo "Analyzing $f using ${t^}."
          ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
        done
      fi
    elif [[ $vul = "TD" ]]; then
      if [[ $optimal == 0 ]]; then
        for t in ${td[@]}
        do
          echo "Analyzing $f using ${t^}."
          ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
        done
      else
        for t in ${td_opt[@]}
        do
          echo "Analyzing $f using ${t^}."
          ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
        done
      fi
    elif [[ $vul = "UC" ]]; then
      if [[ $optimal == 0 ]]; then
        for t in ${uc[@]}
        do
          echo "Analyzing $f using ${t^}."
          ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
        done
      else
        for t in ${uc_opt[@]}
        do
          echo "Analyzing $f using ${t^}."
          ./testing.sh -t $t -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$t.txt
        done
      fi
    else
      echo "Analyzing $f using ${tool^}."
      ./testing.sh -t $tool -f $f -s $solc -o $options -l $timeout > ./result/$dirname/$file/$tool.txt
    fi
    if [ -f ./result/$dirname/$file/manticore.txt ]; then
      str=$(cat ./result/$dirname/$file/manticore.txt | grep "Results in")
      str=${str#2020*Results in /root}
      str=${str%?}
      if [[ $str != "" ]]; then
        cp -r ./manticore$str ./result/$dirname/$file/manticore
      fi  
    fi
    if [ -f ./result/$dirname/$file/oyente.txt ]; then
      sed -i '/.*Attack Vulnerability:.*$/N;s/\n//' ./result/$dirname/$file/oyente.txt
    fi
    ./comparison.sh -d ./result/$dirname/$file
  done
fi
