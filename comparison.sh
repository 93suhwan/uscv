#!/bin/bash
files=( "manticore" "mythril" "oyente" "securify" "slither" "smartcheck" "solhint" "verismart" )
vul=( "AC" "DoS" "FR" "IO" "RE" "TD" "UC" )
manti=("Delegatecall to user controlled" "None detected" "Potential race condition (transaction order dependency)" "signed integer overflow at" "Potential reentrancy vulnerability|Reentrancy multi-million ether bug" "TIMESTAMP instruction used" "Returned value at")
mythril=("SWC ID: 105|SWC ID: 106" "SWC ID: 113" "None detected" "SWC ID: 101" "SWC ID: 107|SWC ID: 117" "SWC ID: 120|SWC ID: 116" "SWC ID: 104")
oyente=("Warning: Parity Multisig Bug 2" "None detected" "Warning: Transaction-Ordering Dependency" "Warning: Integer Underflow|Warning: Integer Overflow" "Warning: Re-Entrancy Vulnerability" "Warning: Timestamp Dependency" "None detected")
securify=("The execution of ether flows should |Calls to selfdestruct that can be " "None detected" "The receiver of ether transfers |The amount of ether transferred " "None detected" "Calls into external contracts that receive |Reentrancy that involves no ether |Reentrancy is equivalent with two " "Returned value relies on block " "The value returned by an |If a single call in the loop ")
slither=("#controlled-delegatecall" "None detected" "None detected" "None detected" "#reentrancy-vulnerabilities" "#block-timestamp" "#unchecked-low-level-calls")
smartcheck=("SOLIDITY_TX_ORIGIN" "SOLIDITY_OVERPOWERED_ROLE" "None detected" "SOLIDITY_VAR|SOLIDITY_UINT_CANT" "None detected" "SOLIDITY_EXACT_TIME" "SOLIDITY_UNCHECKED_CALL")
solhint=("None detected" "None detected" "None detected" "None detected" "reentrancy" "not-rely-on-time" "None detected")
verismart=("None detected" "None detected" "None detected" "\[IO\]" "None detected" "None detected" "None detected")
# This1
file=()

help() {
  echo "comparison.sh [OPTION]"
  echo "              -d <string>  Used to specify the name of a directory."
  exit 0
}

while getopts "d:h" opt
do
  case $opt in
    d) dir=$OPTARG;;
    h) help ;;
    ?) help ;;
  esac
done

writeFiles() {
if [[ $1 == "" ]]; then
  echo $2 >> $3/comparison.txt
  echo $2 >> $3/TP.txt
  echo $2 >> $3/FP.txt
  echo $2 >> $3/FN.txt
else
  echo $1 $2 >> $3/comparison.txt
  echo $1 $2 >> $3/TP.txt
  echo $1 $2 >> $3/FP.txt
  echo $1 $2 >> $3/FN.txt
fi
}

checkVul() {
  strings=$(echo $2 | tr '|' '\n')
  results=""
  loc=${1%/*}
  solFile=${loc##*/}
  countermeasure=${1##*/}
  if [[ $countermeasure = "manticore" ]]; then
    counter=mcore*/global.findings
  else
    counter=$countermeasure.txt
  fi
  counter=$loc/$counter

  IFS=$'\n'
  for string in $strings
  do
    if [[ $string = "None detected" ]]; then
      results=$string
    else
      if [[ $results = "" ]]; then
        if [ -f $counter ]; then
          results=$(grep "$string" $counter)
        fi
      fi
    fi
  done

  if [[ $results = "" ]]; then
    result="X"
    if [[ $1 =~ "result/data/$3" ]]; then
      FN=1
    fi
  elif [[ $results = "None detected" ]]; then
    result="-"
  else
    result="O"
    if [[ $1 =~ "result/data/$3" ]]; then
      TP=1
    else
      FP=1
    fi
  fi
}

for (( i=0; i<${#files[@]}; i++ ))
do
  if [[ -f $dir/${files[i]}.txt ]]; then
    file+=("${files[i]}")
  fi
done

dir=${dir%\/}
echo -ne "\t\t" > $dir/comparison.txt
echo -ne "\t\t" > $dir/TP.txt
echo -ne "\t\t" > $dir/FP.txt
echo -ne "\t\t" > $dir/FN.txt

for t in ${vul[@]}
do
  writeFiles "-ne" $t"\t" $dir
done

for (( i=0; i<${#file[@]}; i++ ))
do
  writeFiles "-ne" "\r\n${file[$i]^}\t" $dir
  for (( j=0; j<${#vul[@]}; j++ ))
  do
    result=""
    TP=0
    FP=0
    FN=0
    if [[ ${vul[$j]} = "AC" && ( ${#file[$i]} -lt 8 ) ]]; then
      writeFiles "-ne" "\t" $dir
    fi

    if [[ ${file[$i]} = "manticore" ]]; then
      checkVul "$dir/${files[i]}" "${manti[j]}" ${vul[$j]}
    elif [[ ${file[$i]} = "mythril" ]]; then
      checkVul "$dir/${files[i]}" "${mythril[j]}" ${vul[$j]}
    elif [[ ${file[$i]} = "oyente" ]]; then
      checkVul "$dir/${files[i]}" "${oyente[j]}" ${vul[$j]}
    elif [[ ${file[$i]} = "securify" ]]; then
      checkVul "$dir/${files[i]}" "${securify[j]}" ${vul[$j]}
    elif [[ ${file[$i]} = "slither" ]]; then
      checkVul "$dir/${files[i]}" "${slither[j]}" ${vul[$j]}
    elif [[ ${file[$i]} = "smartcheck" ]]; then
      checkVul "$dir/${files[i]}" "${smartcheck[j]}" ${vul[$j]}
    elif [[ ${file[$i]} = "solhint" ]]; then
      checkVul "$dir/${files[i]}" "${solhint[j]}" ${vul[$j]}
    elif [[ ${file[$i]} = "verismart" ]]; then
      checkVul "$dir/${files[i]}" "${verismart[j]}" ${vul[$j]}
    # This2
    fi
    echo -e $result"\t\c" >> $dir/comparison.txt
    if [[ $result = "-" ]]; then
      echo -e "-\t\c" >> $dir/TP.txt
      echo -e "-\t\c" >> $dir/FP.txt
      echo -e "-\t\c" >> $dir/FN.txt
    else 
      echo -e $TP"\t\c" >> $dir/TP.txt
      echo -e $FP"\t\c" >> $dir/FP.txt
      echo -e $FN"\t\c" >> $dir/FN.txt
    fi
  done
done

writeFiles "-ne" "\r\n${dir}/" $dir
writeFiles "" $(ls $dir | grep \.sol) $dir
