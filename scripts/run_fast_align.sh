#!/bin/bash

set -ex

mkdir -p fastalign
cd fastalign

for ln_pair in "enfr" "roen" "deen"; do
  ../scripts/fast_align.sh ../train/${ln_pair}.lc.plustest.src ../train/${ln_pair}.lc.plustest.tgt ${ln_pair}
  ../scripts/combine.sh ${ln_pair}.talp ${ln_pair}.reverse.talp ../test/${ln_pair}.talp > ${ln_pair}-results.txt
done
