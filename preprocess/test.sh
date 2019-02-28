#!/bin/bash

set -ex

mkdir -p test/
cd test

for ln_pair in "roen" "enfr" "deen"; do
  ../preprocess/${ln_pair}-test.sh
  for suffix in "src" "tgt"; do
    for dataset in "" ".trial"; do
      # deen has no trial data, create empty file to avoid fatal errors
      touch ${ln_pair}${dataset}.${suffix}
      ../scripts/lowercase.py < ${ln_pair}${dataset}.${suffix} > ${ln_pair}${dataset}.lc.${suffix}
      if [ -f ${MOSES_DIR}/scripts/tokenizer/detokenizer.perl ]; then
        ${MOSES_DIR}/scripts/tokenizer/detokenizer.perl < ${ln_pair}${dataset}.lc.${suffix} > ${ln_pair}${dataset}.lc.detok.${suffix}
      fi
    done
  done
done

cd -
