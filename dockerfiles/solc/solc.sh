#!/bin/bash
for v in {11..26}
do
  echo "Install v0.4.$v..."
  python3 -m solcx.install v0.4.$v
done
for v in {0..17}
do
  echo "Install v0.5.$v..."
  python3 -m solcx.install v0.5.$v
done
for v in {0..12}
do
  echo "Install v0.6.$v..."
  python3 -m solcx.install v0.6.$v
done
for v in {0..4}
do
  echo "Install v0.7.$v..."
  python3 -m solcx.install v0.7.$v
done

chmod +x -R /root/.solcx
