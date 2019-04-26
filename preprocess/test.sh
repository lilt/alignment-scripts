#!/bin/bash

set -ex

mkdir -p test/
cd test

for ln_pair in "roen" "enfr" "deen"; do
  ../preprocess/${ln_pair}-test.sh
  ../scripts/generate_repeats.py ${ln_pair}.src ${ln_pair}.tgt ${ln_pair}.talp ${ln_pair}.2repeat --repeats 2
  for suffix in "src" "tgt"; do
    for dataset in "" ".trial" ".2repeat"; do
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
