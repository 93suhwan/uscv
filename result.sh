#!/bin/bash
manticore=( 0 - 0 0 0 0 0 )
mythril=( 0 0 - 0 0 0 0 )
oyente=( 0 - 0 0 0 0 - )
securify=( 0 - 0 - 0 0 0 )
slither=( 0 - - - 0 0 0 )
smartcheck=( 0 0 - 0 - 0 0 )
solhint=( - - - - 0 0 - )
verismart=( - - - 0 - - - )
vul=("AC" "DOS" "FR" "IO" "RE" "TD" "UC")
tools=( "Manticore" "Mythril" "Oyente" "Securify" "Slither" "SmartCheck" "Solhint" "VeriSmart" "Over")

dir="None"
help() {
  echo "result.sh [OPTIONS]"
  echo "          -d <strihg>  Used to specify the name of a directory"
  echo "          -o <int>     Used to specify the number of tools to detect together."
  exit 0
}

over=8

while getopts "d:o:h" opt
do
  case $opt in
    d) dir=$OPTARG;;
    o) over=$OPTARG;;
    h) help ;;
    ?) help ;;
  esac
done

if [[ $dir = "None" || $over -gt 7 ]]; then
  help;
fi

echo -ne "\t\t" > $dir/result.txt

for t in ${vul[@]}
do
  echo -ne $t"\t" >> $dir/result.txt
done

NorMore=( 0 0 0 0 0 0 0 )
count=0

for f in $(find $dir -name "comparison.txt")
do
  dirname=${f%/*}
  temp=( 0 0 0 0 0 0 0 )
  if [[ ${dirname##*/} == "manticore" ]]; then
    continue
  fi
  count=$(($count + 1))
  for (( i=0; i<8; i++ ))
  do
    grepResult=$(grep "${tools[$i]}" $dirname/comparison.txt)
    if [[ $grepResult != "" ]]; then
      IFS=$' \t' read -r -a splits <<< "$grepResult"
      for (( j=0; j<7; j++ ))
      do
        if [[ ${splits[$j + 1]}  = "O" ]]; then
          temp[$j]=$((${temp[$j]} + 1))
          if [[ ${tools[$i]} = "Manticore" ]]; then
            manticore[$j]=$((${manticore[$j]} + 1))
          elif [[ ${tools[$i]} = "Mythril" ]]; then
            mythril[$j]=$((${mythril[$j]} + 1))
          elif [[ ${tools[$i]} = "Oyente" ]]; then
            oyente[$j]=$((${oyente[$j]} + 1))
          elif [[ ${tools[$i]} = "Securify" ]]; then
            securify[$j]=$((${securify[$j]} + 1))
          elif [[ ${tools[$i]} = "Slither" ]]; then
            slither[$j]=$((${slither[$j]} + 1))
          elif [[ ${tools[$i]} = "SmartCheck" ]]; then
            smartcheck[$j]=$((${smartcheck[$j]} + 1))
          elif [[ ${tools[$i]} = "Solhint" ]]; then
            solhint[$j]=$((${solhint[$j]} + 1))
          else
            verismart[$j]=$((${verismart[$j]} + 1))
          fi
        fi
      done
    fi
  done
  for (( i=0; i<7; i++ ))
  do
    if [[ ${temp[$i]} -ge $over ]]; then
      NorMore[$i]=$((${NorMore[$i]} + 1))
    fi
  done
done
echo >> $dir/result.txt
for (( i=0; i<9; i++ ))
do
  if [[ $i == 8 ]]; then
    echo -ne "${tools[$i]}" $over "\t" >> $dir/result.txt
  else
    echo -ne "${tools[$i]}""\t" >> $dir/result.txt
  fi
  for (( j=0; j<7; j++ ))
  do
    if [[ ${vul[$j]} = "AC" && ( ${tools[$i]} = "Mythril" || ${tools[$i]} = "Oyente" || ${tools[$i]} = "Slither" || ${tools[$i]} = "Solhint" || ${tools[$i]} = "Over" ) ]]; then
      echo -ne "\t" >> $dir/result.txt
    fi
    if [[ ${tools[$i]} = "Manticore" ]]; then
      echo -ne "${manticore[$j]}\t" >> $dir/result.txt
    elif [[ ${tools[$i]} = "Mythril" ]]; then
      echo -ne "${mythril[$j]}\t" >> $dir/result.txt
    elif [[ ${tools[$i]} = "Oyente" ]]; then
      echo -ne "${oyente[$j]}\t" >> $dir/result.txt
    elif [[ ${tools[$i]} = "Securify" ]]; then
      echo -ne "${securify[$j]}\t" >> $dir/result.txt
    elif [[ ${tools[$i]} = "Slither" ]]; then
      echo -ne "${slither[$j]}\t" >> $dir/result.txt
    elif [[ ${tools[$i]} = "SmartCheck" ]]; then
      echo -ne "${smartcheck[$j]}\t" >> $dir/result.txt
    elif [[ ${tools[$i]} = "Solhint" ]]; then
      echo -ne "${solhint[$j]}\t" >> $dir/result.txt
    elif [[ ${tools[$i]} = "VeriSmart" ]]; then
      echo -ne "${verismart[$j]}\t" >> $dir/result.txt
    else
      echo -ne "${NorMore[$j]}\t" >> $dir/result.txt
    fi
  done
    echo >> $dir/result.txt
done
echo -ne "\nTotal number of files " $count "\n">> $dir/result.txt
