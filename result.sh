#!/bin/bash
countermeasure=( "manticore" "mythril" "oyente" "securify" "slither" "smartcheck" "solhint" "verismart" )
vul=( "AC" "DoS" "FR" "IO" "RE" "TD" "UC" "SAFE" )
file=0

help() {
  echo "result.sh [OPTIONS]"
  echo "          -d <strihg>  Used to specify the name of a directory"
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

numAC=$( ls data/AC | wc -l )
numDoS=$( ls data/DoS | wc -l )
numFR=$( ls data/FR | wc -l )
numIO=$( ls data/IO | wc -l )
numRE=$( ls data/RE | wc -l )
numTD=$( ls data/TD | wc -l )
numUC=$( ls data/UC | wc -l )
numSAFE=$( ls data/SAFE | wc -l )
numTotal=$( echo "$numAC + $numDoS + $numFR + $numIO + $numRE + $numTD + $numUC + $numSAFE" | bc )
NUM=( $numAC $numDoS $numFR $numIO $numRE $numTD $numUC $numSAFE $numTotal )

TP=()
FP=()
FN=()
TN=()
PRECISION=()
RECALL=()
ACC=()
F1=()

write3Files() {
  echo $1 $2 >> $3/TP.txt
  echo $1 $2 >> $3/FP.txt
  echo $1 $2 >> $3/FN.txt
}

write5Files() {
  echo $1 $2 >> $3/TN.txt
  echo $1 $2 >> $3/Precision.txt
  echo $1 $2 >> $3/Recall.txt
  echo $1 $2 >> $3/Acc.txt
  echo $1 $2 >> $3/F1.txt
}

if [ ! $dir ]; then
  help;
fi

for subFile in "$dir"/*
do
  subDir=${subFile/\/\///}
  echo $subDir
  if [[ -f $subDir/${subDir##*/}.sol ]]; then
    file=1
    sudo ./comparison.sh -d $subDir
  elif [[ -d $subDir ]]; then
    sudo ./result.sh -d $subDir
  else
    continue
  fi
  IFS=$'\t \n'
  tpFile=$(cat $subDir/TP.txt)
  tpFile=( $(echo $tpFile | tr ' ' '\n') )
  fpFile=$(cat $subDir/FP.txt)
  fpFile=( $(echo $fpFile | tr ' ' '\n') )
  fnFile=$(cat $subDir/FN.txt)
  fnFile=( $(echo $fnFile | tr ' ' '\n') )
  for (( i=0; i<8; i++ ))
  do
    for (( j=0; j<7; j++ ))
    do
      idx=$(echo "8 * $i + 8 + $j" | bc)
      if [[ ! ${tpFile[$idx]} = '-' ]]; then
        if [ ! ${TP[$idx]} ]; then
          TP[$idx]=${tpFile[$idx]}
          FP[$idx]=${fpFile[$idx]}
          FN[$idx]=${fnFile[$idx]}
        else
          TP[$idx]=$(echo "${TP[$idx]} + ${tpFile[$idx]}" | bc)
          FP[$idx]=$(echo "${FP[$idx]} + ${fpFile[$idx]}" | bc)
          FN[$idx]=$(echo "${FN[$idx]} + ${fnFile[$idx]}" | bc)
        fi
      else
        TP[$idx]='-'
        FP[$idx]='-'
        FN[$idx]='-'
      fi
    done
  done
done

