#!/bin/bash

set -ex

mkdir -p fastalign-forcealign
cd fastalign-forcealign

for ln_pair in "roen" "deen" "enfr"; do
  train_src="../train/${ln_pair}.lc.src"
  train_tgt="../train/${ln_pair}.lc.tgt"
  ../scripts/fast_align.sh ${train_src} ${train_tgt} ${ln_pair}

  # Run forced alignments with test data
  ## Create test forward and reverse corpus
  ../scripts/create_fast_align_corpus.sh ../test/${ln_pair}.lc.src ../test/${ln_pair}.lc.tgt ${ln_pair}.test.txt
  ../scripts/create_fast_align_corpus.sh ../test/${ln_pair}.lc.tgt ../test/${ln_pair}.lc.src ${ln_pair}.reverse.test.txt
  ## Parse parameters from the error logs of fastalign
  fwd_m=`grep "expected target length" ${ln_pair}.error | awk 'NF>1{print $NF}'`
  rev_m=`grep "expected target length" ${ln_pair}.reverse.error | awk 'NF>1{print $NF}'`
  fwd_t=`grep "final tension" ${ln_pair}.error | tail -n 1 | awk 'NF>1{print $NF}'`
  rev_t=`grep "final tension" ${ln_pair}.error | tail -n 1 | awk 'NF>1{print $NF}'`

  ## Run forced alignment
  ${FASTALIGN_DIR}/build/fast_align -i ${ln_pair}.test.txt -d -m ${fwd_m} -T ${fwd_t} -f ${ln_pair}.model | awk -F '\|\|\|' '{print $3}' > ${ln_pair}.test.talp
  ${FASTALIGN_DIR}/build/fast_align -i ${ln_pair}.reverse.test.txt -d -m ${rev_m} -T ${rev_t} -f ${ln_pair}.reverse.model | awk -F '\|\|\|' '{print $3}' > ${ln_pair}.reverse.test.talp
  # Combine both directions
  ../scripts/combine.sh ${ln_pair}.test.talp ${ln_pair}.reverse.test.talp ../test/${ln_pair}.talp > ${ln_pair}-results.txt
done

cd -

