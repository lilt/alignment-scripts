#!/bin/bash

set -ex

mkdir -p test/
cd test

for ln_pair in "roen" "enfr" "deen"; do
  ../preprocess/${ln_pair}-test.sh
  for suffix in "src" "tgt"; do
    ../scripts/lowercase.py < ${ln_pair}.${suffix} > ${ln_pair}.lc.${suffix}
  done
done

cd -
