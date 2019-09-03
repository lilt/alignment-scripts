#!/bin/bash

set -ex

mkdir -p giza-forcealign
cd giza-forcealign

for ln_pair in "roen" "enfr" "deen"; do
  ../scripts/giza.sh ../train/${ln_pair}.lc.src ../train/${ln_pair}.lc.tgt ${ln_pair}
done

cd -

