#!/bin/bash
vul=("AC" "DOS" "FR" "IO" "RE" "TD" "UC")
manti=("Delegatecall to user controlled" "False condition" "Potential race condition (transaction order dependency)" "signed integer overflow at" "Potential reentrancy vulnerability|Reentrancy multi-million ether bug" "TIMESTAMP instruction used" "Returned value at")
mythril=("SWC ID: 105|SWC ID: 106" "SWC ID: 113" "False condition" "SWC ID: 101" "SWC ID: 107|SWC ID: 117" "SWC ID: 120|SWC ID: 116" "SWC ID: 104")
oyente=("Parity Multisig Bug 2" "False condition" "Transaction-Ordering Dependence" "Integer Underflow|Integer Overflow" "Re-Entrancy Vulnerability" "Timestamp Dependency" "False condition")
securify=("The address of a delegatecall " "False condition" "Transaction Order Affects" "False condition" "Reentrancy" "Usage of block timestamp" "Unused Return Pattern")
slither=("#controlled-delegatecall" "False condition" "False condition" "False condition" "#reentrancy-vulnerabilities" "#block-timestamp" "#unchecked-low-level-calls")
smartcheck=("SOLIDITY_VISIBILITY" "SOLIDITY_UNCHECKED_CALL" "False condition" "SOLIDITY_VAR|SOLIDITY_UINT_CANT" "False condition" "SOLIDITY_EXACT_TIME" "SOLIDITY_FUNCTION_RETURNS")
solhint=("False condition" "False condition" "False condition" "False condition" "reentrancy" "not-rely-on-time" "False condition")
files=("manticore.txt" "mythril.txt" "oyente.txt" "securify.txt" "slither.txt" "smartcheck.txt" "solhint.txt" "verismart.txt")
file=()
tools=("Manticore" "Mythril" "Oyente" "Securify" "Slither" "SmartCheck" "Solhint" "VeriSmart")
exist=()

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

for (( i=0; i<${#files[@]}; i++ ))
do
if [[ -f $dir/${files[i]} ]]; then
  file+=("${files[i]}")
  exist+=("${tools[i]}")
fi
done

echo -ne "\t\t" > $dir/comparison.txt

for t in ${vul[@]}
do
  echo -ne $t"\t" >> $dir/comparison.txt
done

for (( i=0; i<${#exist[@]}; i++ ))
do
  echo -ne "\n""${exist[$i]}""\t" >> $dir/comparison.txt
  for (( j=0; j<${#vul[@]}; j++ ))
  do
    if [[ ${vul[$j]} = "AC" && ( ${file[$i]} = "mythril.txt" || ${file[$i]} = "oyente.txt" || ${file[$i]} = "slither.txt" || ${file[$i]} = "solhint.txt" ) ]]; then
      echo -ne "\t" >> $dir/comparison.txt
    fi
    if [[ ${file[$i]} = "manticore.txt" ]]; then
      if [[ ${manti[$j]} = "False condition" ]]; then
        result="False condition"
      elif [[ ${manti[$j]} =~ "|" ]]; then
        result=$(grep "${manti[$j]%%|*}" $dir/${file[$i]})
        if [[ $result = "" ]]; then
          result=$(grep "${manti[$j]##*|}" $dir/${file[$i]})
        fi
      else
        result=$(grep "${manti[$j]}" $dir/${file[$i]})
      fi
    elif [[ ${file[$i]} = "mythril.txt" ]]; then
      if [[ ${mythril[$j]} = "False condition" ]]; then
        result="False condition"
      elif [[ ${mythril[$j]} =~ "|" ]]; then
        result=$(grep "${mythril[$j]%%|*}" $dir/${file[$i]})
        if [[ $result = "" ]]; then
          result=$(grep "${mythril[$j]##*|}" $dir/${file[$i]})
        fi
      else
        result=$(grep "${mythril[$j]}" $dir/${file[$i]})
      fi
    elif [[ ${file[$i]} = "oyente.txt" ]]; then
      if [[ ${oyente[$j]} = "False condition" ]]; then
        result="False condition"
      elif [[ ${oyente[$j]} =~ "|" ]]; then
        result=$(grep "${oyente[$j]%%|*}" $dir/${file[$i]})
        if [[ $result = "" ]]; then
          result=$(grep "${oyente[$j]##*|}" $dir/${file[$i]})
        fi
      else
        result=$(grep "${oyente[$j]}" $dir/${file[$i]} | grep "True")
      fi
    elif [[ ${file[$i]} = "securify.txt" ]]; then
      if [[ ${securify[$j]} = "False condition" ]]; then
        result="False condition"
      else
        result=$(grep "${securify[$j]}" $dir/${file[$i]})
      fi
    elif [[ ${file[$i]} = "slither.txt" ]]; then
      if [[ ${slither[$j]} = "False condition" ]]; then
        result="False condition"
      else
        result=$(grep "${slither[$j]}" $dir/${file[$i]})
      fi
    elif [[ ${file[$i]} = "smartcheck.txt" ]]; then
      if [[ ${smartcheck[$j]} = "False condition" ]]; then
        result="False condition"
      elif [[ ${smartcheck[$j]} =~ "|" ]]; then
        result=$(grep "${smartcheck[$j]%%|*}" $dir/${file[$i]})
        if [[ $result = "" ]]; then
          result=$(grep "${smartcheck[$j]##*|}" $dir/${file[$i]})
        fi
      else
        result=$(grep "${smartcheck[$j]}" $dir/${file[$i]})
      fi
    elif [[ ${file[$i]} = "solhint.txt" ]]; then
      if [[ ${solhint[$j]} = "False condition" ]]; then
        result="False condition"
      else
        result=$(grep "${solhint[$j]}" $dir/${file[$i]})
      fi
    elif [[ ${file[$i]} = "verismart.txt" ]]; then
      if [[ ${vul[$j]} = "IO" ]]; then
        result=$(grep -A1 "Queries" $dir/${file[$i]} | tr -d '\015' | tail -1 | cut -d ':' -f2 | bc)
        if [[ $result > 0 ]]; then
          result="True"
        else
          result=''
        fi
      else
        result="False condition"
      fi
    fi
    if [[ $result = "False condition" ]]; then
      echo -e "-\t\c" >> $dir/comparison.txt
    elif [[ $result = '' ]]; then
      echo -e "X\t\c" >> $dir/comparison.txt
    else
      echo -e "O\t\c" >> $dir/comparison.txt
    fi
  done
done

echo -e "\n${dir}/\c" >> $dir/comparison.txt
echo $(ls $dir | grep \.sol) >> $dir/comparison.txt 
