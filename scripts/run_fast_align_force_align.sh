#!/bin/bash

set -ex

mkdir -p fastalign-forcealign
cd fastalign-forcealign

for ln_pair in "roen" "deen" "enfr"; do
  train_src="../train/${ln_pair}.lc.src"
  train_tgt="../train/${ln_pair}.lc.tgt"
  ../scripts/fast_align.sh ${train_src} ${train_tgt} ${ln_pair}
  ../scripts/create_fast_align_corpus.sh ../test/${ln_pair}.lc.src ../test/${ln_pair}.lc.tgt ${ln_pair}.test.txt
  # running forced align by hand for each direction requires parsing the error file of the training pass
  ${FASTALIGN_DIR}/build/force_align.py ${ln_pair}.model ${ln_pair}.error ${ln_pair}.reverse.model ${ln_pair}.reverse.error < ${ln_pair}.test.txt > ${ln_pair}.test.grow-diag-final.talp
done

cd -

