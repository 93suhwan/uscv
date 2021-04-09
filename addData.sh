#!/bin/bash

help() {
  echo "addData.sh [OPTIONS]"
  echo "           -d directory that has the target codes."
  echo "           -f name of the target code."
  echo "           -v vulnerability type (AC, DoS, FR, IO, RE, TD, UC)"
  exit 0
}

while getopts "d:f:v:h" opt
do
  case $opt in
    d) dir=$OPTARG;;
    f) file=$OPTARG;;
    v) vul=$OPTARG;;
    h) help ;;
    ?) help ;;
  esac
done

if [ ! $vul ] || [ ! $file ] || [ ! -f $file ]; then
  help
fi

if [ ! $dir ] && [ $file ]; then
  file=${file##*/}
  cp $file ./data/$vul/$file
elif [ $dir ] && [ ! $file ]; then
  for f in $(find $dir -name "*.sol")
  do
    file=${f##*/}
    cp $file ./data/$vul/$file
  done
else
  help
fi
