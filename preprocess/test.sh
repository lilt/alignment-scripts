#!/bin/bash

set -ex

mkdir -p test/
cd test

for ln_pair in "roen" "enfr" "deen"; do
  ../preprocess/${ln_pair}-test.sh
  for suffix in "src" "tgt"; do
    ../scripts/lowercase.py < ${ln_pair}.${suffix} > ${ln_pair}.lc.${suffix}
    if [ -f ${MOSES_DIR}/scripts/tokenizer/detokenizer.perl ]; then
      ${MOSES_DIR}/scripts/tokenizer/detokenizer.perl < ${ln_pair}.lc.${suffix} > ${ln_pair}.lc.detok.${suffix}
    fi
  done
done

cd -
