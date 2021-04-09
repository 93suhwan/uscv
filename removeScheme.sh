#!/bin/bash

help() {
  echo "removeScheme.sh [OPTIONS]"
  echo "                OPTIONS name of countermeaure to be removed."
  exit 0
}
countermeasure=$1

if [ ! $countermeasure ]; then
  help
fi

countermeasures=$(grep "security_tools=(" execution.sh)
if [[ $countermeasures =~ $countermeasure ]]; then
  sed -i "s/\""$countermeasure"\" //" execution.sh
  sed -i "2s/\""$countermeasure"\" //" comparison.sh
  sed -i "2s/\""$countermeasure"\" //" result.sh
  result=$(grep -n "\$tool = \"$countermeasure\"" testing.sh)
  result=${result%%:*}
  resultPlus1=$(echo "$result + 1" | bc)
  sed -i ${result},${resultPlus1}d testing.sh
  echo "$countermeaure has been removed."
else
  help
fi