if [ $file -eq 0 ]; then
  for (( i=0; i<8; i++ ))
  do
    for (( j=0; j<7; j++ ))
    do
      idx=$(echo "8 * $i + 8 + $j" | bc)
      if [[ ! ${tpFile[$idx]} = '-' ]]; then
        TN[$idx]=$(echo "$numTotal - ${NUM[$j]} - ${FP[$idx]}" | bc)
        if [ ${TP[$idx]} -eq 0 ] && [ ${FP[$idx]} -eq 0 ]; then
          PRECISION[$idx]=0
        else
          PRECISION[$idx]=$(echo "scale=6; ${TP[$idx]} / (${TP[$idx]} + ${FP[$idx]})" | bc)
        fi
        RECALL[$idx]=$(echo "scale=6; ${TP[$idx]} / ${NUM[$j]}" | bc)
        ACC[$idx]=$(echo "scale=6; (${TP[$idx]} + ${TN[$idx]}) / $numTotal" | bc)
        if [ ${TP[$idx]} -eq 0 ]; then
          F1[$idx]=0
        else
          F1[$idx]=$(echo "scale=6; 2 * (${RECALL[$idx]} * ${PRECISION[$idx]}) / (${RECALL[$idx]} + ${PRECISION[$idx]})" | bc)
        fi
        PRECISION[$idx]=$(echo "scale=2; ${PRECISION[$idx]} * 100 / 1" | bc)
        RECALL[$idx]=$(echo "scale=2; ${RECALL[$idx]} * 100 / 1" | bc)
        ACC[$idx]=$(echo "scale=2; ${ACC[$idx]} * 100 / 1" | bc)
        F1[$idx]=$(echo "scale=2; ${F1[$idx]} * 100 / 1" | bc)
      else
        TN[$idx]='-'
        PRECISION[$idx]='-'
        RECALL[$idx]='-'
        ACC[$idx]='-'
        F1[$idx]='-'
      fi
    done
  done
fi

echo -ne "\t\t" > $dir/TP.txt
echo -ne "\t\t" > $dir/FP.txt
echo -ne "\t\t" > $dir/FN.txt
if [ $file -eq 0 ]; then
  echo -ne "\t\t" > $dir/TN.txt
  echo -ne "\t\t" > $dir/Precision.txt
  echo -ne "\t\t" > $dir/Recall.txt
  echo -ne "\t\t" > $dir/Acc.txt
  echo -ne "\t\t" > $dir/F1.txt
fi

for (( i=0; i<7; i++ ))
do
  write3Files "-ne" "${vul[$i]}\t" $dir
  if [ $file -eq 0 ]; then
    write5Files "-ne" "${vul[$i]}\t" $dir 
  fi
done

for (( i=0; i<8; i++ ))
do
  write3Files "-ne" "\r\n${countermeasure[$i]^}\t" $dir
  if [ $file -eq 0 ]; then
    write5Files "-ne" "\r\n${countermeasure[$i]^}\t" $dir
  fi
  for (( j=0; j<7; j++ ))
  do
    idx=$(echo "8 * $i + 8 + $j" | bc)
    if [ $j -eq 0 ] && [ ${#countermeasure[$i]} -lt 8 ]; then
      write3Files "-ne" "\t" $dir
      if [ $file -eq 0 ]; then
        write5Files "-ne" "\t" $dir
      fi
    fi
    echo -ne "${TP[$idx]}\t" >> $dir/TP.txt
    echo -ne "${FP[$idx]}\t" >> $dir/FP.txt
    echo -ne "${FN[$idx]}\t" >> $dir/FN.txt
    if [ $file -eq 0 ]; then
      echo -ne "${TN[$idx]}\t" >> $dir/TN.txt
      echo -ne "${PRECISION[$idx]}\t" >> $dir/Precision.txt
      echo -ne "${RECALL[$idx]}\t" >> $dir/Recall.txt
      echo -ne "${ACC[$idx]}\t" >> $dir/Acc.txt
      echo -ne "${F1[$idx]}\t" >> $dir/F1.txt
    fi
  done
done

if [ $file -eq 0 ]; then
  write3Files "-ne" "\r\nTotal\t\t" $dir
  echo -e "\r\nTotal\t\t\c" >> $dir/TN.txt
  for (( i=0; i<7; i++ ))
  do
    total=$(echo "$numTotal - ${NUM[$i]}" | bc)
    echo -e "${NUM[$i]}\t\c" >> $dir/TP.txt
    echo -e "${NUM[$i]}\t\c" >> $dir/FN.txt
    echo -e "$total\t\c" >> $dir/FP.txt
    echo -e "$total\t\c" >> $dir/TN.txt
  done
fi

write3Files "-e" "\r\n${dir}" $dir
if [ $file -eq 0 ]; then
  write5Files "-e" "\r\n${dir}" $dir
fi
